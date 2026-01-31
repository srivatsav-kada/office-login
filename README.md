# 📍 Geo-Fenced Team Attendance Management System

Geo-Fenced Team Attendance Management System is a **Flutter + Firebase based mobile application** that enables **location-restricted attendance tracking** using **geofencing and real-time employee login/logout monitoring**.  
It ensures accurate attendance by allowing employees to mark attendance only when they are **within the allowed office/worksite location range**.

This system also provides a manager/admin module for tracking, reviewing, and generating team-wise attendance reports with better visibility and control.

---

## 📌 Project Overview

Traditional attendance systems can be misused when employees mark attendance remotely without being physically present.  
This project solves that issue using **Geofencing + Real-Time Tracking**, helping organizations maintain accurate location-based attendance records.

Using this application, employees can:

✅ Login/Logout for attendance  
✅ Mark attendance only within an allowed geofence radius  
✅ Get real-time attendance status updates  
✅ View their attendance history  

Managers/Admins can:

✅ Monitor attendance records  
✅ View reports team-wise  
✅ Track login/logout time and location accuracy  
✅ Manage employee attendance patterns efficiently  

---

## 🚀 Key Features

✅ Geo-Fenced Attendance Tracking (Location restricted)  
✅ Real-time Login/Logout Attendance Updates  
✅ Geolocation Validation (only inside allowed area)  
✅ Firebase Firestore Integration (live data sync)  
✅ Admin Dashboard for Managers  
✅ Team-wise Attendance Reporting  
✅ Attendance History View for Employees  
✅ State Management for centralized data control  
✅ Unit Testing for reliability and code quality  

---

## 🧰 Tech Stack

- Flutter
- Dart
- Firebase Firestore
- Firebase Authentication (optional)
- Firebase Cloud Functions (optional)
- Google Maps / Geolocation APIs (based on implementation)
- Geofencing (Location-based attendance validation)
- State Management (Provider / Riverpod / Bloc - based on your implementation)
- Unit Testing (Flutter test)

---

## ⚙️ Setup & Run the Project

✅ Step 1: Clone the Repository

git clone https://github.com/srivatsav-kada/<your-repo-name>.git
cd <your-repo-name>

✅ Step 2: Install Dependencies

flutter pub get

✅ Step 3: Run the App

flutter run

---

## 🔥 Firebase Setup (Required)

✅ Step 1: Create a Firebase Project  
✅ Step 2: Enable Firestore Database  
✅ Step 3: Add Firebase App (Android / iOS)  
✅ Step 4: Download and place config files:

For Android:
android/app/google-services.json

For iOS:
ios/Runner/GoogleService-Info.plist

✅ Step 5: Enable required Firebase services (if used):
- Firestore Database
- Authentication (optional)

---

## 📍 Geofencing Setup (How it Works)

✅ Admin defines office/worksite location (latitude + longitude)  
✅ A radius is set for allowed attendance zone (example: 100m / 200m)  
✅ Employee can mark login/logout ONLY when inside that zone  
✅ Attendance is stored in Firestore with timestamp + location status

---

## 👨‍💼 Admin Dashboard Features

✅ View all employee attendance entries  
✅ Filter attendance by date / team  
✅ Track login/logout timings  
✅ Generate team-wise attendance reports  
✅ Identify attendance trends and patterns

---

## 📸 Screenshots (Optional)

📌 Add screenshots inside:

/screenshots

Suggested screenshots:
✅ Employee Login Screen  
✅ Attendance Marking Screen  
✅ Location Status (Inside/Outside Geofence)  
✅ Attendance History Screen  
✅ Admin Dashboard Screen  
✅ Team-wise Report Screen  

---

## 🛣️ Future Enhancements

✅ Face verification for attendance  
✅ Live map view for manager tracking  
✅ Automated report export (PDF/Excel)  
✅ Push notifications (reminders for login/logout)  
✅ Offline attendance caching + sync  
✅ Multi-location geofence support  

---

## 👨‍💻 Author

Sri Vatsav  
Flutter Developer | Firebase | Mobile Applications  

📌 GitHub: https://github.com/srivatsav-kada

⭐ If you like this project, consider giving it a star!
