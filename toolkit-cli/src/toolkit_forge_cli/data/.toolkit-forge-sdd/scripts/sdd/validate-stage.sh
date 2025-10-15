#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: validate-stage.sh --stage <stage> --cycle <sdd-XX>

Stages: ideate, architect, plan, implement, assess

Validates stage outputs, metadata, and traceability manifests.
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
cycle=""

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

if [[ -z "$stage" || -z "$cycle" ]]; then
  echo "[ERROR] --stage and --cycle are required" >&2
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

if [[ ! $cycle =~ ^sdd-[0-9]{2}$ ]]; then
  echo "[ERROR] Invalid cycle format: $cycle" >&2
  usage
  exit 1
fi

script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
repo_root="$(cd "${script_dir}/../../.." && pwd)"
cycle_dir="${repo_root}/toolkit-forge-docs/${cycle}"
stage_dir="${cycle_dir}/${stage}"
metadata_path="${cycle_dir}/metadata.json"
traceability_path="${cycle_dir}/traceability.json"

log_dir="${repo_root}/logs/sdd/${cycle}/${stage}"
mkdir -p "$log_dir"
log_file="${log_dir}/validate-stage-$(date -u +"%Y%m%dT%H%M%SZ").log"

exec > >(tee -a "$log_file") 2>&1

echo "[INFO] Validating stage '$stage' for cycle '$cycle'"

if [[ ! -d "$stage_dir" ]]; then
  echo "[ERROR] Stage directory not found: $stage_dir" >&2
  exit 1
fi

# Expected files per stage
case "$stage" in
  ideate)
    expected=(specification.md specification-quality-checklist.md edge-case-catalog.md)
    ;;
  architect)
    expected=(architecture-decision-record.md architecture-quality-checklist.md architecture-traceability.md)
    ;;
  plan)
    expected=(implementation-plan.md work-breakdown-structure.md plan-quality-checklist.md plan-traceability.md)
    ;;
  implement)
    expected=(implementation-log.md test-evidence.md deployment-runbook.md implement-quality-checklist.md)
    ;;
  assess)
    expected=(assessment-report.md assessment-quality-checklist.md residual-risks.md)
    ;;
esac

missing_files=()
for file in "${expected[@]}"; do
  path="${stage_dir}/${file}"
  if [[ ! -f "$path" ]]; then
    missing_files+=("$file")
    echo "[FAIL] Missing expected file: $path"
  else
    echo "[OK] Found file: $path"
    if ! grep -qi "traceability" "$path"; then
      echo "[WARN] File missing Traceability section keyword: $file" >&2
    fi
  fi
done

status=0
if [[ ${#missing_files[@]} -gt 0 ]]; then
  status=1
fi

if [[ ! -f "$metadata_path" ]]; then
  echo "[FAIL] Metadata file not found: $metadata_path" >&2
  status=1
else
  if command -v jq >/dev/null 2>&1; then
    if jq -e ".stages.${stage}" "$metadata_path" >/dev/null 2>&1; then
      echo "[OK] Metadata contains stage entry for '$stage'."
    else
      echo "[WARN] Metadata missing stage entry for '$stage'." >&2
    fi
  fi
fi

if [[ ! -f "$traceability_path" ]]; then
  echo "[FAIL] Traceability manifest not found: $traceability_path" >&2
  status=1
else
  if command -v jq >/dev/null 2>&1; then
    if jq empty "$traceability_path" >/dev/null 2>&1; then
      echo "[OK] Traceability manifest is valid JSON."
    else
      echo "[FAIL] Traceability manifest is invalid JSON." >&2
      status=1
    fi
    stage_artifacts=$(jq --arg stage "$stage" '[.artifacts[] | select(.stage == $stage)] | length' "$traceability_path" 2>/dev/null || echo 0)
    echo "[INFO] Traceability artifacts for stage '$stage': $stage_artifacts"
  fi
fi

if command -v mdformat >/dev/null 2>&1; then
  echo "[INFO] Running mdformat --check on stage files"
  if ! mdformat --check "${stage_dir}"/*.md; then
    echo "[WARN] Markdown formatting issues detected." >&2
  else
    echo "[OK] Markdown formatting verified."
  fi
else
  echo "[INFO] mdformat not available; skipping markdown formatting check."
fi

summary=$(jq -n --arg stage "$stage" --arg cycle "$cycle" --arg log "$log_file" --argjson missingFiles "$(printf '%s\n' "${missing_files[@]}" | jq -R . | jq -s . 2>/dev/null || echo '[]')" --arg status "$status" '{stage: $stage, cycleId: $cycle, logPath: $log, missingFiles: $missingFiles, status: (if ($status|tonumber) == 0 then "passed" else "failed" end)}')
echo "$summary"

if [[ $status -ne 0 ]]; then
  exit 1
fi
