# LEXCONNECT Intelligent Marketplace (LEXIUM)

### AI-Powered Lawyer-Client Connection Platform

LexConnect is a Flutter-based cross-platform application that connects clients with verified and suitable lawyers through AI-powered guidance. The platform provides two dedicated user experiences — a **Client Module** and a **Lawyer Module** — supported by a centralized administrative verification process to create a transparent and efficient legal services ecosystem.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Key Objectives](#2-key-objectives)
3. [Features](#3-features)

   * [3.1 Lawyer Module](#31-lawyer-module)
   * [3.2 Client Module](#32-client-module)
4. [Application Flow](#4-application-flow)
5. [Tech Stack](#5-tech-stack)
6. [Architecture](#6-architecture)
7. [Getting Started](#7-getting-started)
8. [Project Structure](#8-project-structure)
9. [Future Improvements](#9-future-improvements)

---

## 1. Overview

LexConnect addresses a common challenge in legal services: clients may struggle to identify the right lawyer for their legal needs, while lawyers may face difficulties establishing a trustworthy online presence.

The platform addresses these challenges by combining:

### Verified Lawyer Profiles

Every lawyer is manually reviewed and approved by an administrator before gaining access to client appointments.

### AI-Powered Legal Guidance

An in-app AI chat assistant helps clients understand their legal concerns and recommends suitable lawyer categories based on the described issue.

### Direct Booking and Communication

Clients can browse lawyer profiles, request appointments, and communicate directly with a lawyer after the appointment request has been accepted.

### Transparent Ratings

After completion of a case, clients can rate their lawyer, allowing future clients to make more informed decisions.

---

## 2. Key Objectives

* Allow verified lawyers to build professional profiles.
* Help clients find suitable lawyers for their legal needs.
* Provide AI-powered legal guidance and lawyer recommendations.
* Enable direct communication between lawyers and clients.
* Support appointment booking and management.
* Provide transparency through ratings and reviews.
* Create a fair and competitive environment for legal professionals.

---

## 3. Features

### 3.1 Lawyer Module

#### Authentication

* Sign up and log in using Firebase Authentication.

#### Professional Profile Setup

Lawyers can provide professional information including:

* Business name
* Location
* WhatsApp number
* Years of experience
* Lawyer category
* High Court qualification
* Profile picture
* Bar Council number
* Other professional details

Submitted information is forwarded to the administrator for verification.

#### Admin Verification

* **Approved:** The lawyer gains access to the main dashboard.
* **Rejected:** The lawyer is redirected to a rejection screen where submitted information can be edited and resubmitted.

#### Dashboard

* Profile picture
* Appointment details
* Logout functionality
* Performance statistics
* Accepted, rejected, and available appointment percentages
* Incoming appointment requests from clients

#### Statistics Screen

* Today's appointments
* Monthly progress charts
* Completed cases
* Pending cases
* Rejected cases
* Five-month performance overview

#### Profile Management

Lawyers can update:

* Profile picture
* Personal information
* WhatsApp number
* Professional information
* Case-related information

---

### 3.2 Client Module

#### Authentication

* Sign up and log in using Firebase Authentication.

#### Dashboard

Clients can:

* View appointment details
* Browse lawyer categories
* View lawyers within a selected category
* Compare lawyer profiles

#### Lawyer Details

The lawyer details screen provides information including:

* Name
* Profile picture
* Location
* Years of experience
* Cases won
* Rating
* About section
* Education
* Bar Council number
* Current availability status

#### Appointment Booking

Clients can:

* Select a preferred meeting method:

  * At Client's Office
  * At Lawyer's Office
  * Online Meeting
* Select appointment date and time.
* Submit an appointment request.
* Cancel an active request before the lawyer responds.

The system allows one active appointment request per lawyer at a time.

#### Appointment Notifications

* Lawyers receive push notifications when new appointment requests are submitted.
* Lawyers can accept or reject appointment requests.
* Clients receive notifications regarding the lawyer's decision.

#### AI Chat Assistant

The AI assistant provides:

* General legal guidance
* Case-related analysis
* Lawyer category recommendations
* Answers to general questions about available legal services

> **Note:** The AI assistant is intended to provide general informational guidance and should not be considered a substitute for professional legal advice.

#### Communication

Once a lawyer accepts an appointment, the lawyer's WhatsApp contact information becomes available to the client for direct communication.

#### Case Completion and Ratings

* Lawyers can mark an appointment as **Completed**.
* Clients can rate the lawyer after case completion.
* Ratings are displayed on the lawyer's details screen.

#### Client Profile

Clients can:

* Update profile picture
* Update name
* Update WhatsApp number
* View registered email address

---

## 4. Application Flow

### 1. Splash Screen

Introduces the application and performs initial background initialization.

### 2. Role Selection

The user selects one of two roles:

* Lawyer
* Client

### 3. Authentication

Users can log in or create an account using Firebase Authentication.

### 4. Role-Based Routing

#### Lawyer

```text
Professional Information Setup
            ↓
Verification Pending
            ↓
      Administrator
       /          \
   Approved      Rejected
      ↓             ↓
  Dashboard     Edit & Resubmit
```

#### Client

```text
Dashboard
    ↓
Browse Lawyer Categories
    ↓
View Lawyer Profiles
    ↓
Select Lawyer
    ↓
Book Appointment
```

### 5. Appointment Lifecycle

```text
Request
   ↓
Notification
   ↓
Accept / Reject
   ↓
Communication
   ↓
Case Completion
   ↓
Rating
```

---

## 5. Tech Stack

| Component            | Technology                       |
| -------------------- | -------------------------------- |
| Frontend             | Flutter                          |
| Programming Language | Dart                             |
| Platforms            | Android & iOS                    |
| Authentication       | Firebase Authentication          |
| Cloud Database       | Firebase / Cloud Database        |
| Notifications        | Push Notifications               |
| AI Assistant         | AI-powered conversational system |
| Communication        | WhatsApp integration             |

---

## 6. Architecture

### Role-Based Access Segmentation

Immediately after the splash screen, the application separates the client and lawyer journeys using role-based routing. The selected role determines the user's profile setup, navigation flow, available functionality, and permissions.

### Secure Authentication

User authentication is handled through Firebase Authentication. Each authenticated user receives a unique Firebase User ID (UID), which is used to associate application data with the corresponding account.

### Per-User Data Isolation

User-specific information is organized using user-associated data structures in the cloud database. This helps separate individual user information and supports controlled access to application data.

### Admin Verification Gateway

Lawyer accounts remain in a pending verification state until an administrator reviews the submitted professional credentials.

The administrator can:

* Approve the lawyer profile.
* Reject the submitted information.
* Allow rejected profiles to be edited and resubmitted.

---

## 7. Getting Started

### Prerequisites

Before running the application, install:

* [Flutter SDK](https://flutter.dev/docs/get-started/install)
* Android Studio for Android development
* Xcode for iOS development (macOS required)
* A configured Firebase project
* Firebase Authentication enabled
* Required Firebase services configured for the application

### Installation

Clone the repository:

```bash
git clone https://github.com/<your-username>/lexconnect-intelligent-marketplace.git
```

Navigate to the project directory:

```bash
cd lexconnect-intelligent-marketplace
```

Install Flutter dependencies:

```bash
flutter pub get
```

### Firebase Configuration

Configure the Firebase project according to the application's requirements.

Required platform-specific configuration files may include:

```text
android/app/google-services.json
ios/Runner/GoogleService-Info.plist
```

**Do not commit private credentials, API keys, service-account files, or other sensitive configuration data to the repository.**

### Run the Application

```bash
flutter run
```

---

## 8. Project Structure

The following structure represents the main organization of the application:

```text
lexconnect-intelligent-marketplace/
│
├── lib/
│   ├── modules/
│   │   ├── lawyer/
│   │   │   ├── authentication/
│   │   │   ├── profile/
│   │   │   ├── dashboard/
│   │   │   └── statistics/
│   │   │
│   │   └── client/
│   │       ├── authentication/
│   │       ├── dashboard/
│   │       ├── lawyer_details/
│   │       ├── booking/
│   │       └── ai_chat/
│   │
│   ├── shared/
│   │   ├── widgets/
│   │   ├── models/
│   │   └── services/
│   │
│   ├── services/
│   │   ├── firebase/
│   │   ├── notifications/
│   │   └── ai/
│   │
│   └── main.dart
│
├── assets/
│
├── android/
│
├── ios/
│
├── README.md
│
└── pubspec.yaml
```

> **Note:** The structure above should be updated to reflect the actual project directory structure before final publication.

---

## 9. Future Improvements

Potential future enhancements include:

* In-app video and audio consultations.
* Payment integration for consultation fees.
* Multi-language support for the AI assistant.
* Advanced lawyer search and filtering.
* Location-radius-based lawyer search.
* Consultation fee comparison.
* Enhanced AI-based lawyer recommendation.
* Administrator analytics dashboard.
* Advanced appointment management.
* Improved communication and consultation features.

---

## License

This project is licensed under the **MIT License**.

See the `LICENSE` file for details.
