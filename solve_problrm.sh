#!/usr/bin/env bash

set -Eeuo pipefail

APP_NAME="solve_problrm"
CONFIG_FILE="${HOME}/.solve_problrm.conf"
LOG_FILE="${HOME}/.solve_problrm.log"
MAX_RETRIES="${MAX_RETRIES:-3}"

log() {
  local message
  message=$(printf '[%s] %s\n' "$(date +'%H:%M:%S')" "$*")
  printf '%s' "$message"
  printf '%s' "$message" >>"$LOG_FILE" 2>/dev/null || true
}

warn() {
  printf '[%s] warning: %s\n' "$(date +'%H:%M:%S')" "$*" >&2
}

die() {
  printf '[%s] error: %s\n' "$(date +'%H:%M:%S')" "$*" >&2
  exit 1
}

need_cmd() {
  command -v "$1" >/dev/null 2>&1
}

prompt_value() {
  local label="$1"
  local default_value="${2:-}"
  local value

  if [[ -n "$default_value" ]]; then
    printf '%s [%s]: ' "$label" "$default_value" >&2
  else
    printf '%s: ' "$label" >&2
  fi

  IFS= read -r value
  if [[ -z "$value" ]]; then
    value="$default_value"
  fi

  printf '%s' "$value"
}

load_config() {
  if [[ -f "$CONFIG_FILE" ]]; then
    # shellcheck source=/dev/null
    source "$CONFIG_FILE" || warn "Could not load $CONFIG_FILE"
  fi
}

save_config() {
  cat >"$CONFIG_FILE" <<EOF
ADB_HOST="${ADB_HOST:-}"
ADB_PAIR_PORT="${ADB_PAIR_PORT:-}"
ADB_CONNECT_PORT="${ADB_CONNECT_PORT:-}"
ADB_PAIR_CODE="${ADB_PAIR_CODE:-}"
ADB_DEVICE_ALIAS="${ADB_DEVICE_ALIAS:-}"
EOF
}

append_snapshot() {
  local title="$1"
  shift
  {
    printf '\n[%s] %s\n' "$(date +'%H:%M:%S')" "$title"
    "$@"
  } >>"$LOG_FILE" 2>&1 || true
}

collect_device_snapshot() {
  require_adb
  load_config

  log "Collecting device snapshot"
  append_snapshot "adb devices -l" adb devices -l
  append_snapshot "adb shell getprop ro.product.model" adb shell getprop ro.product.model
  append_snapshot "adb shell getprop ro.build.version.release" adb shell getprop ro.build.version.release
  append_snapshot "adb shell getprop ro.product.manufacturer" adb shell getprop ro.product.manufacturer
  append_snapshot "adb shell dumpsys battery" adb shell dumpsys battery
  append_snapshot "adb shell dumpsys activity processes" adb shell dumpsys activity processes
}

check_device_compatibility() {
  require_adb
  load_config

  local checks_passed=0

  if adb start-server >/dev/null 2>&1; then
    checks_passed=$((checks_passed + 1))
  fi

  if [[ -n "${ADB_HOST:-}" ]]; then
    checks_passed=$((checks_passed + 1))
  else
    warn "ADB_HOST is empty. Use 'config' or 'pair' first."
  fi

  if [[ -n "${ADB_PAIR_PORT:-}" && -n "${ADB_CONNECT_PORT:-}" ]]; then
    checks_passed=$((checks_passed + 1))
  else
    warn "ADB ports are not configured yet."
  fi

  log "Compatibility checks passed: ${checks_passed}/3"
  collect_device_snapshot
}

retry_step() {
  local description="$1"
  shift
  local attempt=1

  while [[ $attempt -le $MAX_RETRIES ]]; do
    log "$description (attempt $attempt/$MAX_RETRIES)"
    if "$@"; then
      return 0
    fi
    attempt=$((attempt + 1))
    sleep 1
  done

  warn "$description failed after $MAX_RETRIES attempts"
  return 1
}

