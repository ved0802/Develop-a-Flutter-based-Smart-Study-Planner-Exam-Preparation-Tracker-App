# StudyMate — Smart Study Planner & Exam Preparation Tracker

**Developer:** Vansh (D24IT176)  
**Project:** Academic Final Practical Exam  
**Framework:** Flutter (Latest Stable)  
**Storage:** Hive (Offline-First)

---

## 1. Description of Implemented Modules

### A. Subject & Topic Management Module
This module allows students to organize their curriculum structure with specific data points:
- **Subject Entry:** Students can add subjects by providing a **Subject Name**.
- **Topic Entry:** Under each subject, topics can be added with:
    - **Topic Name**
    - **Estimated Study Time** (in minutes)
- **Management:** Users can edit or delete subjects and topics as their syllabus evolves.

### B. Study Scheduling Module
The scheduling module enables precise planning for exam preparation:
- **Session Details:** When scheduling a study session, the following fields are captured:
    - **Subject Selection**
    - **Topic Selection**
    - **Date & Time Picker**
    - **Duration** (minutes)
- **Organization:** Sessions are automatically grouped by date for clear daily visibility.

### C. Progress Tracking Module
This module provides granular control over preparation status:
- **Topic Status:** Every topic can be transitioned through three distinct states:
    - **Not Started** (Default)
    - **In Progress** (Active study)
    - **Completed** (Finalized)
- **Analytics:** The system automatically calculates and displays the **Percentage Completion per Subject**, helping students identify finished vs. pending work.

### D. Study Dashboard
The central hub for real-time study analytics and visualization:
- **Key Metrics:** Displays live counters for:
    - **Total Subjects** enrolled.
    - **Completed Topics** count.
    - **Pending Topics** remaining.
    - **Daily Study Progress** (total minutes studied today).
- **Visual Indicators:** Uses **Progress Bars** for subject-wise completion and a **Bar Chart** for weekly study activity.

### E. Search & Filter Module
An advanced utility for navigating complex study materials:
- **Search Capability:** Users can **Search topics by name** using a real-time search bar.
- **Multi-Filter System:** Students can narrow down lists by:
    - **Subject**
    - **Status** (Completed / Pending / In Progress)
    - **Date** (Shows topics scheduled for specific days)

### F. Offline Functionality & Sync
- **Local Storage:** The app uses **Hive** to allow scheduling and tracking without an internet connection.
- **Sync Visualization:** A "Synced" indicator provides visual confirmation that local data is ready and consistent, satisfying the offline-first requirement.

### G. Validation & Error Handling
- **Schedule Integrity:** The app **prevents invalid schedules** by checking against past dates and times.
- **Required Fields:** All input forms validate that required fields (Name, Time, Duration) are provided before saving.
- **User Alerts:** Meaningful **SnackBars and Dialogs** provide instant feedback on errors or successful operations.

---

## 2. Explanation of Progress Tracking & Priority Logic

### Progress Tracking Logic
The application calculates completion rates at two levels:
1. **Subject Level:** `(Completed Topics in Subject) / (Total Topics in Subject)`
2. **Global Level:** `(Total Completed Topics) / (Total Topics in App)`

### Priority & Planning Logic
The system includes an intelligent `PriorityEngine`:
- **Highlighting:** It automatically highlights **Subjects with the lowest completion** rates.
- **Next Topic Suggestions:** Based on subject urgency, it suggests the next 5 topics to study, prioritizing subjects that need the most attention and topics already "In Progress".

---

## 3. Future Scope
1. **OCR Scanning:** Automated topic entry from syllabus images.
2. **Gamification:** Study streaks and achievement badges.
3. **Pomodoro Timer:** Built-in focus timer for sessions.
4. **Cloud Integration:** Full Firebase Realtime Database sync for multi-device support.

---

## 4. Conclusion
**StudyMate** (D24IT176) is a comprehensive solution that meets all specified requirements for subject management, scheduling, and progress tracking. By combining **Material 3** aesthetics with **offline-first persistence**, it provides a premium user experience tailored for academic success.

---

## UI Screenshots
1. **Dashboard:** [Capture Dashboard Screen]
2. **Subjects:** [Capture Subject Management Screen]
3. **Schedule:** [Capture Study Scheduling Screen]
4. **Progress:** [Capture Study Progress Screen]
5. **Search:** [Capture Search & Filter Screen]
