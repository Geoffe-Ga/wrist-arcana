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
SIMULATOR="${SIMULATOR:-Apple Watch Ultra 2 (49mm)}"  # Allow override via env var

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

# Build test command based on whether we're testing a specific suite or all tests
if [ -n "$TEST_SUITE" ]; then
  # Specific test suite
  ONLY_TESTING_VALUE="$TEST_TARGET/$TEST_SUITE"
else
  # All tests in target
  ONLY_TESTING_VALUE="$TEST_TARGET"
fi

# Enable code coverage for unit tests only (more meaningful than UI test coverage)
if [ "$TEST_TYPE" = "unit" ]; then
  # Remove old coverage results to avoid conflicts
  rm -rf /tmp/TestResults.xcresult 2>/dev/null || true
  COVERAGE_FLAGS="-enableCodeCoverage YES -resultBundlePath /tmp/TestResults.xcresult"
  echo "📊 Code coverage enabled"
else
  COVERAGE_FLAGS=""
fi

# Run tests
echo "▶️  Running tests..."
echo ""

xcodebuild test \
  -project "$PROJECT_DIR/$PROJECT_FILE" \
  -scheme "$SCHEME" \
  -destination "platform=watchOS Simulator,name=$SIMULATOR" \
  -only-testing:"$ONLY_TESTING_VALUE" \
  $COVERAGE_FLAGS \
  CODE_SIGNING_ALLOWED=NO \
  2>&1 | tee /tmp/wrist-arcana-test-output.log | \
  grep -E "(Testing started|Test case.*passed|Test case.*failed|TEST FAILED|TEST SUCCEEDED|Failing tests:|error:|Error)" || true

# Check exit status
EXIT_CODE=${PIPESTATUS[0]}

if [ $EXIT_CODE -eq 0 ]; then
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "✅ All tests passed!"

    # Show coverage report if enabled
    if [ "$TEST_TYPE" = "unit" ] && [ -d "/tmp/TestResults.xcresult" ]; then
        echo ""
        echo "📊 Code Coverage Report:"
        if command -v jq >/dev/null 2>&1; then
            xcrun xccov view --report --json /tmp/TestResults.xcresult > /tmp/coverage.json 2>/dev/null || true
            COVERAGE=$(jq ".lineCoverage" /tmp/coverage.json 2>/dev/null || echo "0")
            COVERAGE_PCT=$(echo "$COVERAGE * 100" | bc 2>/dev/null || echo "N/A")
            echo "   Line Coverage: ${COVERAGE_PCT}%"
        else
            echo "   (Install jq for detailed coverage: brew install jq)"
            xcrun xccov view --report /tmp/TestResults.xcresult 2>/dev/null || echo "   Coverage data not available"
        fi
    fi
    exit 0
else
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "❌ Tests failed (exit code: $EXIT_CODE)"
    echo ""
    echo "📋 Failing tests:"
    grep "Failing tests:" /tmp/wrist-arcana-test-output.log || echo "  (No failing tests list found)"
    grep -A 1 "Failing tests:" /tmp/wrist-arcana-test-output.log | tail -n +2 || true
    echo ""
    echo "🔍 Recent failures:"
    grep "failed on" /tmp/wrist-arcana-test-output.log | tail -10 || echo "  (No test failures found)"
    echo ""
    echo "⚠️  Build errors:"
    grep -i "error:" /tmp/wrist-arcana-test-output.log | head -10 || echo "  (No build errors found)"
    echo ""
    echo "Full output saved to: /tmp/wrist-arcana-test-output.log"
    echo ""
    echo "💡 View full log: cat /tmp/wrist-arcana-test-output.log"
    exit 1
fi
