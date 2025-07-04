# universal_exam

Goal:

- Build a Flutter Web exam application tailored for Syrian academic use cases, prioritizing being fast in coding over best practices.

Status:
Frontend: Complete.
Firestore integration: Connected.
teacher: Complete, questions.
student: Complete, nned to impement taking exams.
admin: Complete, needs to implement creating exams from questions.
UserProvider: complete, AppProvider(loads exams and topTeachers/topStudents).
no state management by design
Impotant point to always put in mind when working with code:

- we're trying to finish this full app as fast as possible, so the names of the models and datafiles are like the document names. all code only uses real data that exists in Firestore If something doesn’t exist (like an events map), we don't use it
- only one comment in the first line of the file to explain shortly stuffs like (receives x, sends x)

Firestore Structure:
users (Collection)
{uid} (Document)
firstName: string
lastName: string
fatherName: string
motherName: string
email: string
dateOfBirth: string (YYYY-MM-DD)
role: string ("طالب" | "أستاذ" | "مدير")
specialty: string ( "الطب البشري" | "طب الأسنان" | "الصيدلة" | "الهندسة المعلوماتية")
photoBase64: string
verified: boolean
createdAt: timestamp

questions (Collection)
{questionId} (Document)
text: string
specialty: string ( "الطب البشري" | "طب الأسنان" | "الصيدلة" | "الهندسة المعلوماتية")
createdBy: string (uid)
createdAt: timestamp
type: string ("MCQ" | "true_false" )
options: array of string (MCQ only)
correctAnswer: string
disabled: boolean
imageBase64: string (optional)

exams (Collection) // only those never add more
{examId} (Document)
title: string
specialty: string ( "الطب البشري" | "طب الأسنان" | "الصيدلة" | "الهندسة المعلوماتية")
date: timestamp
duration: number (minutes)
createdAt: timestamp
questionIds: array of string (encrypted until 10 minutes before exam starts)
isActive: boolean
questionsPerStudent: number

examAttempts (Collection)
{attemptId} (Document)
examId: string
studentId: string (uid)
startedAt: timestamp
submittedAt: timestamp
status: string ("in_progress" | "submitted" | "graded")
answers: map { questionId: studentAnswer }
correctAnswers: map { questionId: correctAnswer }
score: number

topStudents
{topStudentsId} (Document)
studentId: string (uid)
averageScore: number
updatedAt: timestamp

topTeachers
{topTeachersId} (Document)
teacherId: string (uid)
avgStudentScore: number
totalQuestions: number
updatedAt: timestamp

personal points about me, I don't like long responses unless it was code!
I know you understood the point, and got a plan how to work ahead, please make your main role as code writer with short replies + full code if necessary! Thanks!
never generate images

file structure:
| main.dart
│ splash_screen.dart
│  
├───core
│ │ app_service.dart
│ │ encryption.dart
│ │
│ ├───config
│ │ firebase_options.dart
│ │
│ ├───models
│ │ exam_attempt_model.dart
│ │ exam_model.dart
│ │ question_model.dart
│ │ top_student_model.dart
│ │ top_teacher_model.dart
│ │ user_info_model.dart
│ │ user_model.dart
│ │
│ └───providers
│ app_provider.dart
│ user_provider.dart
│
├───features
│ ├───admin
│ │ ├───controllers
│ │ │ admin_controller.dart
│ │ │
│ │ └───screens
│ │ admin_screen.dart
│ │ logs_screen.dart
│ │ manage_exams_screen.dart
│ │ manage_users_screen.dart
│ │ verify_students_screen.dart
│ │ verify_teachers_screen.dart
│ │ view_statistics_screen.dart
│ │
│ ├───auth
│ │ │ auth_service.dart
│ │ │
│ │ ├───screens
│ │ │ login_screen.dart
│ │ │ sign_up_screen.dart
│ │ │
│ │ └───utils
│ │ login_validator.dart
│ │ sign_up_vaildator.dart
│ │
│ ├───exam
│ │ │ exam_service.dart
│ │ │
│ │ ├───data
│ │ │ colors.dart
│ │ │
│ │ └───screens
│ │ exam_screen.dart
│ │
│ ├───home
│ │ home_screen.dart
│ │
│ ├───student
│ │ │ student_screen.dart
│ │ │
│ │ └───screens
│ │ exams_screen.dart
│ │ help_support_screen.dart
│ │ notifications_screen.dart
│ │ personal_info_screen.dart
│ │ results_screen.dart
│ │ settings_screen.dart
│ │
│ └───teacher
│ ├───controllers
│ │ teacher_controller.dart
│ │
│ └───screens
│ create_question_screen.dart
│ edit_question_screen.dart
│ manage_question_screen.dart
│ stats_screen.dart
│ teacher_screen.dart
│
└───shared
├───theme
│ colors.dart
│ color_animation.dart
│ theme.dart
│
└───widgets
app_bar.dart
bottom_sheet.dart
button.dart
calendar.dart
card.dart
constrained_box.dart
container.dart
dropdown_list.dart
exam_question.dart
list_item.dart
show_dialog.dart

don't do anything yet <3
