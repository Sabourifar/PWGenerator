# 🔐 PWGenerator

A lightweight, interactive PowerShell CLI tool for generating cryptographically secure and customizable passwords.

⚡ Generate cryptographically secure passwords, choose custom character sets, regenerate instantly, and optionally save passwords or login details locally — all from one interactive menu.

## ✨ Features

- 🛡️ Generates passwords using `System.Security.Cryptography.RandomNumberGenerator` instead of basic pseudo-random generators
- 📏 Supports password lengths from `4` to `80` characters
- 🔠 Secure password mode with uppercase, lowercase, numbers, and symbols enabled automatically
- 🎛️ Custom password mode with yes/no selection for each character set
- 🎲 Distributes characters across selected sets and securely shuffles the final password
- 💾 Saves generated passwords to `Passwords.txt`
- 🏷️ Optional save with login info: `Title`, `Username`, and `Password`
- 🖥️ Clean interactive console menu with UTF-8 symbols

## 📋 Requirements

- 🪟 Windows 10/11 or Windows Server 2016+
- 💻 PowerShell 5.1 built into Windows, or PowerShell 7+
- 🔓 No administrator rights required

## 🚀 Getting started

Windows tags every file downloaded from the internet with a "Mark of the Web," and by default PowerShell blocks unsigned scripts carrying that tag. The one-time command below removes that friction permanently for your user account, so you never have to think about it again.

### 1️⃣ One-time setup — do this once, ever

Open any PowerShell window and run:

```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Bypass -Force
```

No admin rights needed — this only affects your own user account, not the whole machine. **Trade-off, stated plainly:** this tells Windows to stop checking execution policy and Mark-of-the-Web on *any* `.ps1` script you run from now on, not just this one. If you'd rather keep more protection, use `RemoteSigned` instead of `Bypass` — but then you'll need to run `Unblock-File .\PWGenerator.ps1` once per downloaded copy of the script, since `RemoteSigned` still blocks unsigned scripts carrying the Mark of the Web.

### 2️⃣ Running it

1. 📥 Download the latest version of `PWGenerator.ps1` from the [Releases](../../releases) page into any folder.
2. ▶️ Right-click it → **Run with PowerShell**. Do this any time you want to open the tool.
3. ✅ No UAC prompt needed — the tool only generates passwords and writes to `Passwords.txt` next to the script.

That one-time setup step is what makes step 2 always work cleanly, with no errors or prompts, every time you run it. 🎉

## 🎮 Usage

Once running, use the number keys shown in the menu:

### Main menu

- `1` — Secure password, recommended: uses uppercase, lowercase, numbers, and symbols
- `2` — Custom password: choose length and character sets yourself
- `0` — Quit

### After a password is generated

- `1` — Generate another password with the same settings
- `2` — Save password to `Passwords.txt`
- `3` — Save with login info: title, username, and password
- `Enter` — Back to main menu
- `0` — Quit

### During custom password setup

- Enter a length from `4` to `80`
- Answer `Y` or `N` for uppercase, lowercase, numbers, and symbols
- Press `Enter` to go back
- Type `0` to quit

## 📝 Notes

- 🔐 `Passwords.txt` stores everything in plain text. Keep the file secure, or avoid using the save feature for sensitive accounts.
- 📁 The save file is created next to `PWGenerator.ps1`. If that folder is protected, move the script to a writable folder such as Documents or Desktop.
- 🧮 Password generation uses .NET `RandomNumberGenerator`, not a simple pseudo-random generator.
- 🔁 When multiple character sets are selected, the script distributes characters across the selected sets and then securely shuffles the final password.
- 🧰 For important credentials, consider using a dedicated encrypted password manager instead of a local text file.

## 📄 License

MIT — see [LICENSE](LICENSE).
