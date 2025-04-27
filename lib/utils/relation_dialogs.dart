import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../utils/app_text_styles.dart';

void showRelationDialog({
  required BuildContext context,
  required String title,
  required String description,
  required VoidCallback onContinue,
}) {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.dark,
      title: Text(title, style: AppTextStyles.subtitle),
      content: Text(description, style: AppTextStyles.body.copyWith(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(ctx).pop();
            onContinue();
          },
          child: Text('Далее', style: AppTextStyles.body.copyWith(color: AppColors.cyan)),
        ),
      ],
    ),
  );
}