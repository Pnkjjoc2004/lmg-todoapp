# LMG ToDo App

A feature-rich ToDo application built with Flutter, focused on local efficiency and smooth user experience.

## Features

*   **Local Storage**: Uses [Hive](https://pub.dev/packages/hive) for lightning-fast, offline-first local storage of all your ToDo items.
*   **State Management**: Powered by [Riverpod](https://pub.dev/packages/flutter_riverpod) for reactive, scalable, and testable state management.
*   **Task Timers**: Includes built-in countdown timers for tasks. You can start, pause, and stop timers directly from the list or details page.
*   **Real-time Search**: Instantly filter your ToDo list using the built-in search bar.
*   **Local Notifications**: Triggers scheduled local notifications automatically when a task's timer reaches zero or is marked as 'Done'.
*   **Authentication**: Secure user login and registration using **Firebase Authentication**.
*   **Guest Mode Fallback**: Users can choose to "Continue without signing in" to bypass Firebase, allowing the app to remain completely functional offline.

## Important: Firebase Configuration (`google-services.json`)

For security reasons, the original `google-services.json` file containing actual Firebase project credentials is **not uploaded to GitHub** (it is excluded via `.gitignore`).

**To run this project locally:**
1. A dummy file named `google-services-dummy.json` is provided in the `android/app/` directory as a template.
2. If you are setting up your own Firebase project, download your generated `google-services.json` from the Firebase Console.
3. Place your `google-services.json` inside the `android/app/` folder before running `flutter run`.

If you do not have a Firebase project, the app will fail to build on Android unless you remove the `google-services` plugin dependencies from the `build.gradle` files, or simply proceed using the **Guest Mode** (with a valid JSON provided).

## Getting Started

1. Check out the repository.
2. Ensure you have the Flutter SDK installed.
3. Run `flutter pub get` to fetch dependencies.
4. Place your valid `google-services.json` in `android/app/`.
5. Run `flutter run`.
