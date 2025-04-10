import 'package:flutter/material.dart';

class OptionGrid extends StatelessWidget {
  final List<Map<String, String>> options;
  final String? selectedValue;
  final void Function(String) onSelected;

  const OptionGrid({
    required this.options,
    required this.selectedValue,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: options.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2, crossAxisSpacing: 15, mainAxisSpacing: 15, childAspectRatio: 3,
      ),
      itemBuilder: (_, index) {
        final option = options[index];
        final isSelected = selectedValue == option['value'];

        return InkWell(
          onTap: () => onSelected(option['value']!),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(color: isSelected ? Colors.blue : Colors.grey, width: 2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                option['label']!,
                style: TextStyle(
                  color: isSelected ? Colors.blue : Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
