import 'package:flutter/material.dart';
import 'package:bunny_wallet/core/extensions/context_extensions.dart';
import 'package:bunny_wallet/data/models/category_model.dart';

class CategoryPicker extends StatelessWidget {
  final List<CategoryModel> categories;
  final String? selectedId;
  final ValueChanged<CategoryModel> onSelected;

  const CategoryPicker({
    super.key,
    required this.categories,
    this.selectedId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: categories.map((cat) {
        final isSelected = cat.id == selectedId;
        return GestureDetector(
          onTap: () => onSelected(cat),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? cat.colorValue.withValues(alpha: 0.15)
                  : context.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
              border: isSelected
                  ? Border.all(color: cat.colorValue, width: 1.5)
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  cat.icon,
                  size: 18,
                  color: isSelected
                      ? cat.colorValue
                      : context.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  cat.name,
                  style: context.textTheme.labelMedium?.copyWith(
                    color: isSelected
                        ? cat.colorValue
                        : context.colorScheme.onSurfaceVariant,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
