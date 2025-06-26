import 'package:flutter/material.dart';
import '../../../shared/theme/colors.dart';
import '../../../shared/widgets/bottom_sheet.dart';
import '../../../shared/widgets/button.dart';
import '../../../shared/widgets/container.dart';
import 'package:file_picker/file_picker.dart';
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
  String? _attachmentName;
  double _uploadProgress = 0.0;
  bool _isUploading = false;

  Future<void> _pickAttachment() async {
    setState(() {
      _isUploading = true;
    });

    final result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.single.size <= 5 * 1024 * 1024) {
      for (int i = 0; i <= 100; i++) {
        await Future.delayed(Duration(milliseconds: 50));
        setState(() {
          _uploadProgress = i / 100.0;
        });
      }

      setState(() {
        _attachmentName = result.files.single.name;
        _isUploading = false;
      });
    } else {
      showError("الملف كبير جدًا، يجب أن يكون الحجم أقل من 5 ميغا بايت.");
      setState(() {
        _isUploading = false;
      });
    }
  }

  void showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
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
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CustomButton(
                          onPressed: _pickAttachment,
                          child: Text("إرفاق ملف"),
                        ),
                        Text(
                          _attachmentName ?? "لا يوجد ملف مرفق",
                          style: TextStyle(color: Colors.grey),
                        ),
                        if (_isUploading)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20.0),
                            child: LinearProgressIndicator(
                              value: _uploadProgress,
                            ),
                          ),
                        if (_attachmentName != null)
                          Text("تم اختيار الملف: $_attachmentName"),
                      ],
                    ),
                    const SizedBox(height: 10),
                    CustomButton(
                      onPressed: () {
                        String title = _titleController.text;
                        String message = _messageController.text;
                        if (title.isNotEmpty && message.isNotEmpty) {
                          print(
                              'إرسال الاستفسار: العنوان: $title، النص: $message');
                          Navigator.pop(context);
                        } else {
                          showError("يرجى ملء جميع الحقول");
                        }
                      },
                      child: Text("إرسال"),
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
