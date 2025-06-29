# universal_exam

**Goal:** Speedrun fastest Flutter web universal exam app (Syrian).

**Status:** Front almost done, Firestore connected, basic backend (login, timer background color) functional but "super bad" (0 State Management).

**Deviations:** Worst practices for speed, minimal state management, no standard assets. Exam page has "evil" time-based gradient background. Web navigation exists.

**Firestore Structure:**

Firestore database in the program is:
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
    specialty: string
    createdBy: string (uid)
    createdAt: timestamp
    type: string ("MCQ" | "true_false" )
    options: array of string (MCQ only)
    correctAnswer: string or array
    disabled: boolean
    imageBase64: string (optional)

exams (Collection)
{examId} (Document)
    title: string 
    specialty: string
    date: timestamp
    duration: number (minutes)
    createdBy: string (uid)
    createdAt: timestamp
    questionIds: array of string
    questionWeights: map { questionId: weight }
    isActive: boolean
    randomizeQuestions: boolean
    questionsPerStudent: number 
    notes: string (اختياري)

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
    events: array of {
        timestamp: timestamp,
        type: string,
        by: string (uid or "system")
    } 

topStudents
{specialty} (Document)
    studentId: string (uid)
    fullName: string
    photoBase64: string
    averageScore: number
    updatedAt: timestamp

topTeachers
{specialty} (Document)
    teacherId: string (uid)
    fullName: string
    photoBase64: string
    avgStudentScore: number
    totalQuestions: number
    updatedAt: timestamp
