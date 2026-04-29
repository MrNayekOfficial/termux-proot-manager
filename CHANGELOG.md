# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-04-30

### Added

**Initial Production Release**

#### termux-superproot.sh Features
- Multi-distro proot manager supporting 6 Linux distributions (Debian, Ubuntu, Kali, Alpine, Arch, Fedora)
- Automatic XFCE desktop environment installation and configuration
- X11 display server support (:0) with automatic environment variable setup
- VNC fallback support (:1) when X11 unavailable
- PulseAudio audio support and bootstrap
- Per-distro launcher generation in `profiles/` directory
- Generic `launch.sh` wrapper for any installed distro
- Memory availability checks with configurable warnings
- Process cleanup and kill functionality with safe fallback
- Kali NetHunter rootless installation support
- Configuration file support (`~/.termux-superproot/config`)
- Comprehensive logging to `~/.termux-superproot/logs/termux-superproot.log`
- 12 commands: init, install, nethunter, gui, launch, start, stop, refresh-profiles, audio-fix, recover, status, signal9, list

#### solve_problrm.sh Features
- ADB wireless debugging pairing (adb pair / adb connect)
- Device compatibility checks and snapshots
- Android settings remediation profiles (all, audio, signal9, gui)
- Phantom process control (max_phantom_processes: 2147483647, disable monitoring)
- Battery optimization bypass
- Termux app whitelisting
- Animation scaling for performance
- Retry logic with configurable MAX_RETRIES (default 3)
- Configuration persistence to `~/.solve_problrm.conf`
- Detailed logging to `~/.solve_problrm.log`
- 7 commands: pair, connect, fix, recover, auto, status, config

#### Documentation
- Comprehensive README with quick start guide
- problem.txt with 17+ common issues and solutions
- Inline command help (--help / help flags)
- Configuration examples and environment variable docs
- Troubleshooting section
- Contributing guidelines

#### Code Quality
- Strict bash error handling (`set -Eeuo pipefail`)
- Input validation and error messages
- Proper variable scoping and quoting
- Fallback mechanisms for optional components
- Cross-platform compatibility (Linux, macOS, WSL)

#### Bug Fixes (Initial Release)
1. Fixed config loading to only log on success
2. Fixed log directory fallback to use direct variable
3. Fixed pkill signal syntax in process cleanup
4. Fixed ADB command piping with proper error handling
5. Fixed retry_step failure logging

### Changed

### Deprecated

### Removed

### Fixed

### Security

---

## [Unreleased]

### Planned Features
- Graphical launcher (GUI wrapper)
- Automated testing suite
- Docker container option
- One-click installers for different Android versions
- Performance profiling and optimization
- Keyboard input mapping helpers
- GPU acceleration exploration
- Full Bluetooth audio support

### Known Limitations
- Signal 9 cannot be completely eliminated (Android kernel-level)
- Audio/Bluetooth/Wi-Fi device-dependent due to proot rootless constraints
- GPU acceleration limited by proot constraints
- Keyboard input mapping requires manual setup
- Some Android settings may not persist across device reboot

---

## Notes

### Testing Matrix
- ✅ Tested on Termux (latest)
- ✅ Tested with proot-distro latest
- ✅ Tested on Android 11, 12, 13
- ⏳ Pending: Android 14+, alternative Termux builds

### Backward Compatibility
- v1.0.0 establishes initial stable API
- Future versions will maintain script command compatibility
- Config file format may evolve with migration guides provided

### Contributors
- Initial development and testing
