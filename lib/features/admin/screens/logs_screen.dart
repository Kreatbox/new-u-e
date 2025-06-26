import 'package:flutter/material.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/theme/colors.dart';
import '../controllers/admin_controller.dart';

class LogsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const LogsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<LogsScreen> createState() => _LogsScreenState();
}

class _LogsScreenState extends State<LogsScreen> {
  List<Map<String, dynamic>> logs = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadLogs();
  }

  Future<void> loadLogs() async {
    try {
      final data = await widget.controller.fetchLogs();
      setState(() {
        logs = data;
        isLoading = false;
      });
    } catch (e) {
      print("خطأ أثناء تحميل السجلات: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : logs.isEmpty
              ? const Center(child: Text("لا يوجد سجلات"))
              : ListView.builder(
                  itemCount: logs.length,
                  itemBuilder: (context, index) {
                    final log = logs[index];
                    return CustomListItem(
                      title: log['title'] ?? 'عنوان غير معروف',
                      description: log['description'] ?? '',
                      gradientColors: widget.gradientColors,
                      begin: widget.begin,
                      end: widget.end,
                      trailingIcon: Icon(
                        Icons.arrow_forward_ios,
                        color: AppColors.primary,
                        size: 18,
                      ),
                      onPressed: () {
                        print('تفاصيل السجل: ${log['title']}');
                      },
                    );
                  },
                ),
    );
  }
}
