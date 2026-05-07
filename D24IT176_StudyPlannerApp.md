# StudyMate — Smart Study Planner & Exam Preparation Tracker

**Developer:** Vansh (D24IT176)  
**Project:** Academic Final Practical Exam  
**Framework:** Flutter (Latest Stable)  
**Storage:** Hive (Offline-First)

---

## 1. Description of Implemented Modules

### A. Subject & Topic Management Module
This module allows students to organize their curriculum. 
- **Subjects:** Users can add multiple subjects (e.g., Mathematics, Physics).
- **Topics:** Each subject can have multiple topics, each with an estimated study time (in minutes).
- **Features:** Supports adding, editing, and deleting subjects and topics.

### B. Study Scheduling Module
The scheduling module helps students allocate time to specific topics.
- **Session Planning:** Users can select a subject and topic, choose a date and time, and set the duration.
- **Grouped View:** Scheduled sessions are grouped by date for easy daily planning.
- **Completion Tracking:** Sessions can be marked as completed directly from the schedule list.

### C. Progress Tracking Module
This module provides a deep dive into the student's preparation status.
- **Status Lifecycle:** Topics move through "Not Started", "In Progress", and "Completed".
- **Subject Analytics:** Shows percentage completion for each subject with mini-stats (Done/Pending).
- **Overall Progress:** A circular indicator displays total curriculum completion.

### D. Study Dashboard
The command center of the application.
- **Greeting & Summary:** Personalized greeting with overall progress summary.
- **Metric Cards:** Real-time counters for total subjects, completed topics, pending topics, and today's study time.
- **Activity Chart:** A bar chart visualizing study minutes over the last 7 days.
- **Today's Focus:** A quick-access list of sessions scheduled for the current day.

### E. Search & Filter Module
Allows quick navigation through large syllabi.
- **Real-time Search:** Search for topics by name across all subjects.
- **Advanced Filtering:** Filter topics by Subject or by Status (e.g., see all "In Progress" topics).

---

## 2. Explanation of Progress Tracking & Priority Logic

### Progress Tracking Logic
The application calculates completion rates at two levels:
1. **Subject Level:** `(Completed Topics in Subject) / (Total Topics in Subject)`
2. **Global Level:** `(Total Completed Topics) / (Total Topics in App)`

Each topic has a three-state status integer:
- `0 (Not Started)`
- `1 (In Progress)`
- `2 (Completed)`

### Priority Logic (PriorityEngine)
The `PriorityEngine` suggests which topics the student should study next based on a "Lowest Completion First" strategy:
1. **Subject Urgency:** It identifies subjects with the lowest completion percentage.
2. **Topic Readiness:** Within those subjects, it prioritizes "In Progress" topics over "Not Started" ones to encourage finishing started work.
3. **Suggestion List:** The Dashboard and Progress screens display the top 5 suggested topics derived from this logic.

---

## 3. Future Scope

1. **OCR Receipt/Syllabus Scanning:** Use AI to scan printed syllabus documents and automatically populate subjects and topics.
2. **Gamification:** Add study streaks, badges, and level-ups to motivate students.
3. **Pomodoro Timer Integration:** A built-in timer for study sessions with automatic session logging.
4. **Cloud Sync & Collaboration:** Real-time data sync across devices and ability to share study plans with classmates.
5. **PDF Export:** Export study schedules and progress reports as professional PDFs.
6. **Smart Notifications:** Reminders for upcoming study sessions and motivational nudges.

---

## 4. Conclusion

**StudyMate** successfully demonstrates a robust, offline-first solution for student organization. By leveraging **Flutter** for a high-performance cross-platform UI and **Hive** for efficient local storage, the application ensures that students can plan their studies anytime, anywhere. The modular architecture (MVVM with Provider) ensures maintainability, while the custom `PriorityEngine` provides intelligent insights that go beyond simple data entry, helping students focus on areas that need the most attention.

---

## UI Screenshots

*Note: Please run the application in your browser and capture screenshots to replace the placeholders below.*

1. **Dashboard:** [Capture Dashboard Screen]
2. **Subjects:** [Capture Subject Management Screen]
3. **Schedule:** [Capture Study Scheduling Screen]
4. **Progress:** [Capture Study Progress Screen]
5. **Search:** [Capture Search & Filter Screen]
