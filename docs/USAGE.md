# Usage Guide

This guide shows practical ways to use this project on Android Termux.

## 1. Requirements

- Termux installed (prefer F-Droid build)
- Internet connection
- Enough free storage for Linux rootfs
- Optional for device fixes: ADB available in your environment

## 2. Get the project

### Option A: Clone repository

```bash
pkg update -y
pkg install -y git bash

git clone https://github.com/MrNayekOfficial/termux-proot-manager.git
cd termux-proot-manager
```

### Option B: Download essential files only

```bash
pkg update -y
pkg install -y curl bash

mkdir -p termux-proot-manager
cd termux-proot-manager

curl -fsSL -o termux-superproot.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/termux-superproot.sh
curl -fsSL -o solve_problrm.sh https://raw.githubusercontent.com/MrNayekOfficial/termux-proot-manager/main/solve_problrm.sh

chmod +x termux-superproot.sh solve_problrm.sh
```

## 3. Main Linux manager (`termux-superproot.sh`)

### First run (interactive menu)

```bash
bash termux-superproot.sh
```

This opens a menu where you can:

1. Initialize dependencies
2. Install a Linux distro
3. Start a distro session
4. Install + start in one flow

### Non-interactive commands

```bash
# Install base packages and generate launchers
bash termux-superproot.sh init

# Show supported distro names
bash termux-superproot.sh list

# Install distro
bash termux-superproot.sh install debian

# Setup GUI packages in distro
bash termux-superproot.sh gui debian

# Start full session (X11 or VNC fallback)
bash termux-superproot.sh start debian

# Open distro shell directly
bash termux-superproot.sh launch debian

# Install audio packages inside distro
bash termux-superproot.sh audio-fix debian

# Stop related background processes
bash termux-superproot.sh stop

# Recover from broken session
bash termux-superproot.sh recover debian
```

### NetHunter rootless

```bash
bash termux-superproot.sh nethunter
```

## 4. Android/ADB fixer (`solve_problrm.sh`)

Use this script when Android keeps killing sessions, ADB is unstable, or system settings need tuning.

### Configure and connect

```bash
# Save host/ports/pair code
bash solve_problrm.sh config

# Pair wireless debugging
bash solve_problrm.sh pair

# Connect to saved host:port
bash solve_problrm.sh connect
```

### Run fixes

```bash
# Full fix profile
bash solve_problrm.sh fix

# Specific profile
bash solve_problrm.sh fix signal9
bash solve_problrm.sh fix audio
bash solve_problrm.sh fix gui
```

### Recovery and automation

```bash
# Pair/connect with retries then run fix
bash solve_problrm.sh recover

# Compatibility checks + connect + fix + snapshot
bash solve_problrm.sh auto

# Print current config
bash solve_problrm.sh status
```

## 5. Typical workflows

### Install and launch Debian with GUI

```bash
bash termux-superproot.sh init
bash termux-superproot.sh install debian
bash termux-superproot.sh gui debian
bash termux-superproot.sh start debian
```

### Fix session killing (Signal 9)

```bash
bash solve_problrm.sh connect
bash solve_problrm.sh fix signal9
```

### Quick full repair

```bash
bash solve_problrm.sh auto
```

## 6. Troubleshooting

- If you see mirror warnings in Termux, run:

```bash
termux-change-repo
```

- If GUI does not open, run fallback path:

```bash
bash termux-superproot.sh gui debian
bash termux-superproot.sh start debian
```

- If ADB says no device connected:

```bash
bash solve_problrm.sh connect
bash solve_problrm.sh fix
```

- If Termux sessions are killed in background:

```bash
bash termux-superproot.sh signal9
```

Then disable battery optimization for Termux from Android settings.

## 7. Helpful files

- `README.md` for overview
- `problem.txt` for issue reference
- `profiles/*.sh` launch wrappers for installed distros
