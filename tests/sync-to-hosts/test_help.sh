#!/bin/bash
# ============================================================================
# test_help.sh — Verify SyncToHosts help output
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Help Output"

    run_test_case "--help prints usage" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "Usage:"

    run_test_case "--help prints general options" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "Serial sync"

    run_test_case "--help prints host selection options" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "Wildcards match SSH config"

    run_test_case "--help prints Source/Destination options" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "--dst PATH"

    run_test_case "--help prints sync engine options" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "rsync"

    run_test_case "--help prints concurrency options" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "concurrent sync"

    run_test_case "--help prints host resolution rules" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "Plain hostname"

    run_test_case "--help prints examples" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "Hygon-"

    run_test_case "--help exits with code 0" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_exit_code 0

    run_test_case "-h exits with code 0" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_exit_code 0

    run_test_case "-v option listed" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "-v"

    run_test_case "--exclude option listed" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "exclude"

    run_test_case "Hosts option documented" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "hosts"

    run_test_case "Config option documented" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "config"

    run_test_case "--serial option documented" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "--serial"

    run_test_case "--dry-run option documented" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "--dry-run"

    run_test_case "--all option documented" \
        "$SCRIPT --ssh-timeout 1 -h" \
        assert_contains "ALL hosts"
}
