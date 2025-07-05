import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/widgets/dropdown_list.dart';
import '../controllers/admin_controller.dart';

class ManageContactRequestsScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const ManageContactRequestsScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<ManageContactRequestsScreen> createState() =>
      _ManageContactRequestsScreenState();
}

class _ManageContactRequestsScreenState
    extends State<ManageContactRequestsScreen> {
  List<Map<String, dynamic>> contactRequests = [];
  bool isLoading = true;
  String filterType = 'all';

  @override
  void initState() {
    super.initState();
    _loadContactRequests();
  }

  Future<void> _loadContactRequests() async {
    setState(() {
      isLoading = true;
    });

    try {
      bool? isReadFilter;
      if (filterType == 'unread') {
        isReadFilter = false;
      } else if (filterType == 'read') {
        isReadFilter = true;
      }

      final requests =
          await widget.controller.fetchContactRequests(isRead: isReadFilter);
      setState(() {
        contactRequests = requests;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading contact requests: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> _markAsRead(String requestId) async {
    try {
      await widget.controller.markContactRequestAsRead(requestId);
      _loadContactRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم تحديد الرسالة كمقروءة')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في تحديث الرسالة')),
      );
    }
  }

  Future<void> _deleteRequest(String requestId) async {
    try {
      await widget.controller.deleteContactRequest(requestId);
      _loadContactRequests();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('تم حذف الرسالة')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('خطأ في حذف الرسالة')),
      );
    }
  }

  void _showRequestDetails(Map<String, dynamic> request) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkPrimary,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(2.0),
        ),
        title: Text(
          request['title'] ?? '',
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomListItem(
                title: 'معلومات المرسل',
                additionalTitles: [
                  'الاسم',
                  'البريد الإلكتروني',
                  'الدور',
                  'التخصص'
                ],
                additionalDescriptions: [
                  request['userName'] ?? '',
                  request['userEmail'] ?? '',
                  request['userRole'] ?? '',
                  request['specialty'] ?? '',
                ],
                gradientColors: widget.gradientColors,
                begin: widget.begin,
                end: widget.end,
                padding: EdgeInsets.zero,
              ),
              SizedBox(height: 16),
              CustomListItem(
                title: 'محتوى الرسالة',
                description: request['message'] ?? '',
                additionalTitles: ['التاريخ'],
                additionalDescriptions: [_formatDate(request['createdAt'])],
                gradientColors: widget.gradientColors,
                begin: widget.begin,
                end: widget.end,
                padding: EdgeInsets.zero,
              ),
            ],
          ),
        ),
        actions: [
          CustomButton(
            onPressed: () => Navigator.pop(context),
            text: 'إغلاق',
            gradientColors: widget.gradientColors,
          ),
          if (request['isRead'] != true)
            CustomButton(
              onPressed: () {
                Navigator.pop(context);
                _markAsRead(request['id']);
              },
              text: 'تحديد كمقروءة',
              gradientColors: widget.gradientColors,
            ),
          CustomButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteRequest(request['id']);
            },
            text: 'حذف',
            gradientColors: [Colors.red, Colors.red.shade700],
          ),
        ],
      ),
    );
  }

  String _formatDate(dynamic timestamp) {
    if (timestamp is Timestamp) {
      final date = timestamp.toDate();
      return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
    }
    return 'غير محدد';
  }

  String _getFilterText() {
    switch (filterType) {
      case 'all':
        return 'جميع الرسائل';
      case 'unread':
        return 'غير مقروءة';
      case 'read':
        return 'مقروءة';
      default:
        return 'جميع الرسائل';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      begin: widget.begin,
      end: widget.end,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 16 : 32.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'إدارة طلبات التواصل',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              CustomDropdownMenu(
                items: ['جميع الرسائل', 'غير مقروءة', 'مقروءة'],
                onItemSelected: (value) {
                  setState(() {
                    switch (value) {
                      case 'جميع الرسائل':
                        filterType = 'all';
                        break;
                      case 'غير مقروءة':
                        filterType = 'unread';
                        break;
                      case 'مقروءة':
                        filterType = 'read';
                        break;
                    }
                  });
                  _loadContactRequests();
                },
                buttonText: _getFilterText(),
                gradientColors: widget.gradientColors,
                begin: widget.begin,
                end: widget.end,
              ),
              CustomButton(
                onPressed: _loadContactRequests,
                text: 'تحديث',
                gradientColors: widget.gradientColors,
              ),
            ],
          ),
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                    ),
                  )
                : contactRequests.isEmpty
                    ? Center(
                        child: CustomListItem(
                          title: 'لا توجد رسائل',
                          description: 'لا توجد رسائل في الوقت الحالي',
                          gradientColors: widget.gradientColors,
                          begin: widget.begin,
                          end: widget.end,
                          padding: EdgeInsets.symmetric(horizontal: 64),
                        ),
                      )
                    : ListView.builder(
                        itemCount: contactRequests.length,
                        itemBuilder: (context, index) {
                          final request = contactRequests[index];
                          final isRead = request['isRead'] == true;

                          return CustomListItem(
                            title: request['title'] ?? '',
                            description: request['message'] ?? '',
                            additionalTitles: ['المرسل', 'التاريخ'],
                            additionalDescriptions: [
                              '${request['userName'] ?? ''} - ${request['userRole'] ?? ''}',
                              _formatDate(request['createdAt']),
                            ],
                            gradientColors: isRead
                                ? [
                                    AppColors.secondary,
                                    AppColors.primary,
                                    AppColors.secondary
                                  ]
                                : widget.gradientColors,
                            begin: widget.begin,
                            end: widget.end,
                            trailingIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (!isRead)
                                  Icon(
                                    Icons.mark_email_unread,
                                    color: AppColors.primary,
                                    size: 20,
                                  ),
                                SizedBox(width: 8),
                                Icon(
                                  Icons.arrow_forward_ios,
                                  color: AppColors.primary,
                                  size: 18,
                                ),
                              ],
                            ),
                            onPressed: () => _showRequestDetails(request),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
