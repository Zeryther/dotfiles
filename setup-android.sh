set -e

# Optional setup for Android/Expo dev builds on WSL
# Based on: https://medium.com/@danielrauhut/running-expo-dev-builds-from-wsl-on-your-windows-virtual-devices-android-emulator-bd7cc7e29418
#
# Prerequisites:
#   - Android Studio installed on Windows with at least one Virtual Device
#   - run setup.sh first (for stow, zsh, etc.)
#
# What this does:
#   1. Installs JDK 17 on WSL
#   2. Downloads and sets up Android command-line tools on WSL
#   3. Installs required SDK packages (platforms, build-tools)
#   4. Symlinks Windows platform-tools into WSL SDK (for adb bridge)
#   5. Copies .exe files to extension-less counterparts on Windows side
#      so WSL can invoke them without the .exe suffix

ANDROID_SDK_DIR="$HOME/android_sdk"
CMDLINE_TOOLS_URL="https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip"

# Auto-detect Windows username from the existing path in .zshrc
WIN_USER="zeryt"
WIN_SDK="/mnt/c/Users/$WIN_USER/AppData/Local/Android/Sdk"

# --- Verify Windows SDK exists ---
if [[ ! -d "$WIN_SDK/platform-tools" ]]; then
	echo "!! Windows Android SDK not found at $WIN_SDK"
	echo "   Make sure Android Studio is installed and SDK Platform-Tools are downloaded."
	exit 1
fi

# --- Install JDK 17 ---
if ! java -version 2>&1 | grep -q '17\.'; then
	echo ">> Installing JDK 17..."
	sudo apt-get update -qq
	sudo apt-get install -y openjdk-17-jdk
else
	echo ">> JDK 17 already installed."
fi

export JAVA_HOME="/usr/lib/jvm/java-17-openjdk-amd64"

# --- Download and set up Android command-line tools ---
if [[ ! -d "$ANDROID_SDK_DIR/cmdline-tools/latest/bin" ]]; then
	echo ">> Setting up Android command-line tools..."
	mkdir -p "$ANDROID_SDK_DIR"

	TMPZIP=$(mktemp /tmp/cmdline-tools-XXXXXX.zip)
	curl -fsSL "$CMDLINE_TOOLS_URL" -o "$TMPZIP"

	unzip -qo "$TMPZIP" -d "$ANDROID_SDK_DIR"
	rm -f "$TMPZIP"

	# The archive extracts to cmdline-tools/ — sdkmanager expects cmdline-tools/latest/
	if [[ -d "$ANDROID_SDK_DIR/cmdline-tools/bin" && ! -d "$ANDROID_SDK_DIR/cmdline-tools/latest" ]]; then
		TMPDIR=$(mktemp -d)
		mv "$ANDROID_SDK_DIR/cmdline-tools" "$TMPDIR/latest"
		mkdir -p "$ANDROID_SDK_DIR/cmdline-tools"
		mv "$TMPDIR/latest" "$ANDROID_SDK_DIR/cmdline-tools/latest"
		rmdir "$TMPDIR"
	fi
else
	echo ">> Android command-line tools already set up."
fi

export ANDROID_HOME="$ANDROID_SDK_DIR"
export PATH="$ANDROID_SDK_DIR/cmdline-tools/latest/bin:$PATH"

# --- Install SDK packages ---
echo ">> Installing SDK packages (platforms;android-35, build-tools;35.0.0)..."
yes | sdkmanager "platforms;android-35" "build-tools;35.0.0" 2>/dev/null || true

echo ">> Accepting all SDK licenses..."
yes | sdkmanager --licenses 2>/dev/null || true

# --- Symlink Windows platform-tools into WSL SDK ---
if [[ -d "$ANDROID_SDK_DIR/platform-tools" && ! -L "$ANDROID_SDK_DIR/platform-tools" ]]; then
	echo ">> Removing WSL-native platform-tools (will symlink to Windows instead)..."
	rm -rf "$ANDROID_SDK_DIR/platform-tools"
fi

if [[ ! -e "$ANDROID_SDK_DIR/platform-tools" ]]; then
	echo ">> Symlinking Windows platform-tools into WSL SDK..."
	ln -s "$WIN_SDK/platform-tools" "$ANDROID_SDK_DIR/platform-tools"
else
	echo ">> platform-tools symlink already exists."
fi

# --- Copy .exe files to extension-less counterparts on Windows side ---
# This allows WSL to call `adb` and `emulator` (without .exe) through the mount.
echo ">> Creating extension-less copies of Windows executables..."

copy_exe_to_noext() {
	local dir="$1"
	local count=0

	for exe in "$dir"/*.exe; do
		[[ -f "$exe" ]] || continue
		local noext="${exe%.exe}"
		if [[ ! -f "$noext" ]]; then
			cp "$exe" "$noext"
			count=$((count + 1))
		fi
	done

	echo "   $dir: $count new copies created"
}

copy_exe_to_noext "$WIN_SDK/platform-tools"
copy_exe_to_noext "$WIN_SDK/emulator"

# --- Done ---
echo ""
echo ">> Android/Expo WSL setup complete!"
echo ""
echo "   Your .zshrc already has the required environment variables:"
echo "     ANDROID_HOME=$ANDROID_SDK_DIR"
echo "     ADB_SERVER_SOCKET=tcp:localhost:5037"
echo "     PATH includes cmdline-tools and platform-tools"
echo ""
echo "   To start an emulator from WSL:"
echo "     $WIN_SDK/emulator/emulator -avd <device_name>"
echo ""
echo "   To list available devices:"
echo "     $WIN_SDK/emulator/emulator -list-avds"
echo ""
echo "   Then run your Expo dev build:"
echo "     npx expo run:android"
