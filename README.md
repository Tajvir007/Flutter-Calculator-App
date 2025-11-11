#  Flutter Calculator App

A fully functional calculator built using **Flutter** with a clean UI, responsive layout, and Dark/Light theme support.  
This app performs all basic arithmetic operations — addition, subtraction, multiplication, and division — while preventing invalid inputs.

---

##  Features

✅ Standard calculator interface with digits `0–9`  
✅ Operations: `+`, `−`, `×`, `÷`  
✅ Functional buttons: `AC` (All Clear), `⌫` (Backspace), `.` (Decimal), `=` (Equals)  
✅ Real-time calculation and accurate results  
✅ Prevents invalid inputs (like multiple operators in a row)  
✅ Dark/Light theme toggle 🌙☀️  
✅ Theme persistence using `shared_preferences`  


##  Tech Stack

- **Flutter** (UI Framework)
- **Dart** (Programming Language)
- **math_expressions** → for expression parsing and evaluation  
- **shared_preferences** → for saving theme preference locally  

---

##  Installation & Setup

### Clone the Repository
```bash
git clone https://github.com/Tajvir007/Flutter-Calculator-App.git
cd flutter_calculator_app


---
# Install Dependencies
flutter pub get
---


# Project Structure
lib/
│
├── main.dart          # Main Flutter app file (UI + Logic)
└── ...

# Dependencies
## Add these to your pubspec.yaml:

dependencies:
  flutter:
    sdk: flutter
  math_expressions: ^2.2.0
  shared_preferences: ^2.0.0

