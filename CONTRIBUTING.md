# Contributing to Termux proot Manager

Thank you for your interest in contributing! We welcome bug reports, feature requests, and pull requests.

## How to Contribute

### Reporting Bugs

1. **Check existing issues** to avoid duplicates
2. **Provide device details:**
   - Android version
   - Termux version
   - Output of `uname -a` inside Termux
   - Device model and RAM
3. **Include error messages and logs:**
   - `~/.termux-superproot/logs/termux-superproot.log`
   - `~/.solve_problrm.log`
4. **Steps to reproduce** the issue

### Suggesting Features

1. Describe the feature and use case
2. Explain why it would be useful
3. Provide examples or mockups if applicable
4. Check if similar features exist

### Submitting Code

#### Development Setup

```bash
# Clone your fork
git clone https://github.com/YOUR_USERNAME/termux-proot-manager.git
cd termux-proot-manager

# Create a branch
git checkout -b feature/your-feature-name
```

#### Code Guidelines

1. **Bash Style:**
   - Use `#!/usr/bin/env bash` as shebang
   - Set `set -Eeuo pipefail` at start of script
   - Use `local` for function variables
   - Quote all variables: `"$var"` not `$var`
   - Use `[[ ]]` for conditionals, not `[ ]`

2. **Error Handling:**
   - Use `die()` for fatal errors
   - Use `warn()` for warnings
   - Check command availability with `need_cmd()`
   - Add `|| true` or `|| return 1` for non-fatal failures

3. **Logging:**
   - Use `log()` for important output
   - Include timestamps in logs
   - Log to files + console
   - Use `append_snapshot()` for device data collection

4. **Functions:**
   - Add descriptive names
   - Document parameters and return values
   - Keep functions focused and testable
   - Use prefixes for clarity (e.g., `check_`, `run_`, `setup_`)

5. **Variables:**
   - Use UPPERCASE for constants
   - Use lowercase for local variables
   - Use meaningful names
   - Provide defaults: `"${VAR:-default}"`

#### Testing

Before submitting:

```bash
# Syntax check
bash -n termux-superproot.sh
bash -n solve_problrm.sh

# Run on device (test all main commands)
bash termux-superproot.sh init
bash termux-superproot.sh install debian
bash termux-superproot.sh status
bash solve_problrm.sh config
bash solve_problrm.sh auto
```

#### Commit Messages

Use clear, descriptive commit messages:

```
feat: Add phantom process control
fix: Correct pkill signal syntax
docs: Update README with new features
refactor: Simplify device snapshot collection
```

Format: `<type>: <subject>`

Types: `feat`, `fix`, `docs`, `refactor`, `test`, `chore`

#### Pull Request Process

1. Update documentation and examples
2. Add entries to [CHANGELOG.md](CHANGELOG.md)
3. Test on multiple Android versions if possible
4. Provide clear PR description:
   - What changes?
   - Why?
   - How to test?
5. Link related issues (#123)
6. Keep commits clean and focused

## Code of Conduct

- Be respectful and inclusive
- Welcome diverse perspectives
- Focus on constructive feedback
- No harassment or discrimination

## Questions?

- Open a GitHub Discussion
- Check existing documentation
- Review similar issues

## License

By contributing, you agree that your code will be licensed under the MIT License.

---

Thank you for making Termux proot Manager better! 🎉
