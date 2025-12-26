# Deep Work Timer 🍅

A professional-grade Pomodoro timer application built with Flutter, designed to help you maintain focus and achieve flow states.

## 🚀 Features

- **🎯 Focus & Break Timer**: Customizable durations for deep work sessions and short breaks.
- **📝 Task Tracking**: Input your current objective to stay aligned with your goals.
- **📊 Statistics Dashboard**: Visualize your productivity with beautiful bar charts showing daily completed sessions (last 7 days).
- **🎧 Ambient Soundscapes**: Built-in high-quality audio streams (Rain 🌧️, Forest 🌲, Fireplace 🔥, Cafe ☕) to mask distractions.
- **🔔 Smart Notifications**: Native system alerts notify you when a session ends, even if the app is in the background.
- **🎨 Dynamic Themes**: Customize the app's look with beautiful color presets (Classic, Ocean, Lavender, Forest) that adapt to your timer phase.
- **📱 Responsive Design**: A modern, clean UI built with Material 3, custom fonts (Outfit & JetBrains Mono), and smooth animations.

## 🛠️ Tech Stack

- **Framework**: Flutter
- **State Management**: [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- **Persistence**: [shared_preferences](https://pub.dev/packages/shared_preferences)
- **Charts**: [fl_chart](https://pub.dev/packages/fl_chart)
- **Audio**: [audioplayers](https://pub.dev/packages/audioplayers)
- **Notifications**: [flutter_local_notifications](https://pub.dev/packages/flutter_local_notifications)
- **Typography**: [google_fonts](https://pub.dev/packages/google_fonts)

## 📂 Project Structure

The project follows a **Feature-First** architecture for scalability and maintainability:

```
lib/
├── features/
│   ├── timer/          # Core timer logic and UI
│   ├── stats/          # Statistics repository and charts
│   ├── sounds/         # Audio player service
│   ├── notifications/  # Local notifications handler
│   └── settings/       # Theme and configuration services
├── main.dart           # Entry point and app-wide providers
```

## 🏁 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) installed.
- Android Studio / VS Code with Flutter extensions.

### Installation

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/yourusername/deep-work-timer.git
    cd deep-work-timer
    ```

2.  **Install dependencies:**
    ```bash
    flutter pub get
    ```

3.  **Run the app:**
    ```bash
    # For Chrome (Web)
    flutter run -d chrome

    # For Android (Emulator/Device)
    flutter run -d android
    ```

### Release Build (Android)
To build a release APK with core library desugaring enabled:
```bash
flutter build apk --release
```

## 📄 License
This project is open-source and available under the MIT License.
