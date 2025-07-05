# universal_exam

Goal:

- Build a Flutter Web exam application tailored for Syrian academic use cases, prioritizing being fast in coding over best practices.

Status:
Frontend: Complete.
Firestore integration: Connected.
teacher: Complete.
student: Complete,
admin: Complete.
exams: Complete.
UserProvider + AppProvider issue, weirdly our issue is with login...
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
calculated: boolean //false until exam is over and graded
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

don't do anything yet <3
