# Sandwich Shop App

A small Flutter sample app that simulates a sandwich counter/order screen.  
It demonstrates basic state handling, selectable bread types, sandwich size toggle, add/remove quantity controls, and an order preview with notes.

Key features
- Select bread type (white, wheat, multigrain, sourdough, wholemeal)
- Toggle between footlong / six-inch sandwiches
- Increment / decrement sandwich quantity with a configurable max
- Live order preview showing quantity, bread, type and emoji visualization
- Add optional order notes
- Lightweight, testable UI (includes widget tests)

---

## Prerequisites

- Operating System: Windows, macOS, or Linux
- Flutter SDK (stable channel) and Dart (see https://docs.flutter.dev/get-started/install)
- An Android/iOS simulator or a physical device OR use `flutter run -d windows` if building for desktop
- Git (to clone the repo)
- A code editor (Visual Studio Code, Android Studio, etc.)

---

## Get the source

1. Clone the repository
   - git clone <AbigailHinchliffe/sandwich>
   > cd sandwich

2. Fetch dependencies
   > flutter pub get

---

## Run the app

From the project root:

- To run on the default connected device:
  > flutter run

- To run tests:
  > flutter test

- To run on a specific device/emulator (Windows example):
  > flutter run -d windows

If using VS Code or Android Studio, open the project and use the built-in run/debug buttons.

---

## Usage

Launch the app to see the main Order screen.

Main user flows:
- Bread selection: open the dropdown and pick a bread type. The order preview updates to show the selected bread name.
- Size toggle: switch between "footlong" and the shorter option (six-inch); the preview updates its type string.
- Add / Remove: use the Add and Remove buttons to change the quantity. The preview string and emoji count update to match the quantity. Quantity respects the configured max.
- Notes: type order instructions into the notes TextField. The preview shows "Note: ..." when non-empty; otherwise it shows "Note: No notes added." per tests.
- The UI widgets are intentionally simple to make the app easy to read and test.
- Dynamic price Adjustements for Orders

Notes:
- The app uses an OrderRepository to manage quantity state and ensure it does not go below 0 or above the configured max (default max shown in the UI is 5 in tests).
- Button callbacks are synchronous in the UI, but any async work would use async/await inside the handlers. Tests use async test callbacks so they can await tester actions.

---

## Running and understanding the tests

Widget tests are located under `test/` (example: `test/views/widget_test.dart`). They exercise:
- The presence of OrderScreen as the home widget
- Initial preview text and title
- Increment / decrement behavior and limits
- Bread dropdown behavior
- Notes appearance
- StyledButton rendering

To execute:
- flutter test

If a test fails, the failure message will include the expected widget/text. Tests are sensitive to exact strings (for example: `0 white footlong sandwich(es): `), so updating label text in the app requires updating the tests accordingly.

---

## Project structure (relevant files)

- lib/
  - main.dart — app entry point and main widgets (OrderScreen, StyledButton, OrderItemDisplay)
  - views/ — UI styles (e.g. app_styles.dart)
  - repositories/
    - order_repository.dart — encapsulates quantity state, increment/decrement logic and limits
- test/
  - views/widget_test.dart — widget tests that validate UI and behavior
- pubspec.yaml — Flutter project configuration and dependencies
- README.md — this file

---

## Dependencies & tools

- Flutter (SDK)
- No external pub packages are required beyond the Flutter SDK for the code as provided (check pubspec.yaml for any additional packages you might add).
- Recommended editor: Visual Studio Code with Flutter extension (project was developed/tested using VS Code on Windows).

---

## Known issues & limitations

- Tests expect exact strings for labels and notes; changing wording breaks tests until they are updated to match.
- The current UI is basic and intended for learning/testing; accessibility, persistence, and backend integration are not implemented.
- The OrderRepository is in-memory only; no persistence or networking is implemented.

Planned improvements
- Add persistent storage for orders
- Improve accessibility and internationalization
- Add animations and richer order item customization

---

## Contributing

- Fork the repo, create a feature branch, add tests for behavioral changes, and open a PR.
- Keep UI text stable or update tests when changing strings.
- Please run `flutter test` and ensure the test suite passes before submitting a PR.

---

## Contact

Maintainership / contact:
- Name: Abigail Hinchliffe

---
