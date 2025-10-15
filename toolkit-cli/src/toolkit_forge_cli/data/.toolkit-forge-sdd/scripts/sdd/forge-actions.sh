#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: forge-actions.sh --command <lint|deploy|install|tunnel> [--environment <env>] [--site <siteUrl>] [--cycle <sdd-XX>] [--stage <stage>] [--] [extra forge args]
EOF
}

require_arg() {
  if [[ -z ${2:-} ]]; then
    echo "[ERROR] Missing value for $1" >&2
    usage
    exit 1
  fi
}

command_name=""
environment=""
site=""
cycle="global"
stage="implement"
extra_args=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --command)
      require_arg "$1" "$2"
      command_name="$2"
      shift 2
      ;;
    --environment)
      require_arg "$1" "$2"
      environment="$2"
      shift 2
      ;;
    --site)
      require_arg "$1" "$2"
      site="$2"
      shift 2
      ;;
    --cycle)
      require_arg "$1" "$2"
      cycle="$2"
      shift 2
      ;;
    --stage)
      require_arg "$1" "$2"
      stage="$2"
      shift 2
      ;;
    --)
      shift
      extra_args=("$@"); break
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

if [[ -z "$command_name" ]]; then
  echo "[ERROR] --command is required" >&2
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
log_file="${log_dir}/forge-${command_name}-$(date -u +"%Y%m%dT%H%M%SZ").log"

if ! command -v forge >/dev/null 2>&1; then
  echo "[ERROR] Forge CLI not found in PATH" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required to format command summary output" >&2
  exit 1
fi

cmd=(forge)
case "$command_name" in
  lint)
    cmd+=(lint)
    ;;
  deploy)
    if [[ -z "$environment" ]]; then
      echo "[ERROR] --environment is required for deploy" >&2
      exit 1
    fi
    cmd+=(deploy --environment "$environment")
    ;;
  install)
    if [[ -z "$environment" ]]; then
      echo "[ERROR] --environment is required for install" >&2
      exit 1
    fi
    cmd+=(install --environment "$environment")
    if [[ -n "$site" ]]; then
      cmd+=(--site "$site")
    fi
    ;;
  tunnel)
    if [[ -z "$environment" ]]; then
      echo "[ERROR] --environment is required for tunnel" >&2
      exit 1
    fi
    cmd+=(tunnel --environment "$environment")
    ;;
  *)
    echo "[ERROR] Unsupported command: $command_name" >&2
    usage
    exit 1
    ;;
esac

if [[ ${#extra_args[@]} -gt 0 ]]; then
  cmd+=("${extra_args[@]}")
fi

exec > >(tee -a "$log_file") 2>&1

echo "[INFO] Executing: ${cmd[*]}"
exit_code=0
if "${cmd[@]}"; then
  echo "[OK] Command completed successfully."
else
  exit_code=$?
  echo "[ERROR] Command failed with exit code $exit_code" >&2
fi

summary=$(jq -n --arg command "$command_name" --arg stage "$stage" --arg cycle "$cycle" --arg log "$log_file" --arg environment "$environment" --arg site "$site" --argjson exitCode "$exit_code" '{command: $command, stage: $stage, cycleId: $cycle, environment: $environment, site: $site, logPath: $log, exitCode: $exitCode}')
echo "$summary"

exit "$exit_code"
