# 👋 Hey there, I'm የ፟-mom (Esrom)
- 🔭 I’m currently working on Flutter cross-platform apps
- 🌱 I’m learning Firebase, Clean Architecture, AI
- 💬 Ask me about Dart, Git, or how to survive merge conflicts 😅
- 📫 Reach me: [Gmail](mailto:12yemom@gmail.com) | [LinkedIn](https://www.linkedin.com/in/esrom-basazinew-65102a339)


This is a comprehensive Exam Management Mobile Application built with Flutter, powered by Firebase as its backend-as-a-service. The application is designed to facilitate online exams with distinct functionalities for both users and administrators.

## Key Features:

*   **User Authentication and Authorization:**
    *   Secure **Login** and **Signup** functionalities using Firebase Authentication.
    *   Supports **role-based access**, allowing users to register and be designated as either 'User' or 'Admin'.
    *   Users are directed to different home screens and features based on their assigned role.

*   **User Features:**
    *   **Category Browsing:** Users can view and explore various exam categories available in the application.
    *   **Search and Filter:** Easily find specific exam categories using search and filtering options.
    *   **Exam Listing:** View a list of exams within a selected category, including details like the number of questions and time limit.
    *   **Timed Exams:** Take exams with a predefined time limit. The application tracks time and automatically completes the exam when the time is up.
    *   **Interactive Question Interface:** Answer multiple-choice questions within the app.
    *   **Exam Results and Analysis:** Upon completion, users receive their score, along with performance feedback and a detailed breakdown of each question, showing their answer and the correct answer.

*   **Administrator Features:**
    *   **Admin Dashboard:** Get an overview of the application's content, including the total number of categories, total exams, category-wise exam statistics, and recent exam additions.
    *   **Manage Categories:** Full control over exam categories, including:
        *   Viewing existing categories.
        *   Adding new categories (name and description).
        *   Editing details of existing categories.
        *   Deleting categories.
    *   **Manage Exams:** Comprehensive management of exams, including:
        *   Viewing a list of exams, filterable by category.
        *   Searching for exams by title.
        *   Adding new exams, specifying title, category, time limit, and adding multiple questions.
        *   Editing existing exams, including modifying questions and options.
        *   Deleting exams.
    *   **Question and Option Management:** Within the exam creation/editing interface, administrators can add, edit, and remove individual questions, define multiple-choice options for each question, and mark the correct answer.

## Technology Stack:

*   **Frontend:** Flutter (Dart)
*   **Backend:** Firebase
    *   Firebase Authentication for user management.
    *   Cloud Firestore for storing application data (categories, exams, questions, user data).

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
