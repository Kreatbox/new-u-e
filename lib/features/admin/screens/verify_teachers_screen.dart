import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';
import '../../admin/controllers/admin_controller.dart';

class VerifyTeachersScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const VerifyTeachersScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<VerifyTeachersScreen> createState() => _VerifyTeachersScreenState();
}

class _VerifyTeachersScreenState extends State<VerifyTeachersScreen> {
  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _rejectedRequests = [];
  bool _showRejected = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() => _loading = true);
    final requests = await widget.controller.fetchUnverifiedTeachers();
    setState(() {
      _pendingRequests = requests;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final requests = (_showRejected ? _rejectedRequests : _pendingRequests);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: CustomContainer(
        padding: EdgeInsets.symmetric(
          vertical: 32,
          horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
        ),
        gradientColors: widget.gradientColors,
        begin: widget.begin,
        end: widget.end,
        child: Column(
          children: [
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CustomButton(
                      text: "طلبات جديدة",
                      onPressed: () => setState(() => _showRejected = false),
                      gradientColors: _showRejected
                          ? [
                              AppColors.darkPrimary,
                              AppColors.lightSecondary,
                              AppColors.darkPrimary
                            ]
                          : widget.gradientColors),
                  const SizedBox(width: 16),
                  CustomButton(
                    text: "طلبات مرفوضة",
                    onPressed: () => setState(() => _showRejected = true),
                    gradientColors: _showRejected
                        ? widget.gradientColors
                        : [
                            AppColors.darkPrimary,
                            AppColors.lightSecondary,
                            AppColors.darkPrimary
                          ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : requests.isEmpty
                      ? Center(
                          child: Text(
                            _showRejected
                                ? "لا توجد طلبات مرفوضة"
                                : "لا توجد طلبات جديدة",
                            style: const TextStyle(color: Colors.white),
                          ),
                        )
                      : ListView.builder(
                          itemCount: requests.length,
                          itemBuilder: (context, index) {
                            final request = requests[index];
                            if (_showRejected) {
                              return GestureDetector(
                                onTap: () =>
                                    _showRejectedDetails(context, request),
                                child: CustomListItem(
                                  title:
                                      "${request['firstName']} ${request['lastName']}",
                                  description: request['email'],
                                  gradientColors: widget.gradientColors,
                                  begin: widget.begin,
                                  end: widget.end,
                                ),
                              );
                            } else {
                              return GestureDetector(
                                onTap: () =>
                                    _showTeacherDetails(context, request),
                                child: CustomListItem(
                                  title:
                                      "${request['firstName']} ${request['lastName']}",
                                  description: request['email'],
                                  gradientColors: widget.gradientColors,
                                  begin: widget.begin,
                                  end: widget.end,
                                ),
                              );
                            }
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }

  void _showTeacherDetails(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CustomBottomSheet(
          title: "تفاصيل الأستاذ",
          description: "عرض التفاصيل الكاملة لبيانات الأستاذ",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("الاسم الأول: ${request['firstName']}"),
                          Text("الاسم الأخير: ${request['lastName']}"),
                          Text("اسم الأب: ${request['fatherName']}"),
                          Text("اسم الأم: ${request['motherName']}"),
                          Text("تاريخ الميلاد: ${request['dateOfBirth']}"),
                          Text("البريد الإلكتروني: ${request['email']}"),
                          Text("الدور: ${request['role']}"),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: request['profileImage'] != null
                          ? MemoryImage(request['profileImage'] as Uint8List)
                          : const AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CustomButton(
                        text: "قبول",
                        gradientColors: widget.gradientColors,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 8),
                        onPressed: () async {
                          await widget.controller
                              .verifyUser("teachers", request['id']);
                          Navigator.pop(context);
                          _loadPendingRequests();
                        },
                      ),
                      CustomButton(
                        text: "رفض",
                        gradientColors: [
                          widget.gradientColors[1],
                          widget.gradientColors[0]
                        ],
                        padding: const EdgeInsets.symmetric(
                            horizontal: 48, vertical: 8),
                        onPressed: () async {
                          await widget.controller
                              .deleteUser("teachers", request['id']);
                          setState(() {
                            _rejectedRequests.add(request);
                            _pendingRequests
                                .removeWhere((r) => r['id'] == request['id']);
                          });
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRejectedDetails(
      BuildContext context, Map<String, dynamic> request) {
    final TextEditingController messageController = TextEditingController();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CustomBottomSheet(
          title: "إرسال رسالة",
          description: "حدد البيانات المغلوطة وأرسل رسالة للأستاذ",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("إرسال رسالة إلى: ${request['email']}"),
                const SizedBox(height: 16),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "أدخل البيانات المغلوطة أو سبب الرفض",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: CustomButton(
                    text: "إرسال",
                    gradientColors: widget.gradientColors,
                    onPressed: () {
                      setState(() {
                        _rejectedRequests
                            .removeWhere((r) => r['id'] == request['id']);
                      });
                      Navigator.pop(context);
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
