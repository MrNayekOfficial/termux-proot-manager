#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="termux-superproot"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="${HOME}/.termux-superproot"
DOWNLOAD_DIR="${BASE_DIR}/downloads"
LOG_DIR="${BASE_DIR}/logs"
BIN_DIR="${BASE_DIR}/bin"
PROFILE_DIR="${SCRIPT_DIR}/profiles"
GUI_GEOMETRY="${GUI_GEOMETRY:-1280x720}"
GUI_DEPTH="${GUI_DEPTH:-24}"
GUI_PORT="${GUI_PORT:-5901}"
DEFAULT_DISTRO="${DEFAULT_DISTRO:-debian}"
ROOTFS_DIR="${PREFIX:-}/var/lib/proot-distro/installed-rootfs"
CONFIG_FILE="${BASE_DIR}/config"
MEMORY_WARN_MB="${MEMORY_WARN_MB:-700}"

log() {
  local msg
  msg=$(printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*")
  printf '%s' "$msg"
  mkdir -p "$LOG_DIR" 2>/dev/null || true
  printf '%s' "$msg" >> "$LOG_DIR/termux-superproot.log" 2>/dev/null || true
}

warn() {
  printf '[%s] warning: %s\n' "$(date +'%H:%M:%S')" "$*" >&2
}

die() {
  printf '[%s] error: %s\n' "$(date +'%H:%M:%S')" "$*" >&2
  exit 1
}

run() {
  log "$*"
  "$@"
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

rootfs_path() {
  local distro="${1:-}"
  printf '%s/%s' "$ROOTFS_DIR" "$distro"
}

is_distro_installed() {
  local distro="${1:-}"
  [[ -n "$distro" ]] || return 1
  [[ -d "$(rootfs_path "$distro")" ]]
}

ensure_termux() {
  if [[ -z "${PREFIX:-}" || ! -d "${PREFIX:-}" ]]; then
    die "This script must be run inside Termux."
  fi
}

ensure_dirs() {
  mkdir -p "$DOWNLOAD_DIR" "$LOG_DIR" "$BIN_DIR"
}

ensure_profile_dir() {
  mkdir -p "$PROFILE_DIR"
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    if source "$CONFIG_FILE"; then
      log "Loaded config: $CONFIG_FILE"
    else
      warn "Failed to source $CONFIG_FILE"
    fi
  fi
}

installed_distros() {
  local path

  shopt -s nullglob
  for path in "$ROOTFS_DIR"/*; do
    [[ -d "$path" ]] || continue
    basename "$path"
  done | sort -u
  shopt -u nullglob
}

install_base_packages() {
  run pkg update -y
  run pkg upgrade -y
  run pkg install -y proot-distro curl wget git jq tar xz-utils pulseaudio termux-tools termux-api

  if pkg list-installed 2>/dev/null | grep -q '^x11-repo$'; then
    :
  else
    run pkg install -y x11-repo || warn "x11-repo is optional and may not be available on this Termux channel"
  fi

  if pkg list-installed 2>/dev/null | grep -q '^termux-x11-nightly$'; then
    :
  else
    run pkg install -y termux-x11-nightly || warn "termux-x11-nightly is optional; VNC fallback is still available"
  fi

  if need_cmd termux-wake-lock; then
    termux-wake-lock || true
  fi
}

show_supported_distros() {
  cat <<'EOF'
Supported proot-distro names:
  alpine
  archlinux
  debian
  fedora
  kali
  ubuntu
EOF
}

install_distro() {
  local distro="${1:-}"
  [[ -n "$distro" ]] || die "Missing distro name"
  if ! need_cmd proot-distro; then
    die "proot-distro not installed. Run 'pkg install proot-distro' first."
  fi
  run proot-distro install "$distro"
}

create_profile_launcher() {
  local distro="${1:-}"
  local target="${PROFILE_DIR}/${distro}.sh"

  [[ -n "$distro" ]] || die "Missing distro name"

  cat >"$target" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="\$(cd "\$(dirname "\${BASH_SOURCE[0]}")" && pwd)"
exec bash "\${SCRIPT_DIR}/../termux-superproot.sh" start ${distro}
EOF

  chmod +x "$target"
  log "Created profile launcher: $target"
}

create_generic_profile_launcher() {
  local target="${PROFILE_DIR}/launch.sh"

  cat >"$target" <<'EOF'
#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DISTRO_NAME="${1:-${DISTRO:-}}"

if [[ -z "$DISTRO_NAME" ]]; then
  echo "usage: bash launch.sh <distro>" >&2
  echo "or set DISTRO=<distro>" >&2
  exit 1
fi

exec bash "${SCRIPT_DIR}/../termux-superproot.sh" start "$DISTRO_NAME"
EOF

  chmod +x "$target"
  log "Created generic launcher: $target"
}

refresh_profile_launchers() {
  ensure_profile_dir
  create_generic_profile_launcher

  while IFS= read -r distro; do
    [[ -n "$distro" ]] || continue
    create_profile_launcher "$distro"
  done < <(installed_distros)

  if ! installed_distros | grep -q .; then
    create_profile_launcher "${DEFAULT_DISTRO}"
  fi
  log "Profile refresh complete"
}

install_nethunter_rootless() {
  local installer="${DOWNLOAD_DIR}/install-nethunter-termux"
  run curl -L "https://offs.ec/2MceZWr" -o "$installer"
  run chmod +x "$installer"
  log "Launching the official Kali NetHunter Rootless installer"
  "$installer" -y
}

host_pulse_bootstrap() {
  if need_cmd pulseaudio; then
    pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
  fi
}

start_termux_x11() {
  if need_cmd termux-x11; then
    log "Starting termux-x11 on :0"
    termux-x11 :0 -ac >/dev/null 2>&1 &
    export DISPLAY=:0
    export XDG_RUNTIME_DIR="${TMPDIR:-${PREFIX}/tmp}"
    export QT_QPA_PLATFORM=xcb
    export GDK_BACKEND=x11
    export NO_AT_BRIDGE=1
    export LIBGL_ALWAYS_SOFTWARE=1
    if wait_for_x11; then
      return 0
    fi
    warn "termux-x11 failed to become ready"
    return 1
  else
    warn "termux-x11 is not available; GUI will need a VNC-style fallback"
    return 1
  fi
}

wait_for_x11() {
  local tries=0
  local max_tries=12
  while [[ $tries -lt $max_tries ]]; do
    if pgrep -f termux-x11 >/dev/null 2>&1; then
      log "termux-x11 running"
      return 0
    fi
    sleep 1
    tries=$((tries + 1))
  done
  return 1
}

wait_for_pulseaudio() {
  local tries=0
  local max_tries=12
  while [[ $tries -lt $max_tries ]]; do
    if pgrep -f pulseaudio >/dev/null 2>&1; then
      log "PulseAudio appears available"
      return 0
    fi
    sleep 1
    tries=$((tries + 1))
  done
  warn "PulseAudio did not appear after $max_tries seconds"
  return 1
}

check_memory() {
  if [[ -r /proc/meminfo ]]; then
    local avail
    avail=$(awk '/MemAvailable:/ {print int($2/1024)}' /proc/meminfo 2>/dev/null || echo 0)
    if [[ -n "$avail" && "$avail" -lt "$MEMORY_WARN_MB" ]]; then
      warn "Available memory is low: ${avail}MB (recommended >= ${MEMORY_WARN_MB}MB)"
    else
      log "Available memory: ${avail}MB"
    fi
  fi
}

start_vnc_fallback() {
  local distro="${1:-$DEFAULT_DISTRO}"
  log "Attempting VNC fallback inside distro: $distro"
  proot-distro login --termux-home --shared-tmp "$distro" -- env GUI_GEOMETRY="$GUI_GEOMETRY" GUI_DEPTH="$GUI_DEPTH" bash -lc '
if command -v tigervncserver >/dev/null 2>&1; then
  mkdir -p ~/.vnc
  vncserver :1 -geometry "$GUI_GEOMETRY" -depth "$GUI_DEPTH" >/dev/null 2>&1 || true
  echo "VNC server started on :1"
else
  echo "tigervncserver not installed inside distro; run the distro package install command shown in README" >&2
  exit 1
fi'
  log "If VNC was started, connect to localhost:5901 using a VNC client"
}

install_audio_support() {
  local distro="${1:-$DEFAULT_DISTRO}"
  log "Installing audio support packages inside distro: $distro"
  proot-distro login --termux-home --shared-tmp "$distro" -- bash -lc '
set -e
if [ -f /etc/os-release ]; then
  . /etc/os-release
fi
case "${ID:-}" in
  debian|ubuntu|kali)
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt install -y pulseaudio pulseaudio-utils alsa-utils
    ;;
  arch|archlinux)
    pacman -Syu --noconfirm
    pacman -S --noconfirm pulseaudio pulseaudio-alsa alsa-utils
    ;;
  fedora)
    dnf -y install pulseaudio pulseaudio-utils alsa-utils
    ;;
  alpine)
    apk update
    apk add pulseaudio alsa-utils
    ;;
  *)
    echo "Unsupported distro for audio auto-install: ${ID:-unknown}" >&2
    exit 1
    ;;
esac'
  log "Audio packages installed for $distro"
}

recover_session() {
  local distro="${1:-$DEFAULT_DISTRO}"
  stop_related_processes
  install_audio_support "$distro" || true
  refresh_profile_launchers
  start_full_session "$distro"
}

stop_related_processes() {
  local pattern
  safe_kill()
  {
    local sig="$1"
    local pat="$2"
    if command -v pkill >/dev/null 2>&1; then
      pkill -s "$sig" -f "$pat" >/dev/null 2>&1 || true
      return
    fi
    # fallback: find pids with ps and kill
    local pids
    pids=$(ps aux 2>/dev/null | grep -F "$pat" | grep -v grep | awk '{print $2}') || pids=
    if [[ -n "$pids" ]]; then
      kill -"$sig" $pids >/dev/null 2>&1 || true
    fi
  }

  for pattern in \
    'termux-x11' \
    'pulseaudio' \
    'tigervnc' \
    'Xvnc' \
    'xfce4-session' \
    'startxfce4' \
    'dbus-daemon' \
    'proot-distro'; do
    safe_kill TERM "$pattern"
  done

  for pattern in \
    'termux-x11' \
    'pulseaudio' \
    'tigervnc' \
    'Xvnc' \
    'xfce4-session' \
    'startxfce4' \
    'dbus-daemon' \
    'proot-distro'; do
    safe_kill KILL "$pattern"
  done
}

login_distro() {
  local distro="${1:-$DEFAULT_DISTRO}"
  shift || true
  host_pulse_bootstrap
  run proot-distro login --termux-home --shared-tmp "$distro" -- "$@"
}

setup_desktop_in_distro() {
  local distro="${1:-$DEFAULT_DISTRO}"
  local setup_script

  setup_script='set -e
if [ -f /etc/os-release ]; then
  . /etc/os-release
fi

case "${ID:-}" in
  debian|ubuntu|kali)
    export DEBIAN_FRONTEND=noninteractive
    apt update
    apt install -y xfce4 xfce4-goodies dbus-x11 tigervnc-standalone-server tigervnc-common xauth x11-apps mesa-utils pulseaudio
    ;;
  arch|archlinux)
    pacman -Syu --noconfirm
    pacman -S --noconfirm xfce4 xfce4-goodies dbus tigervnc xorg-xauth xorg-xinit mesa-utils pulseaudio
    ;;
  fedora)
    dnf -y install @xfce-desktop-environment tigervnc-server dbus-x11 xorg-x11-xauth mesa-dri-drivers mesa-libGL pulseaudio
    ;;
  alpine)
    apk update
    apk add xfce4 xfce4-terminal tigervnc dbus-x11 mesa-dri-gallium mesa-egl pulseaudio
    ;;
  *)
    echo "Unsupported distro inside container: ${ID:-unknown}" >&2
    exit 1
    ;;
esac
'

  proot-distro login --termux-home --shared-tmp "$distro" -- bash -lc "$setup_script"
}

create_launcher() {
  local distro="${1:-$DEFAULT_DISTRO}"
  local target="${BIN_DIR}/start-${distro}.sh"

  cat >"$target" <<EOF
#!/usr/bin/env bash
set -Eeuo pipefail

export PULSE_SERVER=127.0.0.1
export TMPDIR="\$PREFIX/tmp"
export HOME="\$HOME"

if command -v pulseaudio >/dev/null 2>&1; then
  pulseaudio --start --exit-idle-time=-1 >/dev/null 2>&1 || true
fi

if command -v termux-x11 >/dev/null 2>&1; then
  termux-x11 :0 -ac >/dev/null 2>&1 &
  export DISPLAY=:0
  export XDG_RUNTIME_DIR="${TMPDIR:-${PREFIX}/tmp}"
  export QT_QPA_PLATFORM=xcb
  export GDK_BACKEND=x11
  export NO_AT_BRIDGE=1
  export LIBGL_ALWAYS_SOFTWARE=1
fi

exec proot-distro login --termux-home --shared-tmp ${distro} -- env DISPLAY="\$DISPLAY" PULSE_SERVER="\$PULSE_SERVER" bash -l
EOF

  chmod +x "$target"
  log "Created launcher: $target"
}

create_all_launchers() {
  create_launcher debian
  create_launcher kali
  create_launcher ubuntu
  create_launcher alpine
  create_launcher archlinux
  create_launcher fedora
}

fix_signal9_mode() {
  cat <<EOF
Signal 9 mitigation checklist:
1. Keep the app awake with termux-wake-lock.
2. Launch with proot-distro login --termux-home --shared-tmp.
3. Avoid huge single-line startup commands; use the generated launcher in ${BIN_DIR}.
4. Disable Android battery optimization for Termux and any X11/VNC companion app.
5. Prefer lighter desktops such as XFCE over GNOME or KDE on low-memory devices.
6. If the device still kills the session, lower GUI_GEOMETRY and close other apps.
EOF
}

show_status() {
  log "Base directory: $BASE_DIR"
  log "Launcher directory: $BIN_DIR"
  log "Profile directory: $PROFILE_DIR"
  log "GUI geometry: $GUI_GEOMETRY"
  log "GUI depth: $GUI_DEPTH"
  log "GUI port: $GUI_PORT"
  if need_cmd proot-distro; then
    proot-distro list || true
  fi
}

ensure_desktop_ready() {
  local distro="${1:-$DEFAULT_DISTRO}"
  if ! is_distro_installed "$distro"; then
    install_distro "$distro"
  fi

  create_launcher "$distro"
  setup_desktop_in_distro "$distro"
}

start_full_session() {
  local distro="${1:-$DEFAULT_DISTRO}"
  stop_related_processes
  ensure_termux
  ensure_dirs
  ensure_profile_dir
  load_config
  check_memory
  install_base_packages
  ensure_desktop_ready "$distro"
  refresh_profile_launchers
  host_pulse_bootstrap
  if start_termux_x11; then
    wait_for_pulseaudio || true
    login_distro "$distro" bash -l
  else
    warn "termux-x11 unavailable; falling back to VNC inside distro"
    start_vnc_fallback "$distro"
  fi
}

self_update() {
  log "Self-update not implemented. Place a URL in config and implement update logic."
}

usage() {
  cat <<EOF
$APP_NAME

Usage:
  bash $(basename "$0") init
  bash $(basename "$0") install <distro>
  bash $(basename "$0") nethunter
  bash $(basename "$0") gui <distro>
  bash $(basename "$0") launch <distro>
  bash $(basename "$0") start <distro>
  bash $(basename "$0") stop
  bash $(basename "$0") refresh-profiles
  bash $(basename "$0") audio-fix <distro>
  bash $(basename "$0") recover <distro>
  bash $(basename "$0") status
  bash $(basename "$0") signal9
  bash $(basename "$0") list

Commands:
  init      Install Termux packages, create directories, and generate launchers
  install   Install a proot distro by name
  nethunter Install Kali NetHunter Rootless using the official installer
  gui       Bootstrap an XFCE desktop inside a proot distro
  launch    Open the selected distro with the generated launcher
  start     Stop related processes, start X11 on :0, and launch the distro
  stop      Kill related Termux/proot/X11/background processes
  refresh-profiles
            Generate a wrapper for every installed proot distro under profiles/
  audio-fix Install audio support packages inside a distro
  recover   Clean up processes, install audio support, and restart the session
  status    Show configured paths and current distro availability
  signal9   Print practical mitigations for session timeouts and SIGKILLs
  list      Show supported distro names

Examples:
  bash $(basename "$0") init
  bash $(basename "$0") install debian
  bash $(basename "$0") gui kali
  bash $(basename "$0") nethunter
  bash $(basename "$0") launch debian
  bash $(basename "$0") start kali
  bash $(basename "$0") stop
  bash $(basename "$0") refresh-profiles
  bash $(basename "$0") audio-fix kali
  bash $(basename "$0") recover kali
EOF
}

main() {
  ensure_termux
  ensure_dirs
  ensure_profile_dir

  local command="${1:-init}"
  shift || true

  case "$command" in
    init)
      install_base_packages
      create_all_launchers
      refresh_profile_launchers
      ;;
    install)
      [[ $# -ge 1 ]] || die "Usage: $0 install <distro>"
      install_distro "$1"
      create_launcher "$1"
      refresh_profile_launchers
      ;;
    nethunter)
      install_nethunter_rootless
      ;;
    gui)
      [[ $# -ge 1 ]] || die "Usage: $0 gui <distro>"
      setup_desktop_in_distro "$1"
      create_launcher "$1"
      refresh_profile_launchers
      ;;
    launch)
      login_distro "${1:-$DEFAULT_DISTRO}" bash -l
      ;;
    start)
      start_full_session "${1:-$DEFAULT_DISTRO}"
      ;;
    stop)
      stop_related_processes
      ;;
    refresh-profiles)
      refresh_profile_launchers
      ;;
    audio-fix)
      install_audio_support "${1:-$DEFAULT_DISTRO}"
      ;;
    recover)
      recover_session "${1:-$DEFAULT_DISTRO}"
      ;;
    status)
      show_status
      ;;
    signal9)
      fix_signal9_mode
      ;;
    list)
      show_supported_distros
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      die "Unknown command: $command"
      ;;
  esac
}

main "$@"
