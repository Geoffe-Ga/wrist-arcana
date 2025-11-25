#!/bin/bash
# run-tests.sh - Run tests consistently across local, pre-commit, and CI
#
# Usage:
#   ./run-tests.sh                                    # Run all unit tests
#   ./run-tests.sh unit                              # Run all unit tests
#   ./run-tests.sh ui                                # Run all UI tests
#   ./run-tests.sh DrawCardViewResponsivenessUITests # Run specific UI test suite

set -e  # Exit on error

# Configuration
PROJECT_DIR="WristArcana"
PROJECT_FILE="WristArcana.xcodeproj"
SCHEME="WristArcana Watch App"
SIMULATOR="Apple Watch Ultra 2 (49mm)"

# Parse arguments
TEST_TYPE="${1:-unit}"  # Default to unit tests

case "$TEST_TYPE" in
  unit)
    TEST_TARGET="WristArcana Watch AppTests"
    TEST_SUITE=""
    TEST_NAME="Unit Tests"
    ;;
  ui)
    TEST_TARGET="WristArcana Watch AppUITests"
    TEST_SUITE=""
    TEST_NAME="UI Tests (All Suites)"
    ;;
  *)
    # Assume it's a specific UI test suite
    TEST_TARGET="WristArcana Watch AppUITests"
    TEST_SUITE="$TEST_TYPE"
    TEST_NAME="UI Tests ($TEST_SUITE)"
    ;;
esac

echo "🧪 Running $TEST_NAME for WristArcana"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "Simulator: $SIMULATOR"
if [ -n "$TEST_SUITE" ]; then
  echo "Test Suite: $TEST_SUITE"
fi
echo ""

# Navigate to project directory
cd "$(dirname "$0")/.."

# Run tests
echo "▶️  Starting test run..."
echo ""

# Build test command based on whether we're testing a specific suite or all tests
if [ -n "$TEST_SUITE" ]; then
  # Specific test suite
  ONLY_TESTING_VALUE="$TEST_TARGET/$TEST_SUITE"
else
  # All tests in target
  ONLY_TESTING_VALUE="$TEST_TARGET"
fi

xcodebuild test \
  -project "$PROJECT_DIR/$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -destination "platform=watchOS Simulator,name=$SIMULATOR" \
  -only-testing:"$ONLY_TESTING_VALUE" \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee /tmp/wrist-arcana-test-output.log | \
  grep -E "(Testing started|Test case.*passed|Test case.*failed|TEST FAILED|TEST SUCCEEDED|Failing tests:)" || true

# Check exit status
if [ ${PIPESTATUS[0]} -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All tests passed!"
    exit 0
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Tests failed"
    echo ""
    echo "Full output saved to: /tmp/wrist-arcana-test-output.log"
    exit 1
fi
