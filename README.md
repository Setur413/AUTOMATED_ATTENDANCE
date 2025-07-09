# QR Attendance App

A Flutter-based mobile application for automating classroom attendance using QR codes. This app allows instructors to generate QR codes and students to scan them for quick and secure attendance logging. Firebase is used for authentication, data storage, and cloud functions, enabling real-time attendance tracking and management.

---

##  Features

-  Firebase Authentication for secure login/signup
-  QR code generation and scanning
-  Integrated calendar using `table_calendar` for attendance tracking
-  Cloud Firestore for storing attendance data
-  Image upload support via `image_picker` and Firebase Storage
-  Export attendance data as CSV
- Share attendance reports with `share_plus`
-  Local storage using `shared_preferences`

---

##  Tech Stack

**Frontend**:  
- Flutter & Dart  
- `qr_flutter`, `mobile_scanner`, `table_calendar` for UI and functionality  

**Backend**:  
- Firebase Authentication  
- Cloud Firestore  
- Firebase Storage  

**Others**:  
- `csv` for export  
- `path_provider` for file handling  
- `shared_preferences` for local session storage  

---

##  Dependencies

Main packages used (see `pubspec.yaml` for full list):

```yaml
firebase_core: ^2.32.0
firebase_auth: ^4.17.3
cloud_firestore: ^4.17.5
firebase_storage: ^11.6.6
qr_flutter: ^4.1.0
mobile_scanner: ^6.0.7
table_calendar: ^3.0.9
image_picker: ^1.0.7
shared_preferences: ^2.2.2
csv: ^5.0.0
share_plus: ^7.0.0
