# Installation Guide

Complete step-by-step installation instructions for different setups.

## Table of Contents

1. [Fresh Termux Installation](#fresh-termux-installation)
2. [Existing Termux Setup](#existing-termux-setup)
3. [System-Wide Installation](#system-wide-installation)
4. [Development Installation](#development-installation)

## Fresh Termux Installation

### Step 1: Install Termux

Download from:
- **F-Droid** (recommended): https://f-droid.org/en/packages/com.termux/
- **GitHub Releases**: https://github.com/termux/termux-app/releases

### Step 2: Initial Setup

```bash
# Update package manager
pkg update && pkg upgrade -y

# Install essential tools
pkg install -y git curl wget bash
```

### Step 3: Clone Repository

```bash
# Create workspace
mkdir -p ~/projects
cd ~/projects

# Clone the repository
git clone https://github.com/YOUR_USERNAME/termux-proot-manager.git
cd termux-proot-manager

# Make scripts executable
chmod +x *.sh
chmod +x profiles/*.sh
```

### Step 4: Initialize

```bash
# Run initialization (installs all dependencies)
bash termux-superproot.sh init

# Check status
bash termux-superproot.sh status
```

### Step 5: Install Your First Distro

```bash
# Install Debian (lightweight)
bash termux-superproot.sh install debian

# Or Kali (for security tools)
bash termux-superproot.sh install kali

# Or Ubuntu (full-featured)
bash termux-superproot.sh install ubuntu
```

### Step 6: Start Using It

```bash
# Set up GUI in Debian
bash termux-superproot.sh gui debian

# Start a full session
bash termux-superproot.sh start debian
```

## Existing Termux Setup

If you already have Termux with some packages installed:

### Step 1: Add Repository Files

```bash
# Go to your workspace
cd ~/projects
git clone https://github.com/YOUR_USERNAME/termux-proot-manager.git
```

### Step 2: Check Prerequisites

```bash
# Verify proot-distro is installed
proot-distro list

# If not installed:
pkg install proot-distro
```

### Step 3: Run Init (Selective)

```bash
cd termux-proot-manager

# Option A: Full initialization (safest)
bash termux-superproot.sh init

# Option B: Just check status
bash termux-superproot.sh status

# Option C: Just refresh profiles for installed distros
bash termux-superproot.sh refresh-profiles
```

### Step 4: Continue as Above

Pick any distro and start using it.

## System-Wide Installation

Make scripts available globally:

### Step 1: Copy to bin

```bash
cd ~/projects/termux-proot-manager

# Copy scripts
cp termux-superproot.sh $PREFIX/bin/termux-superproot
cp solve_problrm.sh $PREFIX/bin/solve-problem
cp -r profiles/ $PREFIX/share/termux-proot/

# Make executable
chmod +x $PREFIX/bin/termux-superproot
chmod +x $PREFIX/bin/solve-problem
chmod +x $PREFIX/share/termux-proot/profiles/*.sh
```

### Step 2: Use from Anywhere

```bash
# From any directory:
termux-superproot init
termux-superproot install debian
termux-superproot start debian

solve-problem auto
```

### Step 3: View System Logs

```bash
# Logs are still in home:
tail -f ~/.termux-superproot/logs/termux-superproot.log
tail -f ~/.solve_problrm.log
```

## Development Installation

For developers contributing to the project:

### Step 1: Fork on GitHub

1. Go to https://github.com/YOUR_USERNAME/termux-proot-manager
2. Click "Fork"
3. Clone your fork:

```bash
git clone https://github.com/YOUR_GITHUB_USERNAME/termux-proot-manager.git
cd termux-proot-manager

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/termux-proot-manager.git
```

### Step 2: Create Development Branch

```bash
git checkout -b feature/my-feature
```

### Step 3: Test Your Changes

```bash
# Syntax check
bash -n termux-superproot.sh
bash -n solve_problrm.sh

# Test on device
bash termux-superproot.sh init
bash termux-superproot.sh install debian
bash termux-superproot.sh status
```

### Step 4: Commit and Push

```bash
git add .
git commit -m "feat: Add my awesome feature"
git push origin feature/my-feature
```

### Step 5: Create Pull Request

1. Go to your fork on GitHub
2. Click "Pull Request"
3. Describe your changes
4. Submit!

## Troubleshooting Installation

### "Command not found: proot-distro"

```bash
# Install it first
pkg install proot-distro

# Then run init
bash termux-superproot.sh init
```

### "Permission denied" when running scripts

```bash
# Make scripts executable
chmod +x termux-superproot.sh solve_problrm.sh
chmod +x profiles/*.sh
```

### Git clone fails

```bash
# Ensure git is installed
pkg install git

# Try HTTPS (may work better than SSH)
git clone https://github.com/...
```

### Script fails immediately

```bash
# Check you're in Termux (not Linux shell)
echo $PREFIX

# Should output something like: /data/data/com.termux/files/usr

# If empty, you're not in Termux. Exit and relaunch Termux app.
```

## Next Steps

1. Read [Quick Start](../README.md#quick-start)
2. Check [Configuration](../README.md#configuration)
3. Review [Common Problems](../problem.txt)
4. Join discussions on GitHub

## Additional Resources

- Termux Wiki: https://wiki.termux.com
- proot-distro: https://github.com/termux/proot-distro
- Bash Guide: https://mywiki.wooledge.org/BashGuide
