#!/bin/bash
# ============================================================================
# test_syntax.sh — Verify SyncToHosts passes syntax checks
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

# ── Helpers that work with run_test_case ─────────────────────────────────────

assert_exit_0() {
    local cmd="$1"
    local name="$2"
    eval "$cmd" >/dev/null 2>&1
    local rc=$?
    if [[ $rc -eq 0 ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name (exit=$rc)"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

assert_not_zero() {
    local cmd="$1"
    local name="$2"
    local output
    output=$(eval "$cmd" 2>&1)
    if [[ "$output" -gt 0 ]] 2>/dev/null; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name (expected >0, got: $output)"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

assert_not_found() {
    local cmd="$1"
    local name="$2"
    local output
    output=$(eval "$cmd" 2>&1)
    if [[ -z "$output" ]]; then
        echo -e "  ${GREEN}PASS${RESET}: $name"
        ((PASS_COUNT++))
    else
        echo -e "  ${RED}FAIL${RESET}: $name (expected not found, got: $output)"
        ((FAIL_COUNT++))
    fi
    ((TEST_COUNT++))
}

run_tests() {
    print_section_header "Syntax Checks"

    run_test_case "Bash syntax check passes" \
        "bash -n '$SCRIPT'" \
        assert_exit_0

    run_test_case "File is executable" \
        "test -x '$SCRIPT'" \
        assert_exit_0

    run_test_case "File starts with bash shebang" \
        "head -1 '$SCRIPT'" \
        assert_contains "#!/bin/bash"

    run_test_case "File contains PrintHelp function" \
        "grep -c 'function PrintHelp' '$SCRIPT'" \
        assert_not_zero

    run_test_case "File contains main function" \
        "grep -c 'function main' '$SCRIPT'" \
        assert_not_zero

    run_test_case "File sources predefined" \
        "grep -c 'source.*predefined' '$SCRIPT'" \
        assert_not_zero

    run_test_case "File uses array-based commands (no eval on sync)" \
        "grep -cE 'eval.*(rsync|scp)' '$SCRIPT' || true" \
        assert_not_found
}
