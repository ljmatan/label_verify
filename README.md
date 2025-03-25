# Document Revision Verification

---

A document verification system that detects discrepancies in new versions based on configurable validation rules.

## 1. Developer Setup

---

The project has been tested and ran with the following software dependencies:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.29.2
- [Dart SDK](https://dart.dev/get-dart) 3.7.2
- [Python](https://www.python.org/downloads/) 3.11.3
- [Xcode](https://developer.apple.com/xcode/) 16.2

## 2. Project Structure

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

## 3. How to Run

---
