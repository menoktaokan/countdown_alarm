import 'package:flutter/material.dart';

class _SingleItemScrollPhysics extends FixedExtentScrollPhysics {
  const _SingleItemScrollPhysics({super.parent});

  @override
  _SingleItemScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return _SingleItemScrollPhysics(parent: buildParent(ancestor));
  }

  @override
  double applyPhysicsToUserOffset(ScrollMetrics position, double offset) {
    // Fare tekerleği ile tek tek kaydırma için offset'i sınırla
    // itemExtent 50 olduğu için, her tekerlek hareketinde maksimum 50 pixel kaydır
    if (offset.abs() > 50) {
      return offset > 0 ? 50 : -50;
    }
    return super.applyPhysicsToUserOffset(position, offset);
  }

  @override
  Simulation? createBallisticSimulation(
    ScrollMetrics position,
    double velocity,
  ) {
    // Daha yumuşak kaydırma için velocity'yi sınırla
    if (velocity.abs() > 1000) {
      velocity = velocity > 0 ? 1000 : -1000;
    }
    return super.createBallisticSimulation(position, velocity);
  }
}

class TimePickerWheel extends StatefulWidget {
  final int value;
  final int min;
  final int max;
  final ValueChanged<int> onChanged;
  final String label;

  const TimePickerWheel({
    super.key,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    required this.label,
  });

  @override
  State<TimePickerWheel> createState() => _TimePickerWheelState();
}

class _TimePickerWheelState extends State<TimePickerWheel> {
  late FixedExtentScrollController _controller;
  static const int _largeNumber = 10000; // Sonsuz döngü için büyük sayı
  int _centerIndex = 0; // Merkez index'i
  int _selectedIndex = 0; // Seçili index'i

  @override
  void initState() {
    super.initState();
    // Merkez index'i hesapla
    // Yukarı scroll = index azalır = değer azalır (normal davranış)
    // Merkez noktasındaki değer widget.value olmalı
    final centerPoint = _largeNumber ~/ 2;
    final valueOffset = widget.value - widget.min;
    // Merkez noktasından valueOffset kadar aşağı (index artar) gitmeliyiz
    _centerIndex = centerPoint + valueOffset;
    _selectedIndex = _centerIndex;
    // Controller'ı doğru index'te başlat
    _controller = FixedExtentScrollController(initialItem: _centerIndex);
    // İlk render sonrasında seçili index'i güncelle
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _controller.hasClients) {
        setState(() {
          _selectedIndex = _controller.selectedItem;
        });
      }
    });
  }

  @override
  void didUpdateWidget(TimePickerWheel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value && _controller.hasClients) {
      // Mevcut index'ten gerçek değeri al
      final currentIndex = _controller.selectedItem;
      final currentValue = _getValueFromIndex(currentIndex);
      final newValue = widget.value;
      
      // Yeni merkez index'i hesapla
      final valueDiff = newValue - currentValue;
      final range = widget.max - widget.min + 1;
      
      // En kısa yolu bul (döngüsel)
      int shortestDiff = valueDiff;
      if (valueDiff.abs() > range / 2) {
        if (valueDiff > 0) {
          shortestDiff = valueDiff - range;
        } else {
          shortestDiff = valueDiff + range;
        }
      }
      
      // Normal davranış: yukarı scroll = index azalır = değer azalır
      _centerIndex = currentIndex + shortestDiff;
      
      // Merkezden çok uzaklaştıysa yeniden merkeze al
      final centerPoint = _largeNumber ~/ 2;
      if ((_centerIndex - centerPoint).abs() > _largeNumber ~/ 4) {
        final valueOffset = widget.value - widget.min;
        // Normal davranış: offset'i doğrudan kullanıyoruz
        _centerIndex = centerPoint + valueOffset;
      }
      
      final diff = (widget.value - currentValue).abs();
      if (diff > 5) {
        _controller.jumpToItem(_centerIndex);
        setState(() {
          _selectedIndex = _centerIndex;
        });
      } else {
        _controller.animateToItem(
          _centerIndex,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeInOut,
        );
        setState(() {
          _selectedIndex = _centerIndex;
        });
      }
    }
  }

  // Index'ten gerçek değeri hesapla
  int _getValueFromIndex(int index) {
    final range = widget.max - widget.min + 1;
    // Merkez noktasından uzaklığı hesapla
    // _centerIndex merkez noktasıdır ve buradaki değer widget.value'dur
    final offsetFromCenter = index - _centerIndex;
    // Merkez noktasındaki değer widget.value
    // ListWheelScrollView'da yukarı scroll = index azalır, aşağı scroll = index artar
    // Yukarı scroll'da değerin azalmasını istiyoruz (normal davranış)
    var result = widget.value + offsetFromCenter;
    // Sonucu min-max aralığına normalize et (döngüsel)
    while (result > widget.max) {
      result -= range;
    }
    while (result < widget.min) {
      result += range;
    }
    return result;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 60,
      height: 150,
      child: ListWheelScrollView.useDelegate(
        itemExtent: 50,
        diameterRatio: 1.5,
        physics: const _SingleItemScrollPhysics(),
        controller: _controller,
        onSelectedItemChanged: (index) {
          final value = _getValueFromIndex(index);
          setState(() {
            _selectedIndex = index;
          });
          widget.onChanged(value);
          // Merkezden çok uzaklaştıysa yeniden merkeze al
          final centerPoint = _largeNumber ~/ 2;
          if ((index - centerPoint).abs() > _largeNumber ~/ 4) {
            final valueOffset = value - widget.min;
            // Normal davranış: offset'i doğrudan kullanıyoruz
            _centerIndex = centerPoint + valueOffset;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_controller.hasClients) {
                _controller.jumpToItem(_centerIndex);
                setState(() {
                  _selectedIndex = _centerIndex;
                });
              }
            });
          } else {
            // _centerIndex'i güncelle
            _centerIndex = index;
          }
        },
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            final value = _getValueFromIndex(index);
            // Seçili index'i kontrol et
            final isSelected = _selectedIndex == index;
            return Center(
              child: Text(
                value.toString().padLeft(2, '0'),
                style: TextStyle(
                  fontSize: isSelected ? 32 : 24,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
                ),
              ),
            );
          },
          childCount: _largeNumber,
        ),
      ),
    );
  }
}
