import 'package:flutter/material.dart';

class ShimmerPostCard extends StatefulWidget {
  const ShimmerPostCard({super.key});

  @override
  State<ShimmerPostCard> createState() => _ShimmerPostCardState();
}

class _ShimmerPostCardState extends State<ShimmerPostCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat();
    _animation = Tween<double>(begin: -2, end: 2).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildShimmerBox(height: 180, borderRadius: 16),
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildShimmerBox(width: 80, height: 20),
                    const SizedBox(height: 12),
                    _buildShimmerBox(width: double.infinity, height: 20),
                    const SizedBox(height: 8),
                    _buildShimmerBox(width: 200, height: 16),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _buildShimmerBox(width: 32, height: 32, radius: 16),
                        const SizedBox(width: 8),
                        _buildShimmerBox(width: 100, height: 16),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShimmerBox({
    double? width,
    double height = 20,
    double radius = 8,
    double? borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: [
            (_animation.value - 1).clamp(0.0, 1.0),
            _animation.value.clamp(0.0, 1.0),
            (_animation.value + 1).clamp(0.0, 1.0),
          ],
        ),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}