usage() {
  cat <<EOF
$APP_NAME

Usage:
  bash $(basename "$0") pair
  bash $(basename "$0") connect
  bash $(basename "$0") fix
  bash $(basename "$0") recover
  bash $(basename "$0") auto
  bash $(basename "$0") status
  bash $(basename "$0") config

What it does:
  pair      Prompt for ADB wireless-debugging pairing host, port, and code.
  connect   Connect to a previously paired host.
  fix       Run a best-effort remediation profile for common Android/Termux/Linux issues.
  recover   Pair/connect with retries, then run the remediation profile.
  auto      Run compatibility checks, logs, pairing/connect, and recovery in one command.
  status    Show current config values.
  config    Save or refresh the config file with prompted values.

Important:
  This script uses ADB wireless debugging pairing (adb pair / adb connect).
  It does not implement true Bluetooth-based ADB pairing, because ADB pairing is a wireless-debugging feature rather than Bluetooth transport.
EOF
}

require_adb() {
  if ! need_cmd adb; then
    die "adb was not found in PATH. Install platform-tools or use an environment that provides adb."
  fi
}

normalize_host_port() {
  local input="$1"
  if [[ "$input" =~ ^[0-9.]+:[0-9]+$ ]]; then
    printf '%s' "$input"
    return 0
  fi
  if [[ "$input" =~ ^[0-9]+$ ]] && [[ -n "${ADB_HOST:-}" ]]; then
    printf '%s:%s' "$ADB_HOST" "$input"
    return 0
  fi
  printf '%s' "$input"
}

pair_wireless_debugging() {
  require_adb

  ADB_DEVICE_ALIAS="${ADB_DEVICE_ALIAS:-$(prompt_value "Device alias" "android")}"
  ADB_HOST="${ADB_HOST:-$(prompt_value "Wireless debugging host IP" "192.168.0.1")}"
  ADB_PAIR_PORT="${ADB_PAIR_PORT:-$(prompt_value "Pairing port" "37123")}"
  ADB_CONNECT_PORT="${ADB_CONNECT_PORT:-$(prompt_value "Connect port" "5555")}"
  ADB_PAIR_CODE="${ADB_PAIR_CODE:-$(prompt_value "Pairing code" "")}"

  [[ -n "$ADB_PAIR_CODE" ]] || die "Pairing code is required."

  local pair_target connect_target
  pair_target="$(normalize_host_port "${ADB_HOST}:${ADB_PAIR_PORT}")"
  connect_target="$(normalize_host_port "${ADB_HOST}:${ADB_CONNECT_PORT}")"

  log "Pairing to $pair_target"
  adb pair "$pair_target" "$ADB_PAIR_CODE" 2>&1 | tee -a "$LOG_FILE" 2>/dev/null || true

  log "Connecting to $connect_target"
  adb connect "$connect_target" 2>&1 | tee -a "$LOG_FILE" 2>/dev/null || true

  save_config
  log "Pair/connect flow completed for ${ADB_DEVICE_ALIAS}"
}

connect_wireless_debugging() {
  require_adb
  load_config

  ADB_HOST="${ADB_HOST:-$(prompt_value "Wireless debugging host IP" "192.168.0.1")}"
  ADB_CONNECT_PORT="${ADB_CONNECT_PORT:-$(prompt_value "Connect port" "5555")}"

  local connect_target
  connect_target="$(normalize_host_port "${ADB_HOST}:${ADB_CONNECT_PORT}")"

  log "Connecting to $connect_target"
  adb connect "$connect_target" 2>&1 | tee -a "$LOG_FILE" 2>/dev/null || true
}

