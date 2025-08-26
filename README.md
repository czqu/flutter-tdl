# tdl-flutter

A Telegram tool client based on Flutter and tdl, providing functions such as download, upload, forward, and more.

## Feature Highlights
- **Multi-platform Support**: Built on the Flutter framework, runnable on Windows, macOS, Linux, and other platforms.
- **Core Functions**:
    - **Login**: Supports QR code login, verification code login, and importing login status from desktop clients.
    - **Download**: Download content from Telegram messages via links or JSON files.
    - **Upload**: Upload files or folders to a specified chat session.
    - **Forward**: Forward messages between different chat sessions, supporting multiple forwarding modes.
    - **Chat Tools**: List chats, export messages and chat members.
    - **Backup & Restore**: Backup and restore application configurations.
    - **Log Output**: Display real-time operation logs for easy debugging and tracking.

## Installation Instructions
1. Ensure the Flutter development environment is installed.
2. Clone this repository: `git clone https://github.com/czqu/flutter-tdl.git`
3. Navigate to the project directory: `cd flutter-tdl`
4. Install dependencies: `flutter pub get`
5. Run the app: `flutter run` or build an executable: `flutter build <platform>` (replace `<platform>` with target OS like `windows`, `macos`, or `linux`)

## User Guide

### 1. Initial Setup
- Go to the **Settings** page, select the path to the tdl executable file in the **tdl Path** tab.
- Configure global settings such as proxy and storage path in the **Global Parameters** tab.

### 2. Login
- Two login methods are supported:
    - **Quick Login**: Log in via QR code or verification code (operations are performed in a new terminal window).
    - **Import from Desktop Client**: Select the path to your Telegram desktop client, and optionally enter a local password to import the login status.

### 3. File Download
- Enter message links (one per line) or the path to a JSON file (see documentation: https://docs.iyear.me/tdl/guide/download/).
- Configure parameters such as download directory, filename template, and number of threads.
- Click the **Start Download** button to execute the download task; check the progress in the log panel.

### 4. File Upload
- Select the files or folders you want to upload.
- Specify the target chat session (ID/Username; leave blank to use the default Saved Messages).
- Optional: Enable **Delete after Upload** or **Upload as Photo**.
- Click **Start Upload** to execute the operation.

### 5. Message Forwarding
- Enter the source (links or JSON path, one per line) and the target chat session.
- Optional: Set editing rules and forwarding mode (`direct`/`clone`).
- Configure forwarding options (silent send, ungroup, etc.).
- Click **Start Forward** to execute the operation.

## License
This project is licensed under the Apache 2.0 License. See the [LICENSE](LICENSE) file for details.

---
*Note: This is the English version of the README. For the Chinese version, refer to [README_zh.md](README_zh.md).*