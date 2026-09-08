#!/bin/bash
# ============================================================================
# run_tests.sh — Main test orchestrator for all components.
# ============================================================================

set -uo pipefail  # Note: don't use -e, tests intentionally check exit codes
export ST_SSH_TIMEOUT=1  # Speed up SSH connection tests

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

# Components to test (add new ones here)
COMPONENTS=("sync-to-hosts" "completions")

# Source test runner
source "$SCRIPT_DIR/test_runner.sh"

TOTAL_PASSED=0
TOTAL_FAILED=0
TOTAL_TESTS=0

print_section_header "Test Suite: ${*:-All}"

for component in "${COMPONENTS[@]}"; do
    TEST_DIR="$SCRIPT_DIR/$component"

    # Skip if component directory doesn't exist
    if [[ ! -d "$TEST_DIR" ]]; then
        echo -e "${YELLOW}SKIP: Component '$component' not found at $TEST_DIR${RESET}"
        continue
    fi

    print_section_header "Component: $component"

    # Run all test_*.sh files in the component directory
    for test_file in "$TEST_DIR"/test_*.sh; do
        [[ -f "$test_file" ]] || continue

        echo -e "${BOLD}--- $(basename "$test_file") ---${RESET}"

        # Source and run the test file (it must define a run_tests function)
        source "$test_file"
        run_tests

        echo ""
    done

    echo -e "${BOLD}Component summary for $component:${RESET}"
    echo -e "  Tests: $TEST_COUNT  Passed: $PASS_COUNT  Failed: $FAIL_COUNT"
    echo ""

    TOTAL_TESTS=$((TOTAL_TESTS + TEST_COUNT))
    TOTAL_PASSED=$((TOTAL_PASSED + PASS_COUNT))
    TOTAL_FAILED=$((TOTAL_FAILED + FAIL_COUNT))

    # Reset counters for next component
    TEST_COUNT=0
    PASS_COUNT=0
    FAIL_COUNT=0
done

print_section_header "Overall Summary"
echo -e "Total tests: $TOTAL_TESTS"
echo -e "Total passed: $TOTAL_PASSED"
if [[ $TOTAL_FAILED -gt 0 ]]; then
    echo -e "Total failed: ${YELLOW}$TOTAL_FAILED${RESET}"
else
    echo -e "Total failed: ${GREEN}0${RESET}"
fi

# Exit with error if any test failed
if [[ $TOTAL_FAILED -gt 0 ]]; then
    exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}All tests passed!${RESET}"
