# Document Revision Verification

---

A document verification system that detects discrepancies in new versions based on configurable validation rules.

## 1 Developer Setup

---

The project has been tested and ran with the following software dependencies:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.29.2
- [Dart SDK](https://dart.dev/get-dart) 3.7.2
- [Python](https://www.python.org/downloads/) 3.11.3
- [Git LFS](https://git-lfs.com) 3.6.1
- [PyInstaller](https://pyinstaller.org) 6.12.0
- [Xcode](https://developer.apple.com/xcode/) 16.2

## 2 Project Structure

---

The project is implemented as a Flutter desktop app, which relies on an underlying Python server implementation.

This setup ensures successful cross-platform interoperability,
with both of the major SDK systems used having considerable community support.

```txt
label_verify
│
│── assets/             # Visual resources (images, fonts, etc.)
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

## 3 How to Run

---

The application is configured and supports running as a
[Flutter desktop app](https://docs.flutter.dev/platform-integration/desktop):

```txt
C:\> flutter run -d windows
$ flutter run -d macos
$ flutter run -d linux
```

Required project resources include the Python middleware binary compiled with PyInstaller,
which is located in the `assets/bin` directory, and which is shared by utilising the "Git Large File Storage" service.

### 3.1 Middleware Updates

If any changes are made to the Python part of the project,
a new binary needs to be compiled and placed into the relevant location.

The process is automated with the following script usage on MacOS and Linux:

```sh
sh scripts/build-middleware.sh
```

## 4 How to Deploy

---

TODO
