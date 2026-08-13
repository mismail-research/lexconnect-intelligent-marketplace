====================================================================
 LEXCONNECT Intelligent Marketplace (LEXIUM)
 AI-Powered Lawyer-Client Connection Platform
====================================================================

LexConnect is a Flutter-based cross-platform application that
connects clients with verified, suitable lawyers through AI-powered
guidance. The platform brings together two dedicated user
experiences - a Client Module and a Lawyer Module - backed by a
centralized administrative verification process, to create a
transparent and efficient legal services ecosystem.


--------------------------------------------------------------------
TABLE OF CONTENTS
--------------------------------------------------------------------
1. Overview
2. Key Objectives
3. Features
   3.1 Lawyer Module
   3.2 Client Module
4. Application Flow
5. Tech Stack
6. Architecture
7. Getting Started
8. Project Structure
9. Future Improvements


--------------------------------------------------------------------
1. OVERVIEW
--------------------------------------------------------------------
LexConnect solves a common problem: clients struggle to find the
right lawyer for their legal needs, and lawyers struggle to build a
trustworthy online presence. The platform addresses this by
combining:

  - Verified lawyer profiles
    Every lawyer is manually reviewed and approved by an
    administrator before they can accept clients.

  - AI-powered legal guidance
    An in-app chat assistant helps clients understand their legal
    issue and get matched with the right category of lawyer.

  - Direct booking and communication
    Clients can book appointments and, once accepted, communicate
    directly with their lawyer.

  - Transparent ratings
    Completed cases can be rated, helping future clients make
    informed decisions.


--------------------------------------------------------------------
2. KEY OBJECTIVES
--------------------------------------------------------------------
  - Allow verified lawyers to build professional profiles.
  - Help clients find the most suitable lawyer for their legal needs.
  - Provide AI-powered legal guidance and recommendations.
  - Enable direct communication between lawyers and clients.
  - Ensure transparency through ratings and reviews.
  - Create a fair and competitive environment for legal professionals.


--------------------------------------------------------------------
3. FEATURES
--------------------------------------------------------------------

3.1 LAWYER MODULE
--------------------------------------------------------------------

Authentication
  - Sign up / log in via Firebase Authentication.

Professional Profile Setup
  - Business Name, Location, WhatsApp Number, Years of Experience,
    Lawyer Category, High Court Qualification, Profile Picture,
    Bar Council Number, and other professional details.
  - Submitted details are automatically emailed to the administrator
    for review.

Admin Verification
  - Approved -> Lawyer gains full access to the Dashboard.
  - Rejected -> Lawyer is redirected to a Rejected screen where
    they can edit and resubmit their information.

Dashboard
  - Profile picture, appointment details icon, logout button.
  - Performance statistics: Accepted, Rejected, and Available
    appointments (shown as percentages).
  - List of incoming appointment requests from clients.

Statistics Screen
  - Today's appointments.
  - Progress charts for the last five months (Completed, Pending,
    Rejected cases).

Profile Management
  - Update profile picture, personal info, WhatsApp number,
    professional details, and case information.


3.2 CLIENT MODULE
--------------------------------------------------------------------

Authentication
  - Sign up / log in via Firebase Authentication.

Dashboard
  - Appointment details icon, logout button.
  - Browse lawyer categories; selecting a category lists all
    lawyers within it.
  - Compare lawyer profile cards side by side.

Lawyer Details Screen
  - Name, profile picture, location, experience, cases won, rating,
    about section, education, Bar Council number, and current
    availability status.

Book Appointment
  - Choose a meeting preference:
      * At Client's Office
      * At Lawyer's Office
      * Online Meeting
  - Select appointment date and time.
  - Confirm the request (one active request per lawyer at a time;
    can be canceled before the lawyer responds).

Appointment Notifications
  - Lawyer receives a push notification for new requests and can
    accept/reject.
  - Client receives a push notification with the lawyer's decision.

