#!/bin/bash
# run-ui-tests.sh - Run UI tests consistently across local, pre-commit, and CI
#
# This script ensures UI tests are run the same way in all environments

set -e  # Exit on error

# Configuration
PROJECT_DIR="WristArcana"
PROJECT_FILE="WristArcana.xcodeproj"
SCHEME="WristArcana Watch App"
TEST_TARGET="WristArcana Watch AppUITests"
TEST_SUITE="${1:-DrawCardViewResponsivenessUITests}"  # Default to DrawCardViewResponsivenessUITests, allow override
SIMULATOR="Apple Watch Ultra 2 (49mm)"

echo "🧪 Running UI Tests for WristArcana"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Simulator: $SIMULATOR"
echo "Test Suite: $TEST_SUITE"
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."

# Run tests
echo "▶️  Starting test run..."
echo ""

xcodebuild test \
  -project "$PROJECT_DIR/$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -destination "platform=watchOS Simulator,name=$SIMULATOR" \
  -only-testing:"$TEST_TARGET/$TEST_SUITE" \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee /tmp/wrist-arcana-test-output.log | \
  grep -E "(Testing started|Test case.*passed|Test case.*failed|TEST FAILED|TEST SUCCEEDED|Failing tests:)" || true

# Check exit status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All UI tests passed!"
    exit 0
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ UI tests failed"
    echo ""
    echo "Full output saved to: /tmp/wrist-arcana-test-output.log"
    exit 1
fi
