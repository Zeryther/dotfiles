# dotfiles

Personal dotfiles for WSL (Ubuntu) on Windows, managed with [GNU Stow](https://www.gnu.org/software/stow/).

## Structure

```
dotfiles/
  bash/.bashrc          # Bash config (stowed to ~/.bashrc)
  zsh/.zshrc            # Zsh config (stowed to ~/.zshrc)
  git/.gitconfig        # Git config (stowed to ~/.gitconfig)
  win/                  # Windows-side PowerShell scripts (deprecated)
  setup.sh              # Base WSL setup (dependencies, stow links, shell)
  setup-android.sh      # Optional Android/Expo dev environment setup
```

## Setup

### Base

```sh
./setup.sh
```

Installs core dependencies (`stow`, `zsh`, `zoxide`, `nvm`, Oh My Zsh, Homebrew), symlinks all dotfiles via `stow`, and sets zsh as the default shell.

### Windows-side `.wslconfig`

The following must be set manually in `C:\Users\<username>\.wslconfig` on the Windows side (this file is not managed by this repo):

```ini
[wsl2]
memory=12GB
swap=8GB
# Required for Expo dev server in WSL to be reachable from the Android emulator.
# Makes WSL share the Windows host's network stack so localhost is the same everywhere.
networkingMode=mirrored
```

`networkingMode=mirrored` is critical for Android development -- see [Android/Expo dev server connectivity](#androidexpo-dev-server-connectivity) below. A WSL restart (`wsl.exe --shutdown`) is required after changing this file.

### Android / Expo (optional)

```sh
./setup-android.sh
```

Sets up a full Android build environment on WSL for running Expo dev builds on the Windows-side Android emulator. Based on [this guide](https://medium.com/@danielrauhut/running-expo-dev-builds-from-wsl-on-your-windows-virtual-devices-android-emulator-bd7cc7e29418).

**Windows-side prerequisites:**

- Android Studio installed with at least one Virtual Device created
- SDK Platform-Tools installed (Android Studio > More Actions > SDK Manager > SDK Tools tab)

**What the script does:**

1. Installs JDK 17 on WSL (requires `sudo`)
2. Downloads Android command-line tools for Linux and sets up the `cmdline-tools/latest/` directory structure that `sdkmanager` expects
3. Installs SDK packages (`platforms;android-35`, `build-tools;35.0.0`) and accepts all licenses
4. Removes WSL-native `platform-tools` and symlinks the Windows-side `platform-tools` into `~/android_sdk/` -- this is what lets `adb` in WSL talk to the emulator on Windows
5. Copies all `.exe` files in the Windows-side `platform-tools/` and `emulator/` directories to extension-less counterparts (e.g. `adb.exe` -> `adb`) so WSL can invoke them without the `.exe` suffix

**After setup, to run a dev build:**

```sh
# List available emulators
/mnt/c/Users/<username>/AppData/Local/Android/Sdk/emulator/emulator -list-avds

# Start an emulator
/mnt/c/Users/<username>/AppData/Local/Android/Sdk/emulator/emulator -avd <device_name>

# Run the Expo dev build (from your project directory)
npx expo run:android
```

## How the Android/WSL bridge works

The setup involves a few moving parts that are easy to forget about. This section documents what each piece does and why.

### Build environment

Expo builds happen entirely on the WSL side. `ANDROID_HOME` points to `~/android_sdk` which contains the command-line tools, build-tools, and platform definitions installed natively on Linux. This avoids the problems that arise from trying to build using the Windows-side SDK mounted via `/mnt/c/` (wrong binaries, permission issues, path format mismatches).

### adb bridge to Windows emulator

The WSL SDK's `platform-tools/` directory is a symlink to the Windows-side `platform-tools/`. This means when Expo calls `adb`, it actually runs the Windows `adb.exe` (via the extension-less copy), which can natively communicate with the Windows-side emulator. The environment variable `ADB_SERVER_SOCKET=tcp:localhost:5037` in `.zshrc` tells the Android toolchain to connect to the adb server over TCP on localhost rather than looking for a Unix socket.

### Windows .exe extension-less copies

WSL can execute Windows `.exe` files through the `/mnt/c/` mount, but the Android toolchain calls binaries by name without the `.exe` extension (e.g. it looks for `adb`, not `adb.exe`). The setup script copies each `.exe` to a file with the same name minus the extension so these lookups succeed.

### Android/Expo dev server connectivity

This was the trickiest part to debug. Even after a successful build and install, the app on the emulator couldn't connect back to the Expo dev server running in WSL. The root cause is a two-part networking problem:

**Problem 1: WSL2 network isolation.** WSL2 runs in a lightweight VM with its own virtual network adapter. By default, `localhost` inside the Windows host (where the emulator runs) does not reach `localhost` inside WSL (where the dev server runs). The fix is `networkingMode=mirrored` in `.wslconfig`, which makes WSL share the Windows host's network stack. With this, `localhost` is the same everywhere.

**Problem 2: Expo advertises the wrong IP.** Even with mirrored networking, Expo auto-detects the machine's LAN IP (e.g. `192.168.178.25`) and tells the app to connect to that address. The Android emulator runs behind its own NAT (`10.0.2.x`) and can't reach LAN IPs directly. It can only reach the host via the special address `10.0.2.2`, which maps to the host's `localhost`. The fix is `REACT_NATIVE_PACKAGER_HOSTNAME=localhost` in `.zshrc`, which tells Expo to advertise `localhost` instead of the LAN IP.

**The full chain:** App on emulator -> `localhost:8081` -> emulator NAT resolves to `10.0.2.2:8081` -> host `localhost:8081` -> (mirrored networking) -> WSL `localhost:8081` -> Expo dev server.

### Environment variables summary

All set in `zsh/.zshrc`:

| Variable | Value | Why |
|---|---|---|
| `JAVA_HOME` | `/usr/lib/jvm/java-17-openjdk-amd64` | Gradle/Android build toolchain needs JDK 17 |
| `ANDROID_HOME` | `~/android_sdk` | Points to the WSL-native SDK (build-tools, platforms, symlinked platform-tools) |
| `ADB_SERVER_SOCKET` | `tcp:localhost:5037` | Connects to adb over TCP instead of Unix socket |
| `REACT_NATIVE_PACKAGER_HOSTNAME` | `localhost` | Forces Expo to advertise localhost so the emulator can reach it |
