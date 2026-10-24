# HemoLife 2.0 — Blood Donor & Blood Bank Management Mobile App

[![Flutter](https://img.shields.io/badge/Flutter-3.47.6-blue.svg)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.5-blue.svg)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Design-Material_3-red.svg)](https://m3.material.io)
[![State](https://img.shields.io/badge/State-Riverpod-indigo.svg)](https://riverpod.dev)

A mobile client built with Flutter & Material 3 that connects directly to the HemoLife Flask + SQLite backend. Featuring emergency blood finding, live stock tracking, volunteer donor registration, request dispatching, and a full role-guarded hospital administration suite.

---

## 📱 App Highlights & Architecture

### Two Seamless Modes:
1. **Public Mode (No Login Required)**:
   - **Live Stock Dashboard**: 8 real-time blood group cards color-coded by stock level (🔴 Critical < 3, 🟠 Low 3–7, 🟢 Healthy > 7).
   - **Find Blood & Donors**: Instant compatibility search with direct tap-to-call integration for registered volunteer donors.
   - **Emergency Request Form**: Multi-step validated form with quantity stepper, hospital specification, and generated Tracking Reference ID with 1-tap clipboard copying.
   - **Become a Donor**: WHO-compliant donor registration form (enforcing 18–65 age bounds, 10-digit phone number, address) with celebratory success screen.

2. **Admin Mode (Hospital Staff Portal)**:
   - **Secure Bearer Token Auth**: Auto-expiring 8-hour sessions with automatic 401 interceptor redirection.
   - **Executive Dashboard**: KPI summary cards + interactive `fl_chart` charts (Inventory by Blood Group bar chart & Request Status distribution donut chart).
   - **Request Management**: Status filtering chips (`PENDING`, `PROCESSING`, `FULFILLED`, `CANCELLED`), search by patient or reference ID, status modification modal, and swipe/confirm deletion.
   - **Donor Registry**: Debounced (400ms) search, blood-group filters, infinite-scroll pagination, inline editing, and deactivation.
   - **Inventory Controller**: 8 blood-group stock cards with `+` / `-` steppers and direct commit via `PUT /api/inventory/:bloodGroup`.

---

## 🛠️ Project Structure (Clean Feature-First)

```
lib/
├── core/
│   ├── api/             # Config (Base URL), ApiClient, AuthInterceptor (401 auto-logout), Exceptions
│   ├── providers/       # Global Riverpod providers & connectivity listener
│   ├── router/          # GoRouter configuration with role-guarded redirects
│   ├── theme/           # Material 3 Crimson theme tokens (#C62828), Dark mode & typography
│   ├── utils/           # Validators (age 18-65, 10-digit phone), debouncer, formatters
│   └── widgets/         # BloodBadge, StatCard, ShimmerLoading, OfflineBanner, CustomButton
├── features/
│   ├── auth/            # Admin login UI, credentials management, auth repository & provider
│   ├── home/            # Public home, hero banner, live stock grid, public shell (4 tabs)
│   ├── search/          # Find blood screen, chip selectors, donor matching & calling
│   ├── requests/        # Blood request form, success confirmation screen, admin requests manager
│   ├── donors/          # Public donor registration, admin infinite-scroll donor registry
│   ├── inventory/       # Stock cards, admin inventory +/- stepper editor
│   └── dashboard/       # Admin dashboard, metric tiles, fl_chart bar & donut charts, admin shell
└── main.dart            # Application entry point with ProviderScope
```

---

## ⚙️ Configuration & Base URL

All networking configuration is consolidated in a single file:
👉 **[`lib/core/api/config.dart`](lib/core/api/config.dart)**

```dart
class ApiConfig {
  // Switch to your environment's URL:
  // - Android Emulator: 'http://10.0.2.2:5000'
  // - Web / Desktop testing: 'http://127.0.0.1:5000'
  // - Physical Device on Wi-Fi: 'http://<YOUR_LAN_IP>:5000' (e.g. 'http://192.168.1.100:5000')
  static String baseUrl = 'http://10.0.2.2:5000';
  ...
}
```

---

## 🚀 Running the App Locally

### 1. Start the Flask Backend
Make sure the Flask backend is running on `0.0.0.0:5000`:
```bash
cd backend
python app.py
```
*Default admin credentials: `admin` / `admin123`*

### 2. Run the Mobile App in Android Emulator
```bash
# Verify connected devices or running emulators
flutter devices

# Launch on Android Emulator
flutter run
```

### 3. Run on Web / Chrome / Desktop
```bash
# Run with Chrome
flutter run -d chrome

# Or run lightweight web server
flutter run -d web-server --web-port 8080
```

---

## 🧪 Testing Suite

Run the automated test suite covering models, repositories with mocked Dio, form validators, and widget tests:
```bash
flutter test
```

### Included Tests:
- `test/validators_test.dart`: Validates name, age (18–65), 10-digit phone, hospital, and blood groups.
- `test/models_test.dart`: Validates JSON serialization/deserialization for all entities against live API schemas.
- `test/repositories_test.dart`: Validates API repositories with mock `Dio` HTTP adapter.
- `test/request_form_widget_test.dart`: Widget test verifying form rendering, quantity stepper interactions, and inline validation triggers.

---

## 📦 Building the Android APK

To generate a release or debug APK for deployment on physical devices:

```bash
# Build Debug APK
flutter build apk --debug

# Build Release APK
flutter build apk --release
```
The output APK will be generated at:
`build/app/outputs/flutter-apk/app-release.apk`

---

## 💡 Recommended Backend Improvements

1. **Pagination Support for Requests**: `GET /api/requests` currently returns all items; adding query parameters `page` and `limit` matching the `GET /api/donors` endpoint improves scalability for hospital deployments with high volume.
2. **JWT Secret Persistence**: The backend currently initializes `app.config["SECRET_KEY"] = secrets.token_hex(32)` on process startup. If Flask restarts, previous sessions are invalidated. Storing a persistent secret key in an environment variable (`SECRET_KEY`) ensures persistent sessions across backend reboots.
3. **Password Hashing Upgrade**: Replace raw SHA-256 (`hashlib.sha256`) with salted hashes such as `bcrypt` or `argon2` via `werkzeug.security.generate_password_hash` to protect admin credentials against rainbow-table attacks.
4. **HTTPS Enforcement**: Transition from HTTP cleartext traffic to HTTPS with SSL/TLS certificates (e.g. Let's Encrypt or reverse-proxy like Caddy/Nginx) for medical and PII patient confidentiality.
