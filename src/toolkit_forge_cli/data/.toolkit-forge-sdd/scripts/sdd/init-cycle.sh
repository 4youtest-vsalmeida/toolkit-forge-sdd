#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage: init-cycle.sh --stage <stage> [--cycle <sdd-XX|new>] [--feature <name>] [--product-context <comma-separated>]

Stages: ideate, architect, plan, implement, assess

Initializes SDD cycle folders, copies stage templates, and updates metadata.
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
feature=""
product_context=""

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
    --feature)
      require_arg "$1" "$2"
      feature="$2"
      shift 2
      ;;
    --product-context)
      require_arg "$1" "$2"
      product_context="$2"
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
docs_root="${repo_root}/toolkit-forge-docs"
templates_root="${repo_root}/.toolkit-forge-sdd/templates/orchestrators/${stage}"

if [[ ! -d "$templates_root" ]]; then
  echo "[ERROR] Template directory not found for stage '$stage': $templates_root" >&2
  exit 1
fi

if ! command -v jq >/dev/null 2>&1; then
  echo "[ERROR] jq is required for metadata operations" >&2
  exit 1
fi

mkdir -p "$docs_root"

# Determine cycle ID
if [[ -z "$cycle" || "$cycle" == "new" ]]; then
  max_id=0
  shopt -s nullglob
  for dir in "${docs_root}"/sdd-*; do
    base="$(basename "$dir")"
    if [[ $base =~ ^sdd-([0-9]{2})$ ]]; then
      num="${BASH_REMATCH[1]}"
      if ((10#$num > max_id)); then
        max_id=$((10#$num))
      fi
    fi
  done
  shopt -u nullglob
  next=$((max_id + 1))
  printf -v cycle "sdd-%02d" "$next"
else
  if [[ ! $cycle =~ ^sdd-[0-9]{2}$ ]]; then
    echo "[ERROR] Invalid cycle format: $cycle" >&2
    exit 1
  fi
fi

cycle_dir="${docs_root}/${cycle}"
stage_dir="${cycle_dir}/${stage}"
mkdir -p "$stage_dir"

log_dir="${repo_root}/logs/sdd/${cycle}/${stage}"
mkdir -p "$log_dir"
log_file="${log_dir}/init-cycle-$(date -u +"%Y%m%dT%H%M%SZ").log"

exec > >(tee -a "$log_file") 2>&1

echo "[INFO] Repository root: $repo_root"
echo "[INFO] Cycle: $cycle"
echo "[INFO] Stage: $stage"
echo "[INFO] Stage directory: $stage_dir"

templates_copied=()
while IFS= read -r -d '' template; do
  rel_path="${template#${templates_root}/}"
  dest_path="${stage_dir}/${rel_path}"
  mkdir -p "$(dirname "$dest_path")"
  if [[ ! -f "$dest_path" ]]; then
    cp "$template" "$dest_path"
    templates_copied+=("$rel_path")
    echo "[INFO] Copied template: $rel_path"
  else
    echo "[INFO] Skipped existing template: $rel_path"
  fi
done < <(find "$templates_root" -type f -print0)

timestamp="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
metadata_path="${cycle_dir}/metadata.json"
traceability_path="${cycle_dir}/traceability.json"

if [[ -n "$product_context" ]]; then
  product_array="$(printf '%s' "$product_context" | jq -R 'split(",") | map(. | gsub("^\\s+|\\s+$"; "")) | map(select(length > 0))')"
else
  product_array="[]"
fi

jq_base_args=(--arg cycleId "$cycle" --arg feature "$feature" --arg stage "$stage" --arg ts "$timestamp" --argjson productContext "$product_array")

if [[ -f "$metadata_path" ]]; then
  tmp_file="$(mktemp)"
  jq "${jq_base_args[@]}" '
    .cycleId = $cycleId |
    (if ($feature | length) > 0 then .feature = $feature else . end) |
    (if ($productContext | length) > 0 then .productContext = $productContext else . end) |
    .stages = (.stages // {}) |
    .stages[$stage] = (.stages[$stage] // {}) + {
      status: "initialized",
      updatedAt: $ts
    } + (if ($feature | length) > 0 then {feature: $feature} else {} end) + (if ($productContext | length) > 0 then {productContext: $productContext} else {} end)
  ' "$metadata_path" > "$tmp_file"
  mv "$tmp_file" "$metadata_path"
else
  jq -n "${jq_base_args[@]}" '
    {
      cycleId: $cycleId,
      feature: $feature,
      productContext: $productContext,
      createdAt: $ts,
      stages: {
        ($stage): {
          status: "initialized",
          updatedAt: $ts,
          feature: $feature,
          productContext: $productContext
        }
      }
    }
  ' > "$metadata_path"
fi

echo "[INFO] Metadata updated: $metadata_path"

if [[ ! -f "$traceability_path" ]]; then
  jq -n "${jq_base_args[@]}" '
    {
      cycleId: $cycleId,
      artifacts: []
    }
  ' > "$traceability_path"
  echo "[INFO] Created traceability manifest: $traceability_path"
fi

if [[ ${#templates_copied[@]} -eq 0 ]]; then
  templates_json='[]'
else
  templates_json="$(printf '%s\n' "${templates_copied[@]}" | jq -R . | jq -s .)"
fi

jq -n --arg cycle "$cycle" --arg stage "$stage" --arg metadata "$metadata_path" --arg traceability "$traceability_path" --arg log "$log_file" --argjson templates "$templates_json" '
  {
    cycleId: $cycle,
    stage: $stage,
    metadataPath: $metadata,
    traceabilityPath: $traceability,
    logPath: $log,
    templatesCopied: $templates
  }
'
