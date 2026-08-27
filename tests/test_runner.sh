#!/bin/bash
# ============================================================================
# test_runner.sh — Common test infrastructure for all components.
# ============================================================================
# Sourced by individual test files and run_tests.sh.
# Does NOT run anything on its own.
# ============================================================================

# Colors (only if terminal supports them)
if [[ -t 1 ]]; then
    GREEN='\033[32m'
    RED='\033[31m'
    YELLOW='\033[33m'
    BOLD='\033[1m'
    RESET='\033[0m'
else
    GREEN='' RED='' YELLOW='' BOLD='' RESET=''
fi

# Counters
TEST_COUNT=0
PASS_COUNT=0
FAIL_COUNT=0

# ── Helper: assert_eq ──────────────────────────────────────────────────────
# Compare actual output against expected (exact match).
# Usage: assert_eq <actual> <expected> "<test-name>"
assert_eq() {
    local actual="$1"
    local expected="$2"
    local name="$3"

    if [[ "$actual" == "$expected" ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name"
        echo "    Expected: $(echo "$expected" | head -5)"
        echo "    Actual:   $(echo "$actual" | head -5)"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

# ── Helper: assert_contains ────────────────────────────────────────────────
# Check that output contains a substring.
# Usage: assert_contains <output> <substring> "<test-name>"
assert_contains() {
    local output="$1"
    local expected="$2"
    local name="$3"

    if [[ "$output" == *"$expected"* ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name"
        echo "    Expected to contain: $expected"
        echo "    Actual output: $output"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

# ── Helper: assert_not_contains ────────────────────────────────────────────
# Check that output does NOT contain a substring.
# Usage: assert_not_contains <output> <substring> "<test-name>"
assert_not_contains() {
    local output="$1"
    local unexpected="$2"
    local name="$3"

    if [[ "$output" != *"$unexpected"* ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name"
        echo "    Expected to NOT contain: $unexpected"
        echo "    Actual output: $output"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

# ── Helper: assert_exit_code ───────────────────────────────────────────────
# Check that a command exits with a specific code.
# Usage: assert_exit_code <command> <expected_code> "<test-name>"
assert_exit_code() {
    local cmd="$1"
    local expected="$2"
    local name="$3"

    local actual
    eval "$cmd" >/dev/null 2>&1
    actual=$?

    if [[ "$actual" -eq "$expected" ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name (exit=$actual)"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name (expected=$expected, actual=$actual)"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

# ── Helper: run_test_case ──────────────────────────────────────────────────
# Run a command, capture output+exit, and perform a check.
# Usage: run_test_case <description> <command> <check_function>
#   check_function receives: <exit_code> <stdout> <stderr>
#
# Examples:
#   run_test_case "output contains X" \
#       "$SCRIPT -d /tmp -s /tmp" \
#       assert_contains "X"
#   run_test_case "exit code 1" \
#       "$SCRIPT -d /tmp" \
#       assert_exit_code 1
run_test_case() {
    local desc="$1"
    local cmd="$2"
    local check="$3"


    echo -e "Test: $desc"
    local stdout stderr exit_code
    stdout=$(eval "$cmd" 2>&1)
    exit_code=$?

    if [[ "$check" == assert_eq ]]; then
        assert_eq "$stdout" "$3" "$desc"
    elif [[ "$check" == assert_contains ]]; then
        assert_contains "$stdout" "$4" "$desc"
    elif [[ "$check" == assert_not_contains ]]; then
        assert_not_contains "$stdout" "$4" "$desc"
    elif [[ "$check" == assert_exit_code ]]; then
        assert_exit_code "$cmd" "$4" "$desc"
    else
        # Generic: run the command and check exit code is 0
        if [[ $exit_code -eq 0 ]]; then
            echo -e "  ${GREEN}PASS${RESET}: $desc"
            ((PASS_COUNT++))
        else
            echo -e "  ${RED}FAIL${RESET}: $desc (exit=$exit_code)"
            echo "    Output: $stdout"
            ((FAIL_COUNT++))
        fi
        ((TEST_COUNT++))
    fi
}

# ── Helper: print_section_header ───────────────────────────────────────────
print_section_header() {
    echo ""
    echo -e "${BOLD}=== $1 ===${RESET}"
    echo ""
}

# ── Helper: print_summary ──────────────────────────────────────────────────
print_summary() {
    echo ""
    echo "========================================"
    if [[ $FAIL_COUNT -eq 0 ]]; then
        echo -e "${GREEN}${BOLD}All $TEST_COUNT tests passed${RESET}"
    else
        echo -e "${YELLOW}${BOLD}$FAIL_COUNT / $TEST_COUNT tests failed${RESET}"
    fi
    echo "========================================"
}
