# Document Revision Verification

---

A document verification system that detects discrepancies in new versions based on configurable validation rules.

## 1. Developer Setup

---

The project has been tested and ran with the following software dependencies:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.29.2
- [Dart SDK](https://dart.dev/get-dart) 3.7.2
  - Required for applicaton running.
- [Git LFS](https://git-lfs.com) 3.6.1
  - Required for Git repository setup.
- [Python](https://www.python.org/downloads/) 3.11.3
- [PyInstaller](https://pyinstaller.org) 6.12.0
  - Required for middleware running and bundling.
- [Xcode](https://developer.apple.com/xcode/) 16.2
  - Required for running on the MacOS platform.

## 2. Project Structure

---

The project is implemented as a Flutter desktop app, which relies on an underlying Python server implementation.

This setup ensures successful cross-platform interoperability,
with both of the major SDK systems used having considerable community support.

```txt
label_verify
│
│── assets/             # Runtime binary and visual resources
│
│── lib/                # Flutter project codebase
│   │
│   ├── data/               # Data class collection
│   ├── models/             # Serialization class declarations
│   ├── services/           # Software service implementations
│   ├── view/               # Visual display elements
│   ├── config.dart         # Application configuration
│   └── main.dart           # Main program entrypoint
│
│── linux/              # Linux support
│
│── macos/              # MacOS support
│
│── middleware/         # Python server implementation
│
│── scripts/            # Automation scripts
│
└── windows/            # Windows support
```

As can be seen in the above display, the project mostly follows the standard Flutter application approach,
with an addition of the Python "middleware" integration.

## 3. How to Run

---

The application is configured and supports running as a
[Flutter desktop app](https://docs.flutter.dev/platform-integration/desktop):

```txt
C:\> flutter run -d windows
$ flutter run -d macos
$ flutter run -d linux
```

Required project resources include the Python middleware binary compiled with PyInstaller,
which is located in the `assets/bin` directory, and which is also shared by utilising the "Git Large File Storage" service.

### 3.1. Middleware Running

In order to run the middleware server as a standalone program, a named `port` CLI arguments is required,
in order to specify where to bind the program and listen to any incoming connections.

```sh
python3 middleware/main.py --port 49152
```

### 3.2. Middleware Updates

If any changes are made to the Python part of the project,
a new binary needs to be compiled and moved to an appropriate location.

The process is automated with the following script usage on MacOS and Linux:

```sh
sh scripts/build-middleware.sh
```

The script will generate a new binary file, then move it to the `assets/bin` directory.

In order to ensure any cached program data is also updated during the following runtime,
the `--dart-define lvBinAssetUpdate=true` value should be forwarded alongside the `flutter run` command:

```sh
flutter run --dart-define lvBinAssetUpdate=true
```

The reason behind this requirement is the fact that, in order to run the Python server binary from the Flutter frontend,
this binary file located in the `assets` directory and bundled with the app must be first saved to the user device,
and it's contents then executed from this new storage location.

## 4. How to Deploy

---

**TODO**

## 5. Flutter Frontend

---

Flutter SDK was the choice for this desktop application as it supports a single codebase that can target multiple platforms.

The framework’s cross-platform nature makes it possible to extend the application to the web platform, ensuring scalability.

### 5.1. Library Dependencies

This application uses library dependencies to extend functionality, simplify development,
and to ensure compatibility across platforms.
Each dependency is chosen for stability, performance, and support, reducing the need for custom implementations.

The complete list of dependencies utilised by this project can be found in the `assets/licences.html` file,
as well as by running the `flutter pub deps` command from the terminal.

### 5.2. State Management

[State](https://api.flutter.dev/flutter/widgets/State-class.html) is defined as
"information that (1) can be read synchronously when the widget is built and
(2) might change during the lifetime of the widget.".

With the question of state management with the Flutter SDK always remaining a hot topic,
the choice for this application was fairly simple, relying on the usage of the objects directly supported by the framework,
such as the
[`setState`](https://api.flutter.dev/flutter/widgets/State/setState.html) method, and
[`ValueNotifier`](https://api.flutter.dev/flutter/foundation/ValueNotifier-class.html) or
[`StreamController`](https://api.flutter.dev/flutter/dart-async/StreamController-class.html) objects.

The reason behind this approach is the fact that utilising any 3rd-party libraries renders the state management more abstract.

**TODO**

## 6. Python Backend

---

**TODO**

## 7. Usage

---

**TODO**
