import 'package:bedaya2/core/theme/styles.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

// Go Back
void back() {
  Get.back();
}

void offPage(Widget page) {
  Get.off(page);
}

void showSuccessDialog(BuildContext context, title, text, callback) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(title, style: AppStyles.h3),
        content: Text(text, style: AppStyles.bodyMedium),
        actions: <Widget>[
          TextButton(
            child: Text("OK", style: AppStyles.bodyMedium),
            onPressed: () {
              callback();
            },
          ),
        ],
      );
    },
  );
}
