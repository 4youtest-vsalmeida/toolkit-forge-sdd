#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: check-prereqs.sh --stage <stage> [--cycle <sdd-XX>]

Stages: ideate, architect, plan, implement, assess

Validates required tooling, manifest presence, and Forge authentication.
EOF
}

require_arg() {
  if [[ -z ${2:-} ]]; then
    echo "[ERROR] Missing value for $1" >&2
    usage
    exit 1
  fi
}

stage=""
cycle="global"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --stage)
      require_arg "$1" "$2"
      stage="$2"
      shift 2
      ;;
    --cycle)
      require_arg "$1" "$2"
      cycle="$2"
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "[ERROR] Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

if [[ -z "$stage" ]]; then
  echo "[ERROR] --stage is required" >&2
  usage
  exit 1
fi

case "$stage" in
  ideate|architect|plan|implement|assess)
    ;;
  *)
    echo "[ERROR] Invalid stage: $stage" >&2
    usage
    exit 1
    ;;
esac

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../.." && pwd)"
log_dir="${repo_root}/logs/sdd/${cycle}/${stage}"
mkdir -p "$log_dir"
log_file="${log_dir}/check-prereqs-$(date -u +"%Y%m%dT%H%M%SZ").log"

exec > >(tee -a "$log_file") 2>&1

echo "[INFO] Checking prerequisites for stage '$stage' in cycle '$cycle'"

declare -a required_cmds=(jq shellcheck forge)

declare -a stage_cmds=()
case "$stage" in
  implement)
    stage_cmds=(node npm git)
    ;;
  assess|architect|plan)
    stage_cmds+=(mdformat)
    ;;
  ideate)
    # no additional commands beyond base
    ;;
esac

# Merge arrays, ensuring uniqueness
for cmd in "${stage_cmds[@]}"; do
  if [[ ! " ${required_cmds[*]} " =~ " ${cmd} " ]]; then
    required_cmds+=("$cmd")
  fi
done

missing=0
for cmd in "${required_cmds[@]}"; do
  if command -v "$cmd" >/dev/null 2>&1; then
    echo "[OK] Command available: $cmd"
  else
    if [[ "$cmd" == "mdformat" ]]; then
      echo "[WARN] Optional command missing: mdformat (Markdown formatting checks will be skipped)." >&2
    else
      echo "[FAIL] Missing required command: $cmd"
      missing=1
    fi
  fi
done

manifest_count=$(find "$repo_root" -maxdepth 4 -name "manifest.yml" | wc -l | tr -d ' ')
if [[ "$manifest_count" -eq 0 ]]; then
  echo "[FAIL] No Forge manifest.yml found within repository. Ensure you run this script from a Forge app workspace." >&2
  missing=1
else
  echo "[OK] Found $manifest_count manifest.yml file(s)."
fi

if command -v forge >/dev/null 2>&1; then
  if forge whoami >/dev/null 2>&1; then
    echo "[OK] Forge CLI authenticated."
  else
    echo "[WARN] Forge CLI not authenticated. Run 'forge login' before continuing." >&2
    missing=1
  fi
fi

env_warnings=0
if [[ -z ${FORGE_EMAIL:-} ]]; then
  echo "[WARN] Environment variable FORGE_EMAIL not set."
  env_warnings=1
else
  echo "[OK] FORGE_EMAIL environment variable detected."
fi

if [[ -z ${FORGE_API_TOKEN:-} ]]; then
  echo "[WARN] Environment variable FORGE_API_TOKEN not set."
  env_warnings=1
else
  echo "[OK] FORGE_API_TOKEN environment variable detected."
fi

if [[ $missing -eq 0 ]]; then
  echo "[INFO] Prerequisite check completed successfully."
else
  echo "[ERROR] Prerequisite check failed. Review the log above." >&2
fi

# Output machine-readable summary
summary=$(jq -n --arg stage "$stage" --arg cycle "$cycle" --arg log "$log_file" --argjson missing $missing --argjson envWarnings $env_warnings '{stage: $stage, cycleId: $cycle, logPath: $log, missingRequirements: $missing, envWarnings: $envWarnings}')
echo "$summary"

if [[ $missing -ne 0 ]]; then
  exit 1
fi
