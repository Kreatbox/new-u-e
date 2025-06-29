# universal_exam
the goal: speedrun the fastest way to complete a flutter web project
it's for a universal exam 
(a Syrian exam after finish uni about everything you took in your uni (IT, medical doctor, etc))
so far I'm almost done with the front, made the connection to firestore
and made some functionable backend and tools,
login, a system to change color of background depending on time left in test
it was meant to be working in the right way, but no, it's super bad.
why? 0 State Management Strategy, which means just throw a stateful and say "f#ck it" not necessary services.dart, because our goal is to speedrun
Navigation and Routing for Web yeah it's there in the main file, we will add the teacher pages and its done
Data Models and Serialization, sadly our goal is to make it functionable not perfect, we aren't just ignoring best practices, we are doing worst practices... the color.dart in the exam page it's just a gradient colors array to change the color of background during exam to remind the user that the time is running low... it's just an evil thing lol
Asset Management? what is assets? imagine using assets!

Firestore database in the program is:
users (Collection)
├── {uid} (Document)
    ├── firstName: string
    ├── lastName: string
    ├── fatherName: string
    ├── motherName: string
    ├── email: string
    ├── dateOfBirth: string (YYYY-MM-DD)
    ├── role: string ("طالب" | "أستاذ" | "مدير")
    ├── specialty: string ( "الطب البشري" | "طب الأسنان" | "الصيدلة" | "الهندسة المعلوماتية")
    ├── photoBase64: string
    ├── verified: boolean
    └── createdAt: timestamp

questions (Collection)
├── {questionId} (Document)
    ├── text: string
    ├── specialty: string
    ├── createdBy: string (uid)
    ├── createdAt: timestamp
    ├── type: string ("MCQ" | "true_false" )
    ├── options: array of string (MCQ فقط)
    ├── correctAnswer: string or array
    ├── disabled: boolean
    └── imageBase64: string (اختياري)

exams (Collection)
├── {examId} (Document)
    ├── title: string
    ├── specialty: string
    ├── date: timestamp
    ├── duration: number (minutes)
    ├── createdBy: string (uid)
    ├── createdAt: timestamp
    ├── questionIds: array of string
    ├── questionWeights: map { questionId: weight }
    ├── isActive: boolean
    ├── randomizeQuestions: boolean
    ├── questionsPerStudent: number
    └── notes: string (اختياري)

examAttempts (Collection)
├── {attemptId} (Document)
    ├── examId: string
    ├── studentId: string (uid)
    ├── startedAt: timestamp
    ├── submittedAt: timestamp
    ├── status: string ("in_progress" | "submitted" | "graded")
    ├── answers: map { questionId: studentAnswer }
    ├── correctAnswers: map { questionId: correctAnswer } 
    ├── score: number
    ├── events: array of {
        timestamp: timestamp,
        type: string,
        by: string (uid or "system")
    }

topStudents
├── {specialty} (Document)
    ├── studentId: string (uid)
    ├── fullName: string
    ├── photoBase64: string
    ├── averageScore: number
    ├── updatedAt: timestamp

topTeachers
├── {specialty} (Document)
    ├── teacherId: string (uid)
    ├── fullName: string
    ├── photoBase64: string
    ├── avgStudentScore: number (معدل علامات الطلاب في امتحاناته)
    ├── totalQuestions: number
    ├── updatedAt: timestamp
