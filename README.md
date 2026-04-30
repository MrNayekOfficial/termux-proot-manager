# Termux proot Manager

I built this repo for people who want a direct Termux setup without chasing scattered commands. It keeps the Linux setup, recovery steps, and common fixes in one place.

## One-line download

Use this if you want the essential scripts and profile launchers in one go:

```bash
mkdir -p termux-proot-manager && cd termux-proot-manager && for file in termux-superproot.sh solve_problrm.sh profiles/launch.sh profiles/debian.sh profiles/kali.sh profiles/ubuntu.sh profiles/alpine.sh profiles/archlinux.sh profiles/fedora.sh; do curl -fsSL -o "$file" "https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/$file" || exit 1; done && chmod +x termux-superproot.sh solve_problrm.sh profiles/*.sh
```

If you prefer to clone the whole repo, use the quick start below.

## Quick Start

```bash
pkg update -y
pkg install -y git bash

git clone https://github.com/MrNayekOfficial/termux-proot-manager.git
cd termux-proot-manager

bash termux-superproot.sh init
bash termux-superproot.sh install debian
bash termux-superproot.sh start debian
```

If you already have the scripts locally, you can also download them directly:

```bash
pkg update -y
pkg install -y curl bash

curl -fsSL -o termux-superproot.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/termux-superproot.sh
curl -fsSL -o solve_problrm.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/solve_problrm.sh

chmod +x termux-superproot.sh solve_problrm.sh
bash termux-superproot.sh init
```

## What’s in this repo

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

## Everyday usage

```bash
# Install or refresh dependencies
bash termux-superproot.sh init

# Install and start a distro
bash termux-superproot.sh install debian
bash termux-superproot.sh start debian

# Repair Android/ADB issues
bash solve_problrm.sh config
bash solve_problrm.sh auto

# See supported distro names
bash termux-superproot.sh list
```

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

## More details

- `docs/USAGE.md` - Step-by-step usage guide
- `problem.txt` - Problem/solution reference
- `CONTRIBUTING.md` - How to contribute
- `CHANGELOG.md` - Version history

## Status

The repo is kept lightweight on purpose. The scripts are meant to be copied, run, and adjusted for your device.

---

**→ Start with the one-line download or the quick start block above**
