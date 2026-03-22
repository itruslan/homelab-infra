#!/usr/bin/env bash
set -euo pipefail

BASE="${AUTHENTIK_URL}"
TOKEN="${AUTHENTIK_TOKEN}"

# Find enrollment flow by slug
ENROLLMENT_FLOW_SLUG="default-source-enrollment"
FLOW=$(curl -sf "$BASE/api/v3/flows/instances/?slug=$ENROLLMENT_FLOW_SLUG" \
  -H "Authorization: Bearer $TOKEN")

FLOW_PK=$(echo "$FLOW" | python3 -c "
import json,sys
r = json.load(sys.stdin)['results']
if not r:
    print(f'ERROR: flow {\"$ENROLLMENT_FLOW_SLUG\"!r} not found', file=sys.stderr)
    exit(1)
print(r[0]['pk'])
")

# Get all stage bindings for this flow
BINDINGS=$(curl -sf "$BASE/api/v3/flows/bindings/?target=$FLOW_PK&ordering=order" \
  -H "Authorization: Bearer $TOKEN")

STAGE_PKS=$(echo "$BINDINGS" | python3 -c "
import json,sys
bindings = json.load(sys.stdin)['results']
for b in bindings:
    print(b['stage'])
")

# For each stage bound to the enrollment flow, check if it's a user_write stage
PATCHED=0
while IFS= read -r STAGE_PK; do
  [[ -z "$STAGE_PK" ]] && continue

  STAGE=$(curl -sf "$BASE/api/v3/stages/user_write/$STAGE_PK/" \
    -H "Authorization: Bearer $TOKEN" 2>/dev/null) || continue

  CURRENT=$(echo "$STAGE" | python3 -c "
import json,sys
try:
    data = json.load(sys.stdin)
    print(data.get('user_type', ''))
except Exception:
    print('')
")

  [[ -z "$CURRENT" ]] && continue

  if [[ "$CURRENT" == "internal" ]]; then
    NAME=$(echo "$STAGE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('name',''))")
    echo "user_write stage '$NAME' ($STAGE_PK) already set to internal, skipping"
    PATCHED=1
    continue
  fi

  curl -sf -X PATCH "$BASE/api/v3/stages/user_write/$STAGE_PK/" \
    -H "Authorization: Bearer $TOKEN" \
    -H "Content-Type: application/json" \
    -d '{"user_type": "internal"}' > /dev/null

  NAME=$(echo "$STAGE" | python3 -c "import json,sys; print(json.load(sys.stdin).get('name',''))")
  echo "Patched user_write stage '$NAME' ($STAGE_PK) -> user_type=internal"
  PATCHED=1
done <<< "$STAGE_PKS"

if [[ "$PATCHED" -eq 0 ]]; then
  echo "WARNING: no user_write stage found in enrollment flow '$ENROLLMENT_FLOW_SLUG'"
fi