run_fix_profile() {
  require_adb

  local target="${1:-all}"
  log "Running remediation profile: $target"

  case "$target" in
    all)
      adb shell settings put global stay_on_while_plugged_in 3 || true
      adb shell cmd deviceidle whitelist +com.termux || true
      adb shell settings put global max_phantom_processes 2147483647 || true
      adb shell settings put global enable_monitor_phantom_procs false || true
      adb shell pm grant com.termux android.permission.READ_EXTERNAL_STORAGE || true
      adb shell pm grant com.termux android.permission.WRITE_EXTERNAL_STORAGE || true
      adb shell settings put global window_animation_scale 0.5 || true
      adb shell settings put global transition_animation_scale 0.5 || true
      adb shell settings put global animator_duration_scale 0.5 || true
      adb shell input keyevent 224 || true
      ;;
    audio)
      adb shell settings put global stay_on_while_plugged_in 3 || true
      adb shell cmd deviceidle whitelist +com.termux || true
      adb shell am broadcast -a android.intent.action.HEADSET_PLUG >/dev/null 2>&1 || true
      ;;
    signal9)
      adb shell settings put global stay_on_while_plugged_in 3 || true
      adb shell cmd deviceidle whitelist +com.termux || true
      adb shell settings put global max_phantom_processes 2147483647 || true
      adb shell settings put global enable_monitor_phantom_procs false || true
      adb shell settings put global window_animation_scale 0.5 || true
      adb shell settings put global transition_animation_scale 0.5 || true
      adb shell settings put global animator_duration_scale 0.5 || true
      ;;
    gui)
      adb shell settings put global window_animation_scale 0.5 || true
      adb shell settings put global transition_animation_scale 0.5 || true
      adb shell settings put global animator_duration_scale 0.5 || true
      ;;
    *)
      die "Unknown fix profile: $target"
      ;;
  esac

  log "Remediation profile finished"
}

recover_flow() {
  load_config
  check_device_compatibility

  if [[ -n "${ADB_PAIR_CODE:-}" ]]; then
    retry_step "Pairing wireless debugging" pair_wireless_debugging
  else
    retry_step "Connecting wireless debugging" connect_wireless_debugging
  fi

  retry_step "Running full remediation profile" run_fix_profile all
  collect_device_snapshot
}

auto_fix_flow() {
  load_config
  check_device_compatibility

  if [[ -n "${ADB_PAIR_CODE:-}" ]]; then
    retry_step "Pairing wireless debugging" pair_wireless_debugging || true
  fi

  retry_step "Connecting wireless debugging" connect_wireless_debugging || true
  retry_step "Running full remediation profile" run_fix_profile all || true
  collect_device_snapshot
  log "Auto-fix flow completed"
}

show_status() {
  load_config
  printf 'ADB_HOST=%s\n' "${ADB_HOST:-}"
  printf 'ADB_PAIR_PORT=%s\n' "${ADB_PAIR_PORT:-}"
  printf 'ADB_CONNECT_PORT=%s\n' "${ADB_CONNECT_PORT:-}"
  printf 'ADB_DEVICE_ALIAS=%s\n' "${ADB_DEVICE_ALIAS:-}"
  printf 'CONFIG_FILE=%s\n' "$CONFIG_FILE"
}

main() {
  local command="${1:-help}"
  shift || true

  case "$command" in
    pair)
      pair_wireless_debugging
      ;;
    connect)
      connect_wireless_debugging
      ;;
    fix)
      run_fix_profile "${1:-all}"
      ;;
    recover)
      recover_flow
      ;;
    auto)
      auto_fix_flow
      ;;
    status)
      show_status
      ;;
    config)
      load_config
      ADB_DEVICE_ALIAS="${ADB_DEVICE_ALIAS:-$(prompt_value "Device alias" "android")}"
      ADB_HOST="${ADB_HOST:-$(prompt_value "Wireless debugging host IP" "192.168.0.1")}"
      ADB_PAIR_PORT="${ADB_PAIR_PORT:-$(prompt_value "Pairing port" "37123")}"
      ADB_CONNECT_PORT="${ADB_CONNECT_PORT:-$(prompt_value "Connect port" "5555")}"
      ADB_PAIR_CODE="${ADB_PAIR_CODE:-$(prompt_value "Pairing code" "")}"
      save_config
      log "Saved config to $CONFIG_FILE"
      ;;
    help|-h|--help)
      usage
      ;;
    *)
      usage
      die "Unknown command: $command"
      ;;
  esac
}

main "$@"
