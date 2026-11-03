import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ResizableSplitView extends StatefulWidget {
  final Widget leftChild;
  final Widget rightChild;
  final double initialRatio;

  const ResizableSplitView({
    super.key,
    required this.leftChild,
    required this.rightChild,
    this.initialRatio = 0.5,
  });

  @override
  State<ResizableSplitView> createState() => _ResizableSplitViewState();
}

class _ResizableSplitViewState extends State<ResizableSplitView> {
  late double _ratio;
  double _maxWidth = 0;

  @override
  void initState() {
    super.initState();
    _ratio = widget.initialRatio;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _maxWidth = constraints.maxWidth;
        
        return Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Left Side
            SizedBox(
              width: _maxWidth * _ratio,
              child: widget.leftChild,
            ),
            
            // Draggable Divider
            GestureDetector(
              behavior: HitTestBehavior.translucent,
              onPanUpdate: (details) {
                setState(() {
                  _ratio += details.delta.dx / _maxWidth;
                  // Clamp ratio between 20% and 80% to prevent either side from disappearing completely
                  if (_ratio < 0.2) _ratio = 0.2;
                  if (_ratio > 0.8) _ratio = 0.8;
                });
              },
              child: Container(
                width: 24, // Increased width to make it easier to grab
                color: const Color(0xFFE5E7EB), // Light gray divider color like the image
                child: const Center(
                  child: Icon(
                    Icons.compare_arrows,
                    size: 24, // Increased icon size for better visibility
                    color: AppColors.secondaryText,
                  ),
                ),
              ),
            ),
            
            // Right Side
            Expanded(
              child: widget.rightChild,
            ),
          ],
        );
      },
    );
  }
}
