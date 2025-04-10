import 'package:flutter/material.dart';

class ColorSwatchesGrid extends StatelessWidget {
  final List<Color> colors;
  final void Function(Color) onSelect;

  const ColorSwatchesGrid({required this.colors, required this.onSelect, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      child: GridView.builder(
        itemCount: colors.length,
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 4, crossAxisSpacing: 20, mainAxisSpacing: 20,
        ),
        itemBuilder: (_, index) {
          return InkWell(
            onTap: () => onSelect(colors[index]),
            child: Container(
              decoration: BoxDecoration(
                // shape: BoxShape.circle,
                 borderRadius: BorderRadius.circular(10),
                color: colors[index],
                border: Border.all(color: Colors.grey, width: 2),
              ),
            ),
          );
        },
      ),
    );
  }
}
