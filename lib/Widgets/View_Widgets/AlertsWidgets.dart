import 'package:flutter/material.dart';
import 'package:project_v1/Widgets/app_theme.dart';

Widget alertsPageHeader(BuildContext context) {
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
                    child: Icon(Icons.menu_rounded, color: textDark, size: 25),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 18),
            Container(width: 1, height: 30, color: borderColor),
            const SizedBox(width: 18),
            const Expanded(
              child: Directionality(
                textDirection: TextDirection.rtl,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'إنشاء تنبيه',
                        textAlign: TextAlign.right,
                        style: TextStyle(
                          color: textDark,
                          fontSize: 22,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    SizedBox(height: 1),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        'إنشاء تنبيهات وتخصيصها',
                        textAlign: TextAlign.right,
                        style: TextStyle(color: mutedText, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 28),
          ],
        ),
      ),
    ),
  );
}
