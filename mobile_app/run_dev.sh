#!/bin/bash
# Run flutter with all required --dart-define values loaded from .env
# Usage: bash run_dev.sh [device-id]
#   device-id defaults to the Samsung SM S928B

set -a
source .env
set +a

DEVICE=${1:-R5CY60TRCAA}

flutter run -d "$DEVICE" \
  --dart-define=API_BASE_URL="$API_BASE_URL" \
  --dart-define=SUPABASE_URL="$SUPABASE_URL" \
  --dart-define=SUPABASE_ANON_KEY="$SUPABASE_ANON_KEY" \
  --dart-define=GROQ_API_KEY="$GROQ_API_KEY" \
  --dart-define=TYPECAST_API_KEY="$TYPECAST_API_KEY"
