import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

class InlineAudioPlayerWidget extends StatefulWidget {
  final String audioAsset;
  final VoidCallback? onShowTranscript;

  const InlineAudioPlayerWidget({super.key, required this.audioAsset, this.onShowTranscript});

  @override
  State<InlineAudioPlayerWidget> createState() => _InlineAudioPlayerWidgetState();
}

class _InlineAudioPlayerWidgetState extends State<InlineAudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isPlaying = false;
  bool _isDragging = false;
  double _dragValue = 0.0;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;

  @override
  void initState() {
    super.initState();
    _initAudio();
  }

  Future<void> _initAudio() async {
    _audioPlayer.onDurationChanged.listen((Duration d) {
      if (mounted) setState(() => _duration = d);
    });

    _audioPlayer.onPositionChanged.listen((Duration p) {
      if (mounted) setState(() => _position = p);
    });

    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) {
      if (mounted) setState(() => _isPlaying = s == PlayerState.playing);
    });

    await _audioPlayer.play(AssetSource('audio/${widget.audioAsset}'));
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return "$twoDigitMinutes:$twoDigitSeconds";
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.s24, vertical: AppSpacing.s12),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(bottom: BorderSide(color: AppColors.border)),
      ),
      child: Row(
        children: [
          IconButton(
            iconSize: 32,
            icon: Icon(
              _isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
              color: AppColors.primaryNavy,
            ),
            onPressed: () {
              if (_isPlaying) {
                _audioPlayer.pause();
              } else {
                _audioPlayer.resume();
              }
            },
          ),
          const SizedBox(width: AppSpacing.s16),
          Text(
            _formatDuration(_position),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(width: AppSpacing.s16),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
                activeTrackColor: AppColors.primaryNavy,
                inactiveTrackColor: AppColors.border,
                thumbColor: AppColors.primaryNavy,
              ),
              child: Slider(
                min: 0,
                max: _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0,
                value: _isDragging 
                  ? _dragValue.clamp(0.0, _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0)
                  : _position.inSeconds.toDouble().clamp(0.0, _duration.inSeconds > 0 ? _duration.inSeconds.toDouble() : 1.0),
                onChangeStart: (value) {
                  setState(() {
                    _isDragging = true;
                    _dragValue = value;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    _dragValue = value;
                  });
                },
                onChangeEnd: (value) {
                  setState(() {
                    _isDragging = false;
                  });
                  _audioPlayer.seek(Duration(seconds: value.toInt()));
                },
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.s16),
          Text(
            _formatDuration(_duration),
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.secondaryText),
          ),
          if (widget.onShowTranscript != null) ...[
            const SizedBox(width: AppSpacing.s16),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryNavy,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: widget.onShowTranscript,
              icon: const Icon(Icons.subtitles_outlined, size: 18),
              label: const Text("Audio Script", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ),
          ],
        ],
      ),
    );
  }
}
