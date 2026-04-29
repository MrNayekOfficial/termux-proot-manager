# Advanced Usage Guide

Advanced topics and deep dives into script capabilities.

## Table of Contents

1. [Custom Configuration](#custom-configuration)
2. [Multiple Distros](#multiple-distros)
3. [Automation & Scripting](#automation--scripting)
4. [Performance Tuning](#performance-tuning)
5. [Debugging](#debugging)
6. [Custom Launchers](#custom-launchers)

## Custom Configuration

### Environment Variables

Set these before running scripts:

```bash
# GUI settings
export GUI_GEOMETRY="1024x768"
export GUI_DEPTH="16"
export GUI_PORT="5902"

# Distro
export DEFAULT_DISTRO="ubuntu"

# Memory
export MEMORY_WARN_MB="500"

# Retry behavior
export MAX_RETRIES="5"

# Then run
bash termux-superproot.sh start
```

### Config Files

Create `~/.termux-superproot/config`:

```bash
# ~/.termux-superproot/config
GUI_GEOMETRY="1920x1080"
DEFAULT_DISTRO="kali"
MEMORY_WARN_MB="600"
```

### ADB Configuration

Create `~/.solve_problrm.conf`:

```bash
# ~/.solve_problrm.conf
ADB_HOST="192.168.1.100"
ADB_PAIR_PORT="37123"
ADB_CONNECT_PORT="5555"
ADB_DEVICE_ALIAS="work-phone"
```

## Multiple Distros

### Install Multiple

```bash
# Install several
bash termux-superproot.sh install debian
bash termux-superproot.sh install ubuntu
bash termux-superproot.sh install kali
bash termux-superproot.sh install alpine

# Check what's installed
bash termux-superproot.sh status

# See profiles generated
ls profiles/
```

### Switch Between Distros

```bash
# Direct login (lightweight)
bash profiles/debian.sh
bash profiles/ubuntu.sh
bash profiles/kali.sh

# Full GUI session
bash termux-superproot.sh start ubuntu

# Generic launcher (pass distro name)
bash profiles/launch.sh debian
```

### Share Storage Between Distros

All distros share Termux's `--shared-tmp` and `--termux-home`:

```bash
# Create shared data directory
mkdir ~/shared-data

# Access from any distro
bash termux-superproot.sh launch debian

# Inside Debian, see Termux home
ls ~/
cd /data/data/com.termux/files/home
ls shared-data/
```

## Automation & Scripting

### Create Custom Launcher Scripts

```bash
#!/bin/bash
# ~/.local/bin/start-dev-env

cd ~/projects/termux-proot-manager

# Start audio
bash termux-superproot.sh audio-fix debian

# Start session
bash termux-superproot.sh start debian
```

Make executable:
```bash
chmod +x ~/.local/bin/start-dev-env
```

### Batch Fix Multiple Devices

```bash
#!/bin/bash
# fix-all-devices.sh

for device in phone tablet pi; do
  echo "Fixing $device..."
  ADB_DEVICE_ALIAS="$device" bash solve_problrm.sh auto
done
```

### Cron-like Tasks (via Termux:Boot)

Install Termux:Boot, create:

```bash
# ~/.termux/boot/termux-proot-startup.sh

#!/bin/bash
cd ~/projects/termux-proot-manager

# Keep-alive tasks
while true; do
  sleep 300
  bash termux-superproot.sh status > /dev/null 2>&1
done
```

## Performance Tuning

### Lower Memory Usage

```bash
# Reduce geometry
export GUI_GEOMETRY="800x600"
export GUI_DEPTH="16"

# Use lighter distro
bash termux-superproot.sh install alpine

# Start with animation disabled
bash solve_problrm.sh fix gui
bash termux-superproot.sh start alpine
```

### Optimize for Slow Devices

```bash
# Check memory first
free -h

# Lower thresholds
export MEMORY_WARN_MB="300"

# Install minimal GUI
# (Use Alpine + XFCE instead of Ubuntu + GNOME)
```

### Enable CPU Governor

Inside distro:
```bash
# Check available governors
cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_governors

# Set to performance (if available and not too hot)
echo "performance" | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
```

## Debugging

### Enable Verbose Output

```bash
# Run with debug shell
bash -x termux-superproot.sh init 2>&1 | tee debug.log

# Check first 50 lines
bash -x termux-superproot.sh init 2>&1 | head -50
```

### Check Logs

```bash
# termux-superproot.sh
tail -f ~/.termux-superproot/logs/termux-superproot.log

# solve_problrm.sh
tail -f ~/.solve_problrm.log

# Search for errors
grep -i error ~/.termux-superproot/logs/*
grep -i error ~/.solve_problrm.log
```

### Syntax Validation

```bash
# Check bash syntax
bash -n termux-superproot.sh
bash -n solve_problrm.sh

# Check for shellcheck issues (if installed)
pkg install shellcheck
shellcheck termux-superproot.sh
```

### Test Individual Functions

```bash
# Source script and call function
source termux-superproot.sh

# Test function manually
check_memory
show_status
need_cmd adb
```

### Capture Device State

```bash
# Snapshot before fix
bash solve_problrm.sh status > before.txt
adb shell dumpsys battery >> before.txt

# Run fix
bash solve_problrm.sh auto

# Snapshot after
bash solve_problrm.sh status > after.txt
adb shell dumpsys battery >> after.txt

# Compare
diff before.txt after.txt
```

## Custom Launchers

### Create a Shortcut Launcher

```bash
#!/bin/bash
# ~/.local/bin/kali-gui

SCRIPT_DIR="$HOME/projects/termux-proot-manager"
cd "$SCRIPT_DIR"

# Optional: Pre-run fixes
bash solve_problrm.sh fix signal9

# Start
bash termux-superproot.sh start kali
```

### Add to Termux Widget

Create in `~/.shortcuts/`:

```bash
# ~/.shortcuts/Kali GUI.sh
#!/bin/bash
cd ~/projects/termux-proot-manager
bash termux-superproot.sh start kali
```

Then use Termux Widget app to create home screen shortcut.

### Full CI/CD-like Recovery Script

```bash
#!/bin/bash
# ~/.local/bin/full-recovery.sh

set -e

echo "🔧 Running full recovery..."

cd ~/projects/termux-proot-manager

# Phase 1: Device checks
echo "📱 Checking device..."
bash solve_problrm.sh config

# Phase 2: ADB setup
echo "🔌 Setting up ADB..."
bash solve_problrm.sh pair

# Phase 3: Android fixes
echo "⚙️  Applying Android fixes..."
bash solve_problrm.sh fix all

# Phase 4: Distro preparation
echo "🐧 Preparing distro..."
bash termux-superproot.sh install debian
bash termux-superproot.sh gui debian

# Phase 5: Audio setup
echo "🔊 Setting up audio..."
bash termux-superproot.sh audio-fix debian

# Phase 6: Session start
echo "✨ Starting session..."
bash termux-superproot.sh start debian

echo "✅ Recovery complete!"
```

Run:
```bash
chmod +x ~/.local/bin/full-recovery.sh
full-recovery.sh
```

---

For more info, see [README.md](../README.md) and [problem.txt](../problem.txt).
