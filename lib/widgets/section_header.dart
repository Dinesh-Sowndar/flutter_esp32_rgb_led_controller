import 'package:flutter/material.dart';

class SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onMoreTap;

  const SectionHeader({required this.title, this.onMoreTap, super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
        GestureDetector(
          onTap: onMoreTap,
          child: const Text("More > ", style: TextStyle(fontSize: 12, color: Colors.blue)),
        ),
      ],
    );
  }
}
