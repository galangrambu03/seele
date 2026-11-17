<div align="center">
  <img src="assets/images/seele_icon_app.png" alt="Seele Logo" width="120" style="border-radius: 20px;"/>
  <h1>Seele</h1>
  <p><b>Smart Discord Quest Manager & Dashboard</b></p>

  [![Build & Release](https://github.com/galangrambu03/seele_discord/actions/workflows/build_release.yml/badge.svg)](https://github.com/galangrambu03/seele_discord/actions)
  [![Flutter](https://img.shields.io/badge/Flutter-3.50.0-blue?logo=flutter)](https://flutter.dev)
  [![Dart](https://img.shields.io/badge/Dart-3.14.0-blue?logo=dart)](https://dart.dev)
  [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
</div>

---

## 📸 App Preview

<p align="center">
  <img src="seele_asset/iPhone-14-PRO-localhost%20(1).png" width="200" style="border-radius: 12px;" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="seele_asset/iPhone-14-PRO-localhost%20(2).png" width="200" style="border-radius: 12px;" />
  &nbsp;&nbsp;&nbsp;&nbsp;
  <img src="seele_asset/iPhone-14-PRO-localhost%20(3).png" width="200" style="border-radius: 12px;" />
  &nbsp;&nbsp;&nbsp;&nbsp;
</p>


## 📖 About Seele

**"NOTE: for iOS you need to use sideloader for installing the app."**

**Seele** is a cross-platform Flutter-based quest manager for Discord (available on Android, Windows, and iOs). It provides a custom, dark-themed dashboard to monitor your active missions. Operating completely locally, the app fetches your quest data, automates the required tasks, and stores your credentials securely on the device without relying on any external server.

## ✨ Key Features

- **Smart Mission Tracker:** Automatically syncs and categorizes your active Discord Quests.
- **Automated Task Execution:** Seamlessly completes quest requirements (like watching videos or keeping a game session active) while you focus on other things.
- **Live Dashboard:** Monitor quest progress, engine status, and background activities in real-time through the interactive **Seele Automation Console**.
- **Dynamic Mascot:** Your UI companion, Seele, reacts (`idle`, `work`, `done`) based on the current engine status.
- **Secure Authentication:** Your Discord token is encrypted and safely stored in your device's secure storage. It is never sent to any third-party servers.
- **Smart Filtering:** Hides completed or expired quests, ensuring your dashboard only shows actionable missions.
- **Cross-Platform:** Available as an APK (Android) and a Portable EXE (Windows).

## 🚀 Download & Installation

You don't need to build the app yourself. Pre-compiled versions are always available in the **Releases** tab of this repository.

1. Go to the **[Releases](../../releases)** tab on GitHub.
2. Download the file for your platform:
   - `app-release.apk` for **Android**.
   - `seele-windows.zip` for **Windows** (Extract the zip, then run `seele_discord.exe`).
3. Install or run the application.
4. Enter your **Discord Token** on the *Account* page and connect.

---

### 🔑 How to Get Your Discord Authorization Token

To connect your account, Seele requires your Discord Authorization Token. This is a standard method for third-party clients to authenticate. Here is the safest way to retrieve it:

1. Open [Discord](https://discord.com/app) in your web browser (or the Desktop App) and log in.
2. Press `F12` (or `Ctrl + Shift + I`) to open Developer Tools.
3. Go to the **Network** tab.
4. Click on your **Profile** (your avatar in the bottom left corner) to trigger network activity.
5. In the Filter box, type `@me`.
6. Click on the request named `@me` that appears.
7. On the right panel, scroll down to **Request Headers**.
8. Look for the header named **`authorization`**.
9. Copy the value (it usually starts with `mfa.` or `MT...`). 

> 🚨 **CRITICAL SECURITY WARNING:**
> - **NEVER SHARE YOUR TOKEN WITH ANYONE.** Your token is the master key to your account. Anyone with this token can access your account, read your messages, and change your settings without needing your password.
> - Seele stores this token locally using encrypted storage on your device. It is never sent to our servers.
> - If you accidentally leak your token, immediately change your Discord password. This will invalidate the old token and generate a new one.

---

## ⚠️ Disclaimer & Terms of Use

**USE AT YOUR OWN RISK.**
**Please use IP Adress / Same Device While Starting the Quest using Seele, if not there's a risk to get banned!!**

1. **Terms of Service Violation:** Using third-party automation tools, self-bots, or modified clients on a Discord account **strictly violates Discord's Terms of Service**. 
2. **Risk of Ban:** By using Seele, your account is at risk of being flagged, restricted, or **permanently banned** by Discord's anti-abuse systems. 
3. **User Responsibility:** The developers of Seele do not endorse, encourage, or take responsibility for any account bans, data loss, or damages incurred. **All risks are borne entirely by the user.**
4. **Recommendation:** It is highly recommended to use an alternate account (alt) that you do not care about losing, rather than your main account.

By downloading and using this application, you acknowledge that you have read this disclaimer and agree to take full responsibility for your actions.

---

## 🛠️ Tech Stack

- **Framework:** Flutter (Dart)
- **State Management:** `ChangeNotifier` & `ListenableBuilder`
- **Networking:** `http` package
- **Storage:** `flutter_secure_storage`
- **CI/CD:** GitHub Actions (Auto-build APK & Windows Release)

## 💻 Building from Source (For Developers)

If you want to modify the code and build it yourself, follow these steps:

1. **Clone the repository:**
   git clone https://github.com/galangrambu03/seele_discord.git
   cd seele_discord
   
2. **Install dependencies:**
   flutter pub get
   
3. **Run on Emulator/Device:**
   flutter run
   
4. **Build Manually:**
   - Android: flutter build apk --release
   - Windows: flutter build windows --release

> **Automated Release:** This project is equipped with a GitHub Actions workflow. Whenever you push a version tag (e.g., git push origin v1.0.0), GitHub will automatically compile and publish the APK + EXE to the Releases tab.

---

## 👨‍💻 Development Attribution

This project is the result of extensive manual development and problem-solving, with AI utilized strictly as a pair-programming assistant.

- **~85% Manual Development:** Architecture design, state management, UI/UX implementation, Discord API integration, debugging (Null-Safety, CORS), and CI/CD pipeline setup.
- **~15% AI-Assisted:** Assisting with syntax corrections, Dart migration from Python logic, generating tedious boilerplate code, and rubber-duck debugging.

*The core logic, feature implementations, and final code decisions were heavily driven and reviewed by the developer. AI was used as an accelerator, not the primary author.*

---

<div align="center">
  <i>"Dive into the Sea of Quanta."</i><br/><br/>
  
  Made by <b>Halsey</b><br/>
  <a href="https://github.com/galangrambu03">github.com/galangrambu03</a>
</div>
