import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/app_provider.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import '../../../shared/widgets/list_item.dart';

class HelpSupportScreen extends StatefulWidget {
  final List<Color> gradientColors;
  final Alignment begin;
  final Alignment end;

  const HelpSupportScreen({
    super.key,
    required this.gradientColors,
    required this.begin,
    required this.end,
  });

  @override
  State<HelpSupportScreen> createState() => _HelpSupportScreenState();
}

class _HelpSupportScreenState extends State<HelpSupportScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _messageController = TextEditingController();
  bool _isSubmitting = false;

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void showSuccess(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(
          content: Text(message),
          backgroundColor: Colors.green,
        ));
  }

  Future<void> _submitContactRequest() async {
    if (_titleController.text.isEmpty || _messageController.text.isEmpty) {
      showError("يرجى ملء جميع الحقول");
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final user = Provider.of<AppProvider>(context, listen: false).user;
      final currentUser = FirebaseAuth.instance.currentUser;
      
      if (user == null || currentUser == null) {
        showError("حدث خطأ في جلب بيانات المستخدم");
        return;
      }

      await FirebaseFirestore.instance.collection('contactRequests').add({
        'userId': currentUser.uid,
        'userRole': user.role,
        'userName': '${user.firstName} ${user.lastName}',
        'userEmail': user.email,
        'title': _titleController.text,
        'message': _messageController.text,
        'status': 'pending',
        'createdAt': Timestamp.now(),
        'specialty': user.specialty,
        'isRead': false,
      });

      _titleController.clear();
      _messageController.clear();
      
      showSuccess("تم إرسال طلبك بنجاح");
      Navigator.pop(context);
    } catch (e) {
      showError("فشل في إرسال الطلب: $e");
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  void _showHelpDetails(String title, String description, {Widget? child}) {
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
            "المساعدة والدعم",
            style: TextStyle(
              fontSize: 32,
              color: AppColors.primary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 32),
          GestureDetector(
            onTap: () {
              _showHelpDetails(
                "الأسئلة الشائعة",
                "تحتوي هذه الشاشة على قائمة بالأسئلة الأكثر شيوعًا وإجاباتها لتسهيل استخدام النظام.",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "1. كيف أبدأ في استخدام النظام؟",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "للبدء في استخدام النظام، يجب أولاً إنشاء حساب مستخدم. بعد التسجيل، يمكنك التواصل لتوثيق حسابك ثم تقوم تسجيل الدخول والبدء في استخدام الميزات المختلفة.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "2. هل يمكنني استرجاع كلمة المرور؟",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "نعم، يمكنك استرجاع كلمة المرور عن طريق الضغط على خيار 'نسيت كلمة المرور' في شاشة تسجيل الدخول واتباع التعليمات.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                    SizedBox(height: 12),
                    Text(
                      "3. كيف أقدم طلبًا للدعم؟",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "لتقديم طلب للدعم، يمكنك الذهاب إلى قسم 'تواصل مع الإدارة' وملء النموذج مع تفاصيل مشكلتك أو استفسارك.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: CustomListItem(
              title: "الأسئلة الشائعة",
              description: "دليل لاستخدام النظام",
              gradientColors: widget.gradientColors,
              begin: widget.begin,
              end: widget.end,
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showHelpDetails(
                "تواصل مع الإدارة",
                "يمكنك استخدام هذه الميزة لإرسال استفسارات أو مشاكل مباشرة إلى إدارة النظام.",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: "عنوان الرسالة",
                        hintText: "أدخل عنوان الرسالة",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _messageController,
                      maxLines: 5,
                      decoration: InputDecoration(
                        labelText: "نص الرسالة",
                        hintText: "أدخل نص الرسالة",
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: CustomButton(
                        onPressed: _isSubmitting ? null : _submitContactRequest,
                        child: _isSubmitting
                            ? Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SizedBox(
                                    width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 8),
                                  Text("جاري الإرسال..."),
                                ],
                              )
                            : Text("إرسال الطلب"),
                      ),
                    ),
                  ],
                ),
              );
            },
            child: CustomListItem(
              title: "تواصل مع الإدارة",
              description: "إرسال استفسار أو مشكلة",
              gradientColors: widget.gradientColors,
              begin: widget.begin,
              end: widget.end,
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
          GestureDetector(
            onTap: () {
              _showHelpDetails(
                "تعليمات دخول الامتحان",
                "للدخول إلى الامتحان الوطني الموحد، يجب على الطلاب التأكد من الآتي:\n"
                    "-  الوصول إلى قاعة الامتحان قبل موعد الامتحان بـ 15 دقيقة.\n"
                    "-  إحضار بطاقة الهوية الوطنية أو الجامعية.\n"
                    "-  التأكد من اصطحاب الأدوات المطلوبة مثل الأقلام وآلة حاسبة (إن لزم).\n"
                    "-  الامتناع عن استخدام الأجهزة الإلكترونية داخل قاعة الامتحان.\n"
                    "-  الالتزام بالتعليمات الصادرة من المشرفين داخل القاعة.",
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      "ملحوظة:",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      "-  في حال وجود مشكلة، يجب التواصل مع الإدارة قبل موعد الامتحان.\n"
                      "-  الالتزام بالهدوء والانضباط يساهم في سير الامتحان بسلاسة.",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              );
            },
            child: CustomListItem(
              title: "تعليمات دخول الامتحان",
              description: "معلومات وإرشادات حول شروط الامتحانات.",
              gradientColors: widget.gradientColors,
              begin: widget.begin,
              end: widget.end,
              trailingIcon: Icon(
                Icons.arrow_forward_ios,
                color: AppColors.primary,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
