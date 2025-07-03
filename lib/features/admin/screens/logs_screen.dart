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
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUnverifiedCount();
  }

  Future<void> _loadUnverifiedCount() async {
    try {
      final count = await widget.controller.getUnverifiedRequestsCount();
      setState(() {
        unverifiedCount = count;
        isLoading = false;
      });
    } catch (e) {
      print("Error loading unverified count: $e");
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
          const SizedBox(height: 16),
          Text(
            "$unverifiedCount طلب",
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 48),
          if (isLoading) const CircularProgressIndicator(color: Colors.white),
        ],
      ),
    );
  }
}
