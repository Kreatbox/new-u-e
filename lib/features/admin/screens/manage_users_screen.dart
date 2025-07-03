import 'package:flutter/material.dart';
import '../controllers/admin_controller.dart';
import '../../../core/models/user_model.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/list_item.dart';

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

    try {
      users = await widget.controller.fetchAllUsers();
      filteredUsers = [...users];
    } catch (e) {
      print("Failed to load users: $e");
    }

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
            user.lastName.contains(query) ||
            user.email.contains(query) ||
            user.specialty.contains(query);
        return matchesUserType && matchesSearch;
      }).toList();
    });
  }

  void showUserDetails(User user) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return CustomContainer(
          gradientColors: widget.gradientColors,
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${user.firstName} ${user.lastName}',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text('البريد الإلكتروني: ${user.email}'),
              Text('الدور: ${user.role}'),
              Text('التخصص: ${user.specialty}'),
              Text('مُحقق؟ ${user.verified ? 'نعم' : 'لا'}'),
              Text(
                  'تاريخ الإنشاء: ${user.createdAt?.toString().substring(0, 10)}'),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: Navigator.of(context).pop,
                child: Text('إغلاق'),
              )
            ],
          ),
        );
      },
    );
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                  items: ['all', 'طالب', 'أستاذ', 'مدير']
                      .map<DropdownMenuItem<String>>((value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'all'
                            ? 'جميع الأدوار'
                            : value == 'طالب'
                                ? 'طلاب'
                                : value == 'أستاذ'
                                    ? 'أساتذة'
                                    : 'مدراء',
                      ),
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
                            additionalTitles: ['الدور', 'التخصص'],
                            additionalDescriptions: [user.role, user.specialty],
                            gradientColors: widget.gradientColors,
                            begin: widget.begin,
                            end: widget.end,
                            trailingIcon: user.verified
                                ? Icon(Icons.check_circle, color: Colors.green)
                                : Icon(Icons.cancel, color: Colors.red),
                            onPressed: () => showUserDetails(user),
                          );
                        }),
          ),
        ],
      ),
    );
  }
}
