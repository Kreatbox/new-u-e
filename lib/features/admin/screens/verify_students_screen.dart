import '../controllers/admin_controller.dart';
import 'package:flutter/material.dart';
import 'dart:typed_data';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class VerifyStudentsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const VerifyStudentsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<VerifyStudentsScreen> createState() => _VerifyStudentsScreenState();
}

class _VerifyStudentsScreenState extends State<VerifyStudentsScreen> {
  late AdminController _adminController;

  List<Map<String, dynamic>> _pendingRequests = [];
  List<Map<String, dynamic>> _rejectedRequests = [];
  bool _showRejected = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _adminController = widget.controller;
    _loadPendingRequests();
  }

  Future<void> _loadPendingRequests() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final students = await _adminController.fetchUnverifiedStudents();
      setState(() {
        _pendingRequests = students.map((student) {
          return {
            ...student,
            'status': 'pending',
          };
        }).toList();
      });
    } catch (e) {
      print("Error loading unverified students: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 32.0),
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
            if (_isLoading)
              const Expanded(
                child: Center(child: CircularProgressIndicator()),
              )
            else if (requests.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    _showRejected
                        ? 'لا توجد طلبات مرفوضة'
                        : 'لا توجد طلبات جديدة',
                    style: TextStyle(color: AppColors.primary, fontSize: 18),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: requests.length,
                  itemBuilder: (context, index) {
                    final request = requests[index];
                    if (_showRejected) {
                      return GestureDetector(
                        onTap: () => _showRejectedDetails(context, request),
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
                        onTap: () => _showStudentDetails(context, request),
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

  void _showStudentDetails(BuildContext context, Map<String, dynamic> request) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return CustomBottomSheet(
          title: "تفاصيل الطالب",
          description: "عرض التفاصيل الكاملة لبيانات الطالب",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                if (request['status'] == 'pending')
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
                            await _acceptRequest(request);
                            Navigator.pop(context);
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
                            await _rejectRequest(request);
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
          description: "حدد البيانات المغلوطة وأرسل رسالة للطالب",
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
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
                        _rejectedRequests.remove(request);
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

  Future<void> _acceptRequest(Map<String, dynamic> request) async {
    try {
      await _adminController.verifyUser('students', request['id']);
      setState(() {
        _pendingRequests.remove(request);
      });
    } catch (e) {
      print("Error verifying user: $e");
    }
  }

  Future<void> _rejectRequest(Map<String, dynamic> request) async {
    try {
      await _adminController.deleteUser('students', request['id']);
      setState(() {
        _pendingRequests.remove(request);
        request['status'] = 'rejected';
        _rejectedRequests.add(request);
      });
    } catch (e) {
      print("Error deleting user: $e");
    }
  }
}
