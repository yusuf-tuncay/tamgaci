# Tamgaci - Flutter Finance Management App

A comprehensive finance management application built with Flutter and Firebase.

## 🚀 Features

- **User Authentication**: Secure registration and login with Firebase Auth
- **Profile Management**: Complete user profile with photo upload
- **Company Management**: Multi-company support with user roles
- **Financial Tracking**: Invoice management and financial reporting
- **Exchange Rates**: Real-time currency exchange rates from TCMB
- **Responsive Design**: Material Design 3 with responsive layout
- **Offline Support**: Local caching and offline functionality

## 🛠️ Tech Stack

- **Frontend**: Flutter 3.x
- **Backend**: Firebase
  - Authentication
  - Firestore Database
  - Cloud Storage
  - Cloud Functions
- **State Management**: Riverpod
- **Architecture**: Clean Architecture
- **UI Framework**: Material Design 3

## 📱 Supported Platforms

- ✅ Web (Chrome, Firefox, Safari, Edge)
- ✅ Android
- ✅ iOS
- ✅ Windows
- ✅ macOS

## 🏗️ Project Structure

```
lib/
├── core/                    # Core utilities and constants
├── features/               # Feature-based modules
│   ├── auth/              # Authentication
│   ├── user_profile/      # User profile management
│   ├── settings/          # Settings and preferences
│   └── ...
├── shared/                # Shared widgets and utilities
└── main.dart             # Application entry point
```

## 🔧 Setup Instructions

### Prerequisites

- Flutter SDK 3.x or higher
- Dart SDK 3.x or higher
- Firebase CLI
- Google Cloud SDK (gsutil)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/gucluoglu/tamgaci.git
   cd tamgaci
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase setup**
   ```bash
   firebase login
   firebase use tamgaci
   ```

4. **Generate Firebase configuration**
   ```bash
   flutterfire configure
   ```

5. **Deploy Firebase services**
   ```bash
   firebase deploy
   ```

6. **Run the application**
   ```bash
   flutter run -d chrome
   ```

## 🔐 Firebase Configuration

### Storage CORS Setup

The project uses Firebase Storage for image uploads. CORS configuration is required for web access:

```bash
gsutil cors set cors.json gs://tamgaci.firebasestorage.app
```

### Security Rules

- **Firestore**: Authenticated users only
- **Storage**: Public read for profile images, authenticated write
- **Functions**: Regional deployment (Europe-west1)

## 📦 Key Dependencies

- `firebase_core`: Firebase integration
- `firebase_auth`: User authentication
- `cloud_firestore`: Database operations
- `firebase_storage`: File storage
- `riverpod`: State management
- `image_picker`: Image selection
- `flutter_image_compress`: Image optimization
- `dio`: HTTP client for API calls

## 🎨 UI/UX Features

- **Material Design 3**: Modern, adaptive design
- **Responsive Layout**: Works on all screen sizes
- **Dark/Light Theme**: Automatic theme switching
- **Accessibility**: Screen reader support
- **Animations**: Smooth transitions and micro-interactions

## 🔒 Security Features

- **Authentication**: Firebase Auth with email/password
- **Authorization**: Role-based access control
- **Data Validation**: Input sanitization and validation
- **Secure Storage**: Encrypted local storage
- **HTTPS**: All communications encrypted

## 📊 Performance Optimizations

- **Image Compression**: Automatic image optimization
- **Lazy Loading**: On-demand data loading
- **Caching**: Smart caching strategies
- **Pagination**: Efficient data pagination
- **Bundle Splitting**: Optimized app size

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/

# Run with coverage
flutter test --coverage
```

## 🚀 Deployment

### Web Deployment

```bash
# Build for web
flutter build web

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Mobile Deployment

```bash
# Build for Android
flutter build apk --release

# Build for iOS
flutter build ios --release
```

## 📝 Development Guidelines

### Code Style

- Follow Dart/Flutter style guide
- Use meaningful variable and function names
- Add comprehensive comments
- Maintain consistent formatting

### Git Workflow

1. Create feature branches
2. Write descriptive commit messages
3. Use pull requests for code review
4. Keep main branch stable

### Architecture Principles

- **Separation of Concerns**: Clear layer separation
- **Dependency Injection**: Use Riverpod providers
- **Error Handling**: Comprehensive error management
- **Testing**: Write tests for critical functionality

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 👥 Team

- **Development**: [Your Name]
- **Design**: [Designer Name]
- **Backend**: [Backend Developer Name]

## 📞 Support

For support and questions:
- Email: info@seekitapps.com
- Issues: [GitHub Issues](https://github.com/yourusername/tamgaci/issues)

## 🎯 Roadmap

- [ ] Mobile app stores deployment
- [ ] Advanced reporting features
- [ ] Multi-language support
- [ ] API documentation
- [ ] Performance monitoring
- [ ] Automated testing pipeline

---

**Built with ❤️ using Flutter and Firebase**