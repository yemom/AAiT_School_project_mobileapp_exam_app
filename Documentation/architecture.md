# Architecture Overview

This document describes the system architecture of the **AAiT School Exam Mobile App**, covering the overall design, modules, data flow, backend structure, and state management.

---

## 1. **System Architecture Summary**

The project follows a **Client–Server Architecture**:

* **Mobile App (Flutter)** – Handles UI, user actions, exam participation, authentication, and communication with backend.
* **Backend (Node.js + Express)** – Provides REST APIs for user management, exam creation, question handling, exam submission, and result processing.
* **Database (MongoDB)** – Stores users, exams, questions, submissions, and results.

---

## 2. **Frontend Architecture (Flutter)**

### **2.1 Project Structure (from repo)**

```
lib/
 ├── controller/
 ├── api_service/
 ├── models/
 ├── screens/
 ├── widgets/
 └── main.dart
```

### **2.2 Explanation**

* **controller/** → Contains logic classes controlling data flow between API and UI.
* **api_service/** → Contains API calling logic using `http` package.
* **models/** → Data models like User, Exam, Question.
* **screens/** → Each screen/page (login, register, dashboard, exam, results…).
* **widgets/** → UI components that can be reused.

### **2.3 State Management**

The project **does NOT use Provider or GetX**.
It uses **manual state management** using:

* `setState()`
* Passing data through constructors
* Calling controllers directly

This is simple but not scalable.

---

## 3. **Backend Architecture (Node.js + Express)**

### **3.1 Folder Structure**

```
Backend/
 ├── models/
 ├── routes/
 ├── controllers/
 ├── config/
 └── index.js
```

### **3.2 Explanation**

* **models/** → MongoDB schemas for User, Exam, Questions, Results.
* **routes/** → API endpoints definitions.
* **controllers/** → Handles main logic for CRUD and authentication.
* **config/** → Database connection and environment variables.

---

## 4. **Database Architecture (MongoDB)**

### **Collections**

* **users** → stores student data
* **exams** → stores exam metadata
* **questions** → stores exam questions and answer keys
* **results** → stores exam scores and submissions

### **Example Schema**

```json
{
  "user": {
    "name": "string",
    "email": "string",
    "password": "hashed"
  },
  "exam": {
    "title": "string",
    "department": "string",
    "questions": ["questionId1", "questionId2"]
  }
}
```

---

## 5. **Data Flow Architecture**

### **5.1 User Login Flow**

1. User enters email + password.
2. Flutter sends POST → `/login`.
3. Backend verifies user.
4. Backend returns token + user data.
5. App stores session and redirects to dashboard.

### **5.2 Exam Taking Flow**

1. Student selects exam.
2. App fetches questions from backend.
3. Student answers.
4. Answers submitted to backend.
5. Backend auto-grades and stores result.

### **5.3 Result Flow**

1. Backend calculates score.
2. User requests results.
3. App displays marks.

---

## 6. **API Architecture**

### **Main API Categories**

* **Auth APIs** (login, register)
* **Exam APIs** (create, list, get exam)
* **Question APIs** (add question, list questions)
* **Submission APIs** (submit answers)
* **Result APIs** (get results)

---

## 7. **Security Architecture**

* **Password hashing** with bcrypt.
* **JWT Authentication** for secure API access.
* **Role handling** (Admin vs Student) – Admin creates exams.

---

## 8. **Key Architectural Strengths**

* Clean separation between backend and frontend
* Good folder structure
* REST API-based
* Scalable database design

---

## 9. **Architectural Weaknesses**

* No persistent state management (Provider/GetX missing)
* No error handling on network failures
* No caching strategy
* Some hardcoded values in API calls

---

## 10. **Suggested Improvements**

### **Frontend**

* Switch to **GetX** or **Riverpod**
* Add proper **loading + error UI states**
* Add repository layer

### **Backend**

* Add validation using Joi or Zod
* Add pagination for exam listing
* Improve error handling

### **DevOps**

* Add environment variables in `.env`
* Add CI/CD (GitHub Actions)

---

## Final Note

This architecture.md provides a complete technical explanation of how your AAiT School Exam App works: frontend, backend, state, APIs, and database.

If you want **system diagram images**, **UML diagrams**, or **README.md**, tell me ✨
