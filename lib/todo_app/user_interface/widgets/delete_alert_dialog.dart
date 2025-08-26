import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../utils/colors.dart';
import '../../utils/fonts.dart';


class DeleteAlertDialog extends StatelessWidget {
  final String title;
  final String content;
  final String cancelText;
  final String confirmText;
  final Color confirmColor;

  const DeleteAlertDialog({
    super.key,
    required this.title,
    required this.content,
    this.cancelText = "Cancel",
    this.confirmText = "Delete",
    this.confirmColor = AppColors.error,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title, style: s20w700.copyWith(color: AppColors.primaryDark)),
      content: Text(
          content, style: s18w400.copyWith(color: AppColors.primaryDark)),
      actions: [
        TextButton(
          onPressed: () => Get.back(result: false),
          child: Text(cancelText,
              style: s18w700.copyWith(color: AppColors.primaryDark)),
        ),
        ElevatedButton(
          onPressed: () => Get.back(result: true),
          style: ElevatedButton.styleFrom(backgroundColor: confirmColor),
          child: Text(confirmText,
              style: s18w700.copyWith(color: AppColors.primaryDark)),
        ),
      ],
    );
  }
}