AI Chat Assistant
  - Provides legal guidance and case analysis.
  - Recommends suitable lawyers based on the client's described
    issue.
  - Answers general questions about available legal services.

Communication
  - Once a lawyer accepts an appointment, their WhatsApp number
    becomes visible to the client for direct communication.

Case Completion & Ratings
  - Lawyer marks a case as "Completed" via the Appointment Details
    screen.
  - Client can then rate the lawyer; ratings are displayed publicly
    on the Lawyer Details screen.

Client Profile Screen
  - Update profile picture, name, WhatsApp number; view registered
    email address.


--------------------------------------------------------------------
4. APPLICATION FLOW
--------------------------------------------------------------------
  1. Splash Screen
     Introduces the app and handles background initialization.

  2. Role Selection Screen
     User chooses Lawyer or Client.

  3. Authentication
     Login or Sign-Up via Firebase Authentication.

  4. Role-based routing:
       Lawyer -> Professional Information Setup
              -> Verification Pending
              -> Dashboard (if approved)
                 OR Rejected Screen (if rejected; editable and
                 resubmittable)

       Client -> Dashboard
              -> Browse categories
              -> View lawyer profiles
              -> Book appointment

  5. Appointment Lifecycle:
       Request -> Notification -> Accept/Reject
              -> (if accepted) Communication
              -> Case Completion -> Rating


--------------------------------------------------------------------
5. TECH STACK
--------------------------------------------------------------------
  Frontend         : Flutter (cross-platform: Android & iOS)
  Authentication   : Firebase Authentication
  Database         : Cloud database (per-user document/data structure)
  Notifications    : Push notifications
  AI Assistant     : AI-powered chat for legal guidance & lawyer
                      recommendations


--------------------------------------------------------------------
6. ARCHITECTURE
--------------------------------------------------------------------
  - Role-based access segmentation
    Immediately after the splash screen, the app separates the
    client and lawyer journeys via a role tracker, which determines
    profile setup, navigation, and permissions throughout the app.

  - Secure authentication
    Credentials are validated locally, then encrypted and
    transmitted to the authentication server, which issues a
    unique user ID (UID) for each account.

  - Per-user data isolation
    Each user gets an isolated document/data node in the cloud
    database, keeping verification records and personal data
    separate from publicly accessible information.

  - Admin verification gateway
    Lawyer accounts are held in a pending state until an
    administrator manually approves or rejects submitted
    credentials.


--------------------------------------------------------------------
7. GETTING STARTED
--------------------------------------------------------------------

Prerequisites
  - Flutter SDK (https://flutter.dev/docs/get-started/install)
  - A Firebase project with Authentication enabled
  - Android Studio / Xcode for platform-specific builds

Installation

  # Clone the repository
  git clone <repository-url>
  cd lexconnect

  # Install dependencies
  flutter pub get

  # Add your Firebase configuration files
  # - android/app/google-services.json
  # - ios/Runner/GoogleService-Info.plist

  # Run the app
  flutter run


--------------------------------------------------------------------
8. PROJECT STRUCTURE
--------------------------------------------------------------------

  lexconnect/
  |-- lib/
  |   |-- modules/
  |   |   |-- lawyer/     (Lawyer auth, profile setup, dashboard, stats)
  |   |   |-- client/     (Client auth, dashboard, booking, AI chat)
  |   |-- shared/         (Shared widgets, models, and services)
  |   |-- services/       (Firebase, notifications, AI chat integration)
  |   |-- main.dart
  |-- assets/
  |-- android/
  |-- ios/
  |-- README.md

  (Adjust to match your actual folder layout.)


--------------------------------------------------------------------
9. FUTURE IMPROVEMENTS
--------------------------------------------------------------------
  - In-app video/audio consultations.
  - Payment integration for consultation fees.
  - Multi-language support for the AI chat assistant.
  - Advanced lawyer search filters (fees, location radius).
  - Analytics dashboard for administrators.

====================================================================
 END OF README
====================================================================
