# Termux proot Manager & Android Problem Solver

![Status](https://img.shields.io/badge/status-production--ready-brightgreen)
![License](https://img.shields.io/badge/license-MIT-blue)
![Bash](https://img.shields.io/badge/language-bash-red)

A comprehensive Termux automation toolkit for installing and managing multiple Linux distributions via proot, fixing Signal 9 session kills, and resolving Android/Termux compatibility issues.

**Features:**
- 🐧 Install and manage 6+ Linux distros (Debian, Ubuntu, Kali, Alpine, Arch, Fedora)
- 🖥️ Automatic XFCE desktop environment setup with X11 and VNC fallback
- ⚡ Signal 9 mitigation with phantom process control
- 🔊 Audio/PulseAudio support
- 🔧 ADB wireless debugging pairing and recovery
- 📊 Device snapshots and compatibility checks
- 🔄 Retry logic with configurable retries
- 📝 Comprehensive logging for debugging

## Table of Contents

- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [termux-superproot.sh](#termux-superproofsh)
  - [solve_problrm.sh](#solve_problrmsh)
- [Configuration](#configuration)
- [Troubleshooting](#troubleshooting)
- [Common Problems](#common-problems)
- [Contributing](#contributing)
- [License](#license)

## Prerequisites

### On Your Termux Device

1. **Termux** app installed from F-Droid or GitHub
2. **proot-distro** - Linux distribution manager
3. **ADB** (platform-tools) - For wireless debugging on your PC/host

### Recommended Optional Packages

- **Termux:X11** - For GUI display (:0)
- **Termux API** - For Android system integration
- **tigervncserver** - For VNC fallback display
- **PulseAudio** - For audio support

## Installation

### Option 1: Direct Download & Use

```bash
# On your Termux device, create a working directory
mkdir -p ~/work/termux-proot
cd ~/work/termux-proot

# Download the scripts (or clone the repo)
wget https://github.com/YOUR_USERNAME/termux-proot-manager/archive/refs/heads/main.zip
unzip main.zip
cd termux-proot-manager-main

# Make scripts executable
chmod +x termux-superproot.sh solve_problrm.sh
```

### Option 2: Clone from GitHub

```bash
cd ~/work
git clone https://github.com/YOUR_USERNAME/termux-proot-manager.git
cd termux-proot-manager
chmod +x *.sh profiles/*.sh
```

### Option 3: Install System-Wide (Optional)

```bash
# Copy to Termux bin directory for global access
cp termux-superproot.sh $PREFIX/bin/termux-superproot
cp solve_problrm.sh $PREFIX/bin/solve-problem
chmod +x $PREFIX/bin/termux-superproot $PREFIX/bin/solve-problem

# Then use from anywhere:
termux-superproot init
solve-problem auto
```

## Quick Start

### 1. Initialize Everything

```bash
bash termux-superproot.sh init
```

This installs all required packages and creates launchers.

### 2. Install a Linux Distro

```bash
bash termux-superproot.sh install debian
# or
bash termux-superproot.sh install kali
```

### 3. Start with GUI (X11)

```bash
bash termux-superproot.sh start debian
```

This will:
- Start termux-x11 on display :0
- Bootstrap XFCE desktop inside the distro
- Log you into the session

### 4. If You Hit Problems

```bash
# One-command fix (solves Signal 9, audio, animations, phantom processes):
bash solve_problrm.sh auto

# Or configure ADB wireless debugging first:
bash solve_problrm.sh config
bash solve_problrm.sh pair
bash solve_problrm.sh recover
```

## Usage

### termux-superproot.sh

**Purpose:** Manage proot Linux distros and desktop environments

```bash
bash termux-superproot.sh <command> [distro]
```

**Commands:**

| Command | Purpose | Example |
|---------|---------|---------|
| `init` | Install packages, create directories, generate launchers | `bash termux-superproot.sh init` |
| `install <distro>` | Install a proot distro | `bash termux-superproot.sh install ubuntu` |
| `nethunter` | Install Kali NetHunter rootless | `bash termux-superproot.sh nethunter` |
| `gui <distro>` | Bootstrap XFCE desktop in a distro | `bash termux-superproot.sh gui kali` |
| `launch <distro>` | Simple login to a distro | `bash termux-superproot.sh launch debian` |
| `start <distro>` | Full session with X11 and GUI | `bash termux-superproot.sh start debian` |
| `stop` | Kill related Termux/proot/X11 processes | `bash termux-superproot.sh stop` |
| `refresh-profiles` | Generate wrappers for installed distros | `bash termux-superproot.sh refresh-profiles` |
| `audio-fix <distro>` | Install audio packages | `bash termux-superproot.sh audio-fix debian` |
| `recover <distro>` | Full recovery (cleanup, audio, restart) | `bash termux-superproot.sh recover kali` |
| `status` | Show config paths and distros | `bash termux-superproot.sh status` |
| `signal9` | Print Signal 9 mitigation guide | `bash termux-superproot.sh signal9` |
| `list` | Show supported distro names | `bash termux-superproot.sh list` |

**Supported Distros:**
- `alpine`
- `archlinux`
- `debian`
- `fedora`
- `kali`
- `ubuntu`

**Output Directories:**
- `~/.termux-superproot/bin/` - Generated launchers
- `~/.termux-superproot/logs/` - Execution logs
- `./profiles/` - Per-distro wrapper scripts

---

### solve_problrm.sh

**Purpose:** ADB wireless debugging, Android settings remediation, recovery

```bash
bash solve_problrm.sh <command>
```

**Commands:**

| Command | Purpose |
|---------|---------|
| `pair` | Prompt for ADB host/port/code and establish wireless pairing |
| `connect` | Connect to a previously paired device |
| `fix [profile]` | Run remediation profile (`all`, `audio`, `signal9`, `gui`) |
| `recover` | Pair/connect with retries → fix all → snapshot |
| `auto` | One-command: checks → pair/connect → fix all → snapshot |
| `status` | Show current ADB configuration |
| `config` | Interactive configuration setup |

**Fix Profiles:**

| Profile | What It Does |
|---------|------------|
| `all` | Battery optimization, Termux whitelist, phantom process limits, animations, permissions |
| `audio` | Battery optimization, whitelist, audio routing |
| `signal9` | Battery optimization, whitelist, phantom process control, animations |
| `gui` | Animation scaling (for smoother desktop) |

**Configuration:**
- Settings saved to `~/.solve_problrm.conf`
- Logs written to `~/.solve_problrm.log`
- Retry configuration via `MAX_RETRIES` env var (default 3)

---

## Configuration

### Environment Variables

```bash
# termux-superproot.sh
export GUI_GEOMETRY="1280x720"      # X11 display size
export GUI_DEPTH="24"               # Color depth
export GUI_PORT="5901"              # VNC port (if used)
export DEFAULT_DISTRO="debian"      # Default distro for commands
export MEMORY_WARN_MB="700"         # Memory warning threshold

# solve_problrm.sh
export MAX_RETRIES="3"              # Retry attempts for ADB commands
```

### Config Files

**~/.termux-superproot/config:**
```bash
# Optional: place custom environment variables here
GUI_GEOMETRY="1024x768"
DEFAULT_DISTRO="kali"
MEMORY_WARN_MB="500"
```

**~/.solve_problrm.conf:**
```bash
ADB_HOST="192.168.0.1"
ADB_PAIR_PORT="37123"
ADB_CONNECT_PORT="5555"
ADB_PAIR_CODE=""
ADB_DEVICE_ALIAS="android"
```

## Troubleshooting

### Script fails with "This script must be run inside Termux"

**Solution:** Run the script on a Termux device, not on a PC.

### `proot-distro not installed`

**Solution:**
```bash
pkg install proot-distro
bash termux-superproot.sh init
```

### X11 never appears on screen

**Solution:**
1. Install Termux:X11: `pkg install termux-x11-nightly`
2. Ensure you have x11-repo: `pkg install x11-repo`
3. Manually start X11 app on device before running the script
4. Check available memory: `free -h`

### VNC fallback says "tigervncserver not installed"

**Solution:** Inside the distro, install VNC:
```bash
# For Debian/Ubuntu/Kali:
apt install tigervnc-standalone-server

# For Arch:
pacman -S tigervnc

# For Fedora:
dnf install tigervnc-server

# For Alpine:
apk add tigervnc
```

### ADB commands fail ("adb was not found")

**Solution:**
```bash
# Install Android SDK Platform Tools
# On Linux/Mac:
apt install android-sdk-platform-tools

# On Windows:
# Download from https://developer.android.com/studio/releases/platform-tools

# Verify:
adb version
```

### Session keeps getting killed (Signal 9)

**Solution:**
```bash
# Disable battery optimization for Termux on your device:
# Settings > Battery > Battery Saver > (find Termux) > Don't optimize

# Then run:
bash solve_problrm.sh auto

# Or manually:
bash solve_problrm.sh fix signal9
```

### Phantom process killing persists

**Solution:** Ensure the phantom process fix ran:
```bash
bash solve_problrm.sh status
bash solve_problrm.sh fix all
```

Check the log:
```bash
cat ~/.solve_problrm.log
```

### Audio not working

**Solution:**
```bash
# Install audio packages in your distro:
bash termux-superproot.sh audio-fix debian

# Or use recovery:
bash termux-superproot.sh recover debian
```

## Common Problems

See [problem.txt](problem.txt) for an exhaustive list of 17+ common issues and solutions:

- Signal 9 / SIGKILL session kills
- Audio problems (PulseAudio, routing)
- Wi-Fi and network limitations
- Bluetooth problems
- GUI startup failures
- Package installation issues
- Storage and permissions
- Performance and memory
- Keyboard input mapping
- Termux setup issues
- proot rootless constraints
- Security and isolation
- Device-specific quirks
- UX and display issues
- Recovery and debugging
- Edge cases

## Logs and Debugging

### View Logs

```bash
# termux-superproot.sh logs:
tail -f ~/.termux-superproot/logs/termux-superproot.log

# solve_problrm.sh logs:
tail -f ~/.solve_problrm.log
```

### Enable Debug Output

```bash
# Run with verbose output:
bash -x termux-superproot.sh init

# Check script syntax:
bash -n termux-superproot.sh
```

### Capture Device Snapshot

```bash
# View what was captured:
bash solve_problrm.sh status
bash solve_problrm.sh collect-snapshot  # (if implemented)

# Or check the log:
grep "adb devices -l" ~/.solve_problrm.log
```

## Contributing

Contributions are welcome! Please follow these guidelines:

1. **Fork** the repository
2. **Create a branch** for your feature (`git checkout -b feature/amazing-feature`)
3. **Make changes** and test on a real Termux device
4. **Write or update** documentation
5. **Commit** with clear messages (`git commit -am 'Add amazing feature'`)
6. **Push** to your branch (`git push origin feature/amazing-feature`)
7. **Submit a Pull Request**

### Development Tips

- Always test on both old and new Android versions
- Keep scripts POSIX-compliant (use `bash`, test with `sh`)
- Add error handling for missing commands
- Document all new environment variables
- Include examples in usage docs
- Update [CHANGELOG.md](CHANGELOG.md)

## License

This project is licensed under the **MIT License** - see [LICENSE](LICENSE) file for details.

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, subject to the inclusion of the above copyright notice and this permission notice.

## Support

- **Issues:** [GitHub Issues](https://github.com/YOUR_USERNAME/termux-proot-manager/issues)
- **Discussions:** [GitHub Discussions](https://github.com/YOUR_USERNAME/termux-proot-manager/discussions)
- **Termux Docs:** https://termux.dev

## Acknowledgments

- [proot-distro](https://github.com/termux/proot-distro) - Linux distro manager
- [Termux](https://termux.dev) - Android terminal emulator
- [Termux:X11](https://github.com/termux/termux-x11) - X11 display server

## Changelog

See [CHANGELOG.md](CHANGELOG.md) for version history and updates.

---

**Made with ❤️ for the Termux community**
