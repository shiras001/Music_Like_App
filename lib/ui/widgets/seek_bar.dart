part of '../app_ui.dart';

// ==============================================================================
// カスタム Seek Bar（スムーズなドラッグ操作用）
// ==============================================================================

class _SeekBar extends StatefulWidget {
  final Duration position;
  final Duration duration;
  final ValueChanged<Duration> onSeek;

  const _SeekBar({
    required this.position,
    required this.duration,
    required this.onSeek,
  });

  @override
  State<_SeekBar> createState() => _SeekBarState();
}

class _SeekBarState extends State<_SeekBar> {
  double? _dragValue;

  @override
  Widget build(BuildContext context) {
    final value = _dragValue ?? widget.position.inSeconds.toDouble();
    final max = widget.duration.inSeconds.toDouble();

    return Slider(
      value: value.clamp(0.0, max),
      max: max > 0 ? max : 1.0,
      onChangeStart: (val) {
        setState(() {
          _dragValue = val;
        });
      },
      onChanged: (val) {
        setState(() {
          _dragValue = val;
        });
      },
      onChangeEnd: (val) {
        widget.onSeek(Duration(seconds: val.toInt()));
        setState(() {
          _dragValue = null;
        });
      },
    );
  }
}
