# HelpBeacon
 
*A platform connecting those in need with donors and volunteers*

## Table of Contents
- [Features](#features)
- [Technologies](#technologies)
- [Installation](#installation)
- [Configuration](#configuration)
- [Running the App](#running-the-app)
- [Firebase Setup](#firebase-setup)
- [Contributing](#contributing)
- [License](#license)

## Features

### For Users in Need
- **Request Aid**: Create assistance requests (food, shelter, medical, bills, educaation sponsorships etc.)
- **Real-time Chat**: Communicate directly with donors/NGOs
- **Emergency Contacts**: Quick access to local emergency services
- **Resource Map**: View nearby aid distribution centers
- **Request Tracking**: Monitor status of your requests

### For Donors/Volunteers
- **Make Donations**: Offer goods, services or financial help
- **Browse Requests**: Find and fulfill specific needs
- **Donation Management**: Track your donation history
- **Verified Status**: Build trust with verification badges
- **Impact Dashboard**: See your community contribution

### For NGOs/Government
- **Request Management**: Monitor and fulfill aid requests
- **Volunteer Coordination**: Organize relief efforts
- **Crisis Heatmaps**: Identify high-need areas
- **Analytics**: Track relief operation metrics

## Technologies

### Frontend
- **Flutter** (v3.0+) - Cross-platform framework
- **Dart** - Programming language
- **Material Design** - UI components

### Backend
- **Firebase Authentication** - User management
- **Cloud Firestore** - Real-time database
- **Firebase Storage** - File storage
- **Cloud Functions** - Backend logic

### Additional Packages
- `image_picker` - For image uploads
- `cached_network_image` - Efficient image loading
- `intl` - Date/number formatting
- `geolocator` - Location services
- `url_launcher` - Opening external links

## Installation

1. **Prerequisites**:
   - Flutter SDK (v3.0+)
   - Dart (v2.17+)
   - Android Studio/Xcode (for mobile builds)
   - Firebase account

2. **Clone the repository**:
   ```bash
   git clone https://github.com/Youngmiles/Help_Beacon.git
   cd help_beacon
   ```

3. **Install dependencies**:
   ```bash
   flutter pub get
   ```

## Configuration

1. **Create Firebase Project**:
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create new project "HelpBeacon"
   - Enable Authentication (Email/Password)
   - Set up Firestore Database
   - Configure Storage Bucket

2. **Add Firebase Config**:
   - Place your `google-services.json` (Android) and `GoogleService-Info.plist` (iOS) in the respective platform folders

## Running the App

### Development
```bash
flutter run
```

### Build Releases
**Android**:
```bash
flutter build apk --release
```

**iOS**:
```bash
flutter build ios --release
```

## Firebase Setup

1. **Firestore Rules**:
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /requests/{request} {
         allow read: if true;
         allow create: if request.auth != null;
         allow update, delete: if request.auth.uid == resource.data.userId;
       }
       match /donations/{donation} {
         allow read: if true;
         allow create: if request.auth != null;
         allow update, delete: if request.auth.uid == resource.data.donorId;
       }
     }
   }
   ```

2. **Authentication Rules**:
   - Enable Email/Password authentication
   - Consider adding phone authentication for emergency access

## Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

Davis Kathungu Kamula – Developer & Project Owner

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

**HelpBeacon** is developed with ❤️ to help communities during crises. If you use this project, please consider giving credit and contributing back to help improve it for everyone.
