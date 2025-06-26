import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import '../../../core/models/exam_model.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/list_item.dart';
import '../../../shared/widgets/show_dialog.dart';

class UserManagementScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;
  final AdminController controller;

  const UserManagementScreen({
    required this.gradientColors,
    required this.begin,
    required this.end,
    required this.controller,
    Key? key,
  }) : super(key: key);

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<User> users = [];
  List<User> filteredUsers = [];
  String userTypeFilter = 'all';
  TextEditingController searchController = TextEditingController();

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() {
      isLoading = true;
    });

    final rawUsers = await widget.controller.fetchAllUsers();
    users = rawUsers.map((userMap) {
      List<Exam> examsList = [];
      if (userMap['grades'] != null && userMap['grades'] is List) {
        examsList = (userMap['grades'] as List).map((grade) {
          if (grade is Map<String, dynamic>) {
            return Exam(
                name: grade['name'] ?? 'امتحان', grade: grade['grade'] ?? 0);
          }
          return Exam(name: 'امتحان', grade: grade);
        }).toList();
      }
      return User(
        id: userMap['id'] ?? '',
        firstName:
            userMap['firstName'] ?? userMap['name']?.split(' ').first ?? '',
        lastName: userMap['lastName'] ?? userMap['name']?.split(' ').last ?? '',
        fatherName: userMap['fatherName'] ?? '',
        motherName: userMap['motherName'] ?? '',
        dateOfBirth: userMap['dateOfBirth'] ?? '',
        email: userMap['email'] ?? '',
        role: userMap['type'] ?? userMap['role'] ?? 'student',
        profileImage: userMap['profileImage'] ?? '',
        exams: examsList,
      );
    }).toList();

    filteredUsers = users;
    setState(() {
      isLoading = false;
    });
  }

  void filterUsers(String query) {
    setState(() {
      filteredUsers = users.where((user) {
        final matchesUserType =
            userTypeFilter == 'all' || user.role == userTypeFilter;
        final matchesSearch = user.firstName.contains(query) ||
            user.email.contains(query) ||
            user.lastName.contains(query);
        return matchesUserType && matchesSearch;
      }).toList();
    });
  }

  void showUserDetails(User user) {
    showDialog(
      context: context,
      builder: (context) {
        return CustomShowDialog(
          title: '${user.firstName} ${user.lastName}',
          description: user.email,
          userDetails: user.userDetails,
          exams: user.exams,
          profileImageUrl: user.profileImage,
          gradientColors: widget.gradientColors,
          begin: widget.begin,
          end: widget.end,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomContainer(
      gradientColors: widget.gradientColors,
      padding: EdgeInsets.symmetric(
        vertical: 32,
        horizontal: MediaQuery.of(context).size.width < 700 ? 0 : 32.0,
      ),
      begin: widget.begin,
      end: widget.end,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 32),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'إدارة المستخدمين',
              style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary),
            ),
          ),
          SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: filterUsers,
                    decoration: InputDecoration(
                      labelText: 'بحث عن مستخدم',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                ),
                SizedBox(width: 16),
                DropdownButton<String>(
                  value: userTypeFilter,
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    setState(() {
                      userTypeFilter = newValue;
                      filterUsers(searchController.text);
                    });
                  },
                  items: ['all', 'doctor', 'student'].map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value == 'all'
                          ? 'جميع المستخدمين'
                          : (value == 'doctor' ? 'دكاترة' : 'طلاب')),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          SizedBox(height: 16),
          Expanded(
            child: isLoading
                ? Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? Center(child: Text('لا توجد بيانات'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return CustomListItem(
                            title: '${user.firstName} ${user.lastName}',
                            description: user.email,
                            gradientColors: widget.gradientColors,
                            begin: widget.begin,
                            end: widget.end,
                            trailingIcon: Icon(
                              Icons.arrow_forward_ios,
                              color: AppColors.primary,
                              size: 18,
                            ),
                            onPressed: () {
                              showUserDetails(user);
                            },
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
