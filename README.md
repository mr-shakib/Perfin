# Perfin - Personal Finance Manager

A modern, intuitive personal finance management app built with Flutter and Supabase. Track expenses, manage budgets, and gain insights into your spending habits with a beautiful, user-friendly interface.

## ✨ Features

### 🔐 Authentication
- Secure email/password authentication
- User registration with validation
- Session management with Supabase Auth

### 💰 Transaction Management
- Add, edit, and delete transactions
- Categorize expenses (Food, Transport, Entertainment, etc.)
- Track income and expenses
- Transaction history with filtering

### 📊 Budget Tracking
- Set monthly budgets by category
- Real-time budget vs. actual spending
- Visual progress indicators
- Budget alerts and notifications

### 🎯 Onboarding Experience
- Personalized setup flow
- Financial goal setting
- Category preferences
- Notification preferences
- Weekly review scheduling

### 🎨 Modern UI/UX
- Clean, intuitive interface
- Dark/Light theme support
- Smooth animations with Lottie
- Responsive design for all screen sizes

### 📱 Cross-Platform
- Android
- iOS
- Web
- Windows
- macOS
- Linux

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.10.4 or higher)
- Dart SDK
- Android Studio / Xcode (for mobile development)
- Supabase account

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/yourusername/perfin.git
   cd perfin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Set up environment variables**
   ```bash
   copy .env.example .env
   ```
   
   Edit `.env` and add your Supabase credentials:
   ```env
   SUPABASE_URL=your_supabase_url
   SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

4. **Set up Supabase**
   - Create a new project at [supabase.com](https://supabase.com)
   - Run the SQL script from `supabase_setup.sql` in your Supabase SQL editor
   - Get your API credentials from Settings → API

5. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── config/           # Configuration files (Supabase, etc.)
├── constants.dart    # App-wide constants
├── main.dart        # App entry point
├── models/          # Data models
│   ├── budget.dart
│   ├── transaction.dart
│   ├── user.dart
│   └── ...
├── providers/       # State management (Provider)
│   ├── auth_provider.dart
│   ├── budget_provider.dart
│   ├── transaction_provider.dart
│   └── ...
├── screens/         # UI screens
│   ├── auth/
│   ├── onboarding/
│   └── ...
├── services/        # Business logic & API calls
│   ├── auth_service.dart
│   ├── budget_service.dart
│   ├── transaction_service.dart
│   └── ...
├── theme/           # App theming
│   ├── app_colors.dart
│   ├── app_theme.dart
│   └── ...
├── utils/           # Utility functions
├── validators/      # Input validation
└── widgets/         # Reusable widgets
```

## 🛠️ Tech Stack

### Frontend
- **Flutter** - UI framework
- **Provider** - State management
- **Lottie** - Animations

### Backend
- **Supabase** - Backend as a Service
  - Authentication
  - PostgreSQL Database
  - Real-time subscriptions
  - Row Level Security (RLS)

### Local Storage
- **Hive** - Fast, lightweight local database
- **Path Provider** - File system access

### Environment
- **flutter_dotenv** - Environment variable management

## 🔒 Security

- Environment variables for sensitive credentials
- Supabase Row Level Security (RLS) policies
- Secure authentication flow
- Input validation and sanitization
- `.env` file excluded from version control

## 🧪 Testing

Run tests with:
```bash
# All tests
flutter test

# Unit tests only
flutter test test/unit/

# Widget tests only
flutter test test/widget/
```

## 📱 Building for Production

### Android
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

### Web
```bash
flutter build web --release
```

## 📚 Documentation

Additional documentation can be found in the `docs/` folder:

- [Environment Setup](docs/ENV_SETUP.md)
- [Supabase Setup](docs/SUPABASE_SETUP.md)
- [Onboarding Integration](docs/ONBOARDING_INTEGRATION.md)
- [Login Screen Design](docs/LOGIN_SCREEN_DESIGN.md)

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

Your Name - [@yourhandle](https://twitter.com/yourhandle)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Supabase for the backend infrastructure
- All contributors and supporters

## 📞 Support

For support, email support@perfin.app or join our Slack channel.

---

Made with ❤️ using Flutter
