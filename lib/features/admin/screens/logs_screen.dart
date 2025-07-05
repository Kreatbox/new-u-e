import 'package:flutter/material.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../admin/controllers/admin_controller.dart';

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
  State<LogsScreen> createState() => LogsScreenState();
}

class LogsScreenState extends State<LogsScreen> {
  int unverifiedCount = 0;
  int unreadContactCount = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCounts();
  }

  Future<void> _loadCounts() async {
    try {
      final unverified = await widget.controller.getUnverifiedRequestsCount();
      final unreadContacts = await widget.controller.getUnreadContactRequestsCount();
      setState(() {
        unverifiedCount = unverified;
        unreadContactCount = unreadContacts;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading counts: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 32),
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading) 
            CircularProgressIndicator(color: Colors.white)
          else if (unverifiedCount > 0 || unreadContactCount > 0)
            Column(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  size: 80,
                  color: Colors.orange,
                ),
                const SizedBox(height: 24),
                Text(
                  "لديك طلبات معلقة",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),
                if (unverifiedCount > 0)
                  Column(
                    children: [
                      Text(
                        "طلبات التحقق",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$unverifiedCount طلب",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                if (unreadContactCount > 0)
                  Column(
                    children: [
                      Text(
                        "رسائل غير مقروءة",
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.white70,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "$unreadContactCount رسالة",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
              ],
            )
          else
            Column(
              children: [
                Icon(
                  Icons.check_circle_outline,
                  size: 80,
                  color: Colors.green,
                ),
                const SizedBox(height: 24),
                Text(
                  "لا توجد طلبات معلقة",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),
                Text(
                  "جميع الطلبات والرسائل تمت معالجتها",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
        ],
      ),
    );
  }
}
