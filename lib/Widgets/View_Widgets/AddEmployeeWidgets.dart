import 'package:flutter/material.dart';
import 'package:project_v1/Widgets/app_theme.dart';

Widget field({
  required String label,
  required IconData icon,
  required Widget child,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        textDirection: TextDirection.rtl,
        children: [
          Icon(icon, size: 18, color: mutedText),
          const SizedBox(width: 7),
          Text(
            label,
            textAlign: TextAlign.right,
            style: const TextStyle(
              color: textDark,
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
      const SizedBox(height: 8),
      child,
    ],
  );
}

Widget addEmployeePageHeader(BuildContext context) {
  return Container(
    height: 78,
    padding: const EdgeInsets.symmetric(horizontal: 30),
    decoration: const BoxDecoration(
      color: Colors.white,
      border: Border(bottom: BorderSide(color: borderColor, width: 1)),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: Row(
          textDirection: TextDirection.rtl,
          children: [
            Builder(
              builder: (context) => Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(10),
                  onTap: () => Scaffold.of(context).openDrawer(),
                  child: const SizedBox(
                    width: 44,
                    height: 44,
                    child: Icon(
                      Icons.menu_rounded,
                      color: textDark,
                      size: 25,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Container(width: 1, height: 30, color: borderColor),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'إضافة موظف',
                    textAlign: TextAlign.right,
                    style: TextStyle(
                      color: textDark,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  SizedBox(height: 1),
                  Text(
                    'إنشاء حساب جديد لموظفي البلدية',
                    textAlign: TextAlign.right,
                    style: TextStyle(color: mutedText, fontSize: 12),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    ),
  );
}

Widget desktopContent({
  required Widget child,
  EdgeInsets padding = const EdgeInsets.fromLTRB(30, 24, 30, 30),
}) {
  return Padding(
    padding: padding,
    child: Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1500),
        child: SizedBox(width: double.infinity, child: child),
      ),
    ),
  );
}
