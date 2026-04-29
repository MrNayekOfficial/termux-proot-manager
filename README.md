# Termux proot Manager - README

**For comprehensive documentation, see [README_GITHUB.md](README_GITHUB.md)**

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

## Full Documentation

- **[README_GITHUB.md](README_GITHUB.md)** - Complete guide with examples
- **[docs/INSTALLATION.md](docs/INSTALLATION.md)** - Step-by-step installation
- **[docs/ADVANCED_USAGE.md](docs/ADVANCED_USAGE.md)** - Advanced features
- **[docs/PROJECT_STRUCTURE.md](docs/PROJECT_STRUCTURE.md)** - Project layout
- **[problem.txt](problem.txt)** - Problem/solution reference
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute
- **[CHANGELOG.md](CHANGELOG.md)** - Version history

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

## Status

✅ **Production Ready** - Fully tested and bug-free

---

**→ See [README_GITHUB.md](README_GITHUB.md) for comprehensive documentation**
