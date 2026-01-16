📅 Event Central

Event Central is a Flutter-based mobile application designed to centralize college club events (GDGC, IEEE, TinkerHub, IEDC, NSDC, etc.) into a single platform.
Users can view events, register via Google Forms, add events to Google Calendar, and receive reminders.
Authorized users can add, edit, and delete events for their respective clubs.

🚀 Features
🔐 Authentication

Email & Password Sign In / Sign Up (Firebase Authentication)

Google Sign-In support

Secure session handling

🏠 Home Page

Displays available clubs

Navigation to club-specific event pages

Logout functionality

🏷️ Club-wise Event Management

Separate event lists for each club (GDGC, IEEE, etc.)

Events stored in Firebase Firestore

Real-time updates using Firestore streams

🎫 Event Details

Each event contains:

Event Name

Event Description

Event Date & Time

Registration Link (Google Form)

🔗 Registration

“Register” button opens the Google Form in an external browser

📅 Google Calendar Integration

“Add to Calendar” button

Automatically opens Google Calendar with:

Event title

Description

Date & time

➕ Add Event

Add new events for a specific club

Date & time picker

Firestore integration

✏️ Edit Event

Edit existing event details

Pre-filled form with current event data

🗑️ Delete Event

Trash icon to delete events

Confirmation dialog before deletion

🎨 UI & Assets

Custom app launcher icon

Clean Material UI

Card-based event layout

🛠️ Tech Stack

Flutter (Dart)

Firebase Authentication

Cloud Firestore

Google Sign-In

Google Calendar (via URL intent)

url_launcher

intl (date formatting)

🔧 Installation & Setup
1️⃣ Prerequisites

Flutter SDK (stable)

Android Studio / VS Code

Firebase account

Git

Check Flutter:

flutter doctor

2️⃣ Clone the Repository
git clone https://github.com/<your-username>/Event_central1.git
cd event_central

3️⃣ Install Dependencies
flutter pub get

4️⃣ Firebase Setup
🔹 Create Firebase Project

Go to https://console.firebase.google.com

Create a new project

Enable:

Authentication

Email/Password

Google

Cloud Firestore

🔹 Add App to Firebase

Register Android app

Download google-services.json

Place it in:

android/app/google-services.json

5️⃣ Run the App
flutter run
