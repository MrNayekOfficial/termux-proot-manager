# Security Policy

## Reporting Security Issues

**Do not** open public GitHub issues for security vulnerabilities.

Instead, please email security concerns to the maintainers or use GitHub's Security Advisory feature.

### What to Include

1. Description of the vulnerability
2. Steps to reproduce
3. Potential impact
4. Suggested fix (if available)

## Security Considerations

### What These Scripts Do

- Execute shell commands via `adb shell`
- Write logs to user home directory
- Store ADB configuration locally
- Manage proot processes and distros
- Modify Android settings via ADB

### What These Scripts Don't Do

- Execute arbitrary code from the internet
- Store passwords or secrets in files
- Require root access (proot is rootless)
- Modify system partitions
- Install binary blobs or closed-source software

### Best Practices

1. **Keep Termux Updated**
   ```bash
   pkg update && pkg upgrade
   ```

2. **Verify Downloads**
   - Clone from official GitHub repository
   - Check commit signatures if available

3. **Protect Your ADB Configuration**
   - `~/.solve_problrm.conf` contains host/port info
   - Keep PCs running ADB in trusted networks
   - Revoke ADB connections regularly

4. **Monitor Logs**
   - Review `~/.solve_problrm.log` for unexpected activity
   - Check `~/.termux-superproot/logs/` for errors

5. **Use Wireless ADB Securely**
   - Enable only when needed
   - Use strong pairing codes
   - Disable on untrusted networks
   - Change ports if defaults conflict

## Dependencies

All dependencies are from official Termux repositories:
- `proot-distro` - Official proot wrapper
- `termux-tools` - Termux utilities
- `termux-api` - Android integration
- Standard GNU tools (bash, grep, awk, etc.)

## Tested Platforms

- Android 11, 12, 13
- Termux 0.118+
- proot-distro latest
- Standard Linux distros (Debian, Ubuntu, Alpine, etc.)

## Known Limitations

- proot cannot override Android kernel-level process killing
- Some Android settings may revert after reboot
- Phantom process control depends on Android version and OEM modifications
- ADB wireless debugging requires USB debugging enabled

## Version Support

- Latest version: Supported
- Previous major version: Limited support
- Older versions: No support (recommend upgrade)

## Responsible Disclosure

If you discover a vulnerability:

1. Do not publicly disclose immediately
2. Contact maintainers privately
3. Allow 90 days for a fix
4. Coordinate disclosure timing

## Security Updates

Check the [CHANGELOG.md](CHANGELOG.md) for security-related updates marked with 🔒.

Subscribe to releases for notifications: Watch → Releases only
