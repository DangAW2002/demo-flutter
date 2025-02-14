import 'package:flutter/material.dart';
import 'package:demo/constants/colors.dart'; // Thêm dòng này

class HealthTile extends StatelessWidget {
  final dynamic value; // Changed to dynamic to handle both int and double
  final String title;
  final Color color;
  final IconData icon;
  final String unit; // Added unit parameter
  final bool isDark; // Thêm tham số isDark
  final Function(dynamic)? onUpdate; // Add this line

  const HealthTile({
    super.key,
    required this.value,
    required this.title,
    required this.color,
    required this.icon,
    required this.unit, // Added unit parameter
    required this.isDark,
    this.onUpdate, // Add this line
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        if (onUpdate != null) {
          final TextEditingController controller =
              TextEditingController(text: value.toString());
          final result = await showDialog<String>(
            context: context,
            builder: (context) => AlertDialog(
              title: Text('Update $title'),
              content: TextField(
                controller: controller,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Enter new value',
                  suffixText: unit,
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, controller.text),
                  child: const Text('Save'),
                ),
              ],
            ),
          );

          if (result != null) {
            final newValue = double.tryParse(result);
            if (newValue != null) {
              onUpdate!(newValue);
            }
          }
          controller.dispose();
        }
      },
      child: Container(
        width: 180,
        height: 170,
        margin: const EdgeInsets.all(6),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.surfaceDark : Colors.white,
          borderRadius: BorderRadius.circular(25),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 2), // Minimal spacing between icon and title
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(flex: 6), // Top portion of space
            Text(
              '$value $unit',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color:
                    isDark ? AppColors.textPrimaryDark : AppColors.textPrimary,
              ),
            ),
            const Spacer(flex: 2), // Bottom portion of space
          ],
        ),
      ),
    );
  }
}
