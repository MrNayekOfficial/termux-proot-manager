# Termux proot Manager

**Single-line download for the essential scripts and profiles:**

```bash
mkdir -p termux-proot-manager && cd termux-proot-manager && for file in termux-superproot.sh solve_problrm.sh profiles/launch.sh profiles/debian.sh profiles/kali.sh profiles/ubuntu.sh profiles/alpine.sh profiles/archlinux.sh profiles/fedora.sh; do curl -fsSL -o "$file" "https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/$file" || exit 1; done && chmod +x termux-superproot.sh solve_problrm.sh profiles/*.sh
```

This project gives visitors a simple way to download the scripts and run them in Termux.

## Visitor Quick Start

### Option 1: Clone from GitHub

```bash
pkg update -y
pkg install -y git bash

git clone https://github.com/MrNayekOfficial/termux-proot-manager.git
cd termux-proot-manager

bash termux-superproot.sh init
bash termux-superproot.sh install debian
bash termux-superproot.sh start debian
```

### Option 2: Download the script directly

```bash
pkg update -y
pkg install -y curl bash

curl -fsSL -o termux-superproot.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/termux-superproot.sh
curl -fsSL -o solve_problrm.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/solve_problrm.sh

chmod +x termux-superproot.sh solve_problrm.sh

bash termux-superproot.sh init
```

### Option 3: Download with wget

```bash
pkg update -y
pkg install -y wget bash

wget -O termux-superproot.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/termux-superproot.sh
wget -O solve_problrm.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/solve_problrm.sh

chmod +x termux-superproot.sh solve_problrm.sh
```

This project contains three main components:

1. **`termux-superproot.sh`** - Linux distro manager for Termux
   - Install and manage 6+ proot-based Linux distributions
   - Automatic XFCE desktop environment setup
   - X11 and VNC display server support
   - Audio/PulseAudio integration
   - Per-distro launcher generation

2. **`solve_problrm.sh`** - Android recovery and problem solver
   - ADB wireless debugging pairing
   - Device compatibility checks
   - Android settings remediation
   - Signal 9 and phantom process mitigation
   - Device snapshots and logging

3. **`problem.txt`** - Problem/solution reference (17 categories)
   - Signal 9 session kills
   - Audio issues
   - Network and Bluetooth
   - GUI and display failures
   - And many more...

## Quick Start

```bash
# Initialize (installs all packages)
bash termux-superproot.sh init

# Install Debian
bash termux-superproot.sh install debian

# Start with GUI
bash termux-superproot.sh start debian

# Or fix problems:
bash solve_problrm.sh auto
```

## How Visitors Use It

Visitors usually do one of these:

```bash
# Clone the repo and run the manager
git clone https://github.com/MrNayekOfficial/termux-proot-manager.git
cd termux-proot-manager
bash termux-superproot.sh init

# Or download the scripts directly without git
curl -fsSL -o termux-superproot.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/termux-superproot.sh
chmod +x termux-superproot.sh
bash termux-superproot.sh start debian
```

## Full Documentation

- `problem.txt` - Problem/solution reference
- `CONTRIBUTING.md` - How to contribute
- `CHANGELOG.md` - Version history

## Quick Workflows

### Fix Session Killing (Signal 9)

```bash
bash solve_problrm.sh config
bash solve_problrm.sh pair
bash solve_problrm.sh fix signal9
```

### One-Command Recovery

```bash
bash solve_problrm.sh auto
```

### Set Up with Audio

```bash
bash termux-superproot.sh install debian
bash termux-superproot.sh gui debian
bash termux-superproot.sh audio-fix debian
bash termux-superproot.sh start debian
```

## Requirements

- **Termux** app (F-Droid or GitHub)
- **proot-distro** (installed by init)
- **ADB** (for device fixes, optional)

## Useful Commands

```bash
# Show supported distros
bash termux-superproot.sh list

# Install and start Debian
bash termux-superproot.sh install debian
bash termux-superproot.sh start debian

# Repair Android/ADB issues
bash solve_problrm.sh config
bash solve_problrm.sh auto
```

## Status

✅ **Production Ready** - Fully tested and bug-free

---

**→ Use the commands above to get started in Termux**
