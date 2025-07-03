import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:universal_exam/core/models/user_model.dart';
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
  late AdminController _adminController;

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
      final List<User> students =
          await _adminController.fetchUnverifiedTeachers();
      setState(() {
        _pendingRequests = students
            .map((user) => {
                  'id': user.id,
                  'firstName': user.firstName,
                  'lastName': user.lastName,
                  'fatherName': user.fatherName,
                  'motherName': user.motherName,
                  'dateOfBirth': user.dateOfBirth,
                  'email': user.email,
                  'role': user.role,
                  'specialty': user.specialty,
                  'profileImage': user.profileImage,
                  'verified': user.verified,
                  'createdAt': user.createdAt?.toIso8601String(),
                })
            .toList();
      });
    } catch (e) {
      print("Error loading unverified students: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
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
                          Text(
                              "الاسم الأول: ${request['firstName'] ?? 'غير متوفر'}"),
                          Text(
                              "الاسم الأخير: ${request['lastName'] ?? 'غير متوفر'}"),
                          Text(
                              "اسم الأب: ${request['fatherName'] ?? 'غير متوفر'}"),
                          Text(
                              "اسم الأم: ${request['motherName'] ?? 'غير متوفر'}"),
                          Text(
                              "تاريخ الميلاد: ${request['dateOfBirth'] ?? 'غير متوفر'}"),
                          Text(
                              "البريد الإلكتروني: ${request['email'] ?? 'غير متوفر'}"),
                          Text("الدور: ${request['role'] ?? 'غير محدد'}"),
                        ],
                      ),
                    ),
                    CircleAvatar(
                      radius: 40,
                      backgroundImage: request['profileImage'] != null
                          ? MemoryImage(base64Decode(request['profileImage']))
                          : AssetImage('assets/images/default_avatar.png')
                              as ImageProvider,
                    )
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
                          await widget.controller.verifyUser(request['id']);
                          setState(() {
                            _pendingRequests
                                .removeWhere((r) => r['id'] == request['id']);
                          });
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
                          await widget.controller.deleteUser(request['id']);
                          setState(() {
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

  @override
  Widget build(BuildContext context) {
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
            if (_isLoading)
              Expanded(child: Center(child: CircularProgressIndicator()))
            else if (_pendingRequests.isEmpty)
              Expanded(
                child: Center(
                  child: Text(
                    'لا توجد طلبات جديدة',
                    style: TextStyle(color: AppColors.primary, fontSize: 18),
                  ),
                ),
              )
            else
              Expanded(
                child: ListView.builder(
                  itemCount: _pendingRequests.length,
                  itemBuilder: (context, index) {
                    final request = _pendingRequests[index];
                    return GestureDetector(
                      onTap: () => _showTeacherDetails(context, request),
                      child: CustomListItem(
                        title: "${request['firstName']} ${request['lastName']}",
                        description: request['email'],
                        trailingIcon: Icon(Icons.warning_amber_rounded,
                            color: Colors.orange),
                        gradientColors: widget.gradientColors,
                        begin: widget.begin,
                        end: widget.end,
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}
