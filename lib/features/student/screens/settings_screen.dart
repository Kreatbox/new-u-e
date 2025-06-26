import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/list_item.dart';

class SettingsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const SettingsScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool isExamNotificationsEnabled = true;
  bool isResultsNotificationsEnabled = false;

  void toggleExamNotifications(bool value) {
    setState(() {
      isExamNotificationsEnabled = value;
    });
  }

  void toggleResultsNotifications(bool value) {
    setState(() {
      isResultsNotificationsEnabled = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      child: ListView(
        children: [
          Text(
            "الإعدادات",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          ..._buildSettingsItems(),
        ],
      ),
    );
  }

  List<Widget> _buildSettingsItems() {
    return [
      GestureDetector(
        onTap: () {
          _showHelpDetails(
            context,
            "تعديل المعلومات الشخصية",
            "يمكنك تعديل اسمك، بريدك الإلكتروني، أو باقي التفاصيل الشخصية.",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  decoration: InputDecoration(
                    labelText: "الاسم",
                    hintText: "أدخل اسمك الكامل",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  decoration: InputDecoration(
                    labelText: "البريد الإلكتروني",
                    hintText: "أدخل بريدك الإلكتروني",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onPressed: () {},
                  child: Text("حفظ التعديلات"),
                ),
              ],
            ),
          );
        },
        child: CustomListItem(
          title: "تعديل المعلومات الشخصية",
          description: "تعديل بياناتك الشخصية مثل الاسم والبريد الإلكتروني.",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
        ),
      ),
      GestureDetector(
        onTap: () {
          _showHelpDetails(
            context,
            "تغيير كلمة المرور",
            "يمكنك تغيير كلمة مرورك هنا، تأكد من اختيار كلمة مرور قوية.",
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الحالية",
                    hintText: "أدخل كلمة المرور الحالية",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "كلمة المرور الجديدة",
                    hintText: "أدخل كلمة المرور الجديدة",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  obscureText: true,
                  decoration: InputDecoration(
                    labelText: "تأكيد كلمة المرور الجديدة",
                    hintText: "تأكيد كلمة المرور الجديدة",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                CustomButton(
                  onPressed: () {},
                  child: Text("تغيير كلمة المرور"),
                ),
              ],
            ),
          );
        },
        child: CustomListItem(
          title: "تغيير كلمة المرور",
          description: "تغيير كلمة المرور لتأمين حسابك.",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
        ),
      ),
      GestureDetector(
          onTap: () {
            _showHelpDetails(
              context,
              "إشعارات الامتحانات",
              "تمكنك هذه الميزة من تفعيل أو إيقاف إشعارات الامتحانات.",
              child: Column(
                children: [
                  ListTile(
                    title: Text("تفعيل الإشعارات"),
                    trailing: Switch(
                      value: isExamNotificationsEnabled,
                      onChanged: toggleExamNotifications,
                    ),
                  ),
                ],
              ),
            );
          },
          child: CustomListItem(
            title: "تفعيل/إيقاف إشعارات الامتحانات",
            description: "إدارة إشعارات الامتحانات وتواريخها.",
            gradientColors: widget.gradientColors,
            begin: widget.begin,
            end: widget.end,
          )),
      const SizedBox(height: 4),
      GestureDetector(
        onTap: () {
          _showHelpDetails(
            context,
            "إشعارات النتائج",
            "تمكنك هذه الميزة من تفعيل أو إيقاف إشعارات نتائج الامتحانات.",
            child: Column(
              children: [
                ListTile(
                  title: Text("تفعيل الإشعارات"),
                  trailing: Switch(
                    value: isResultsNotificationsEnabled,
                    onChanged: toggleResultsNotifications,
                  ),
                ),
              ],
            ),
          );
        },
        child: CustomListItem(
          title: "تفعيل/إيقاف إشعارات النتائج",
          description: "إدارة إشعارات نتائج الامتحانات.",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
        ),
      ),
    ];
  }

  void _showHelpDetails(BuildContext context, String title, String description,
      {Widget? child}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return CustomBottomSheet(
          title: title,
          description: description,
          child: child,
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
        );
      },
    );
  }
}
