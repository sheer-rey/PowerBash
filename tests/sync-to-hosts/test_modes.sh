#!/bin/bash
# ============================================================================
# test_modes.sh — Verify parallel vs serial mode
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Mode: Serial"

    run_test_case "--serial mode" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run --serial 2>&1" \
        assert_contains "Serial"

    run_test_case "Serial with -v" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run --serial -v 2>&1" \
        assert_contains "Serial"

    local tmpconf
    tmpconf=$(mktemp)
    echo '10.0.0.1' > "$tmpconf"
    run_test_case "Serial with config file" \
        "$SCRIPT --ssh-timeout 1 -c \"$tmpconf\" -s /tmp -d /tmp --dry-run --serial 2>&1" \
        assert_contains "Serial"

    print_section_header "Mode: Parallel (default)"

    # --dry-run auto-enables serial, so test parallel mode detection without --dry-run
    run_test_case "Parallel mode (default, no --serial)" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -v 2>&1" \
        assert_contains "Parallel"

    run_test_case "Parallel with -j 1" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -j 1 -v 2>&1" \
        assert_contains "Parallel"

    run_test_case "Parallel with -j 2" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -j 2 -v 2>&1" \
        assert_contains "Parallel"

    print_section_header "Mode: Dry-run"

    run_test_case "--dry-run auto-enables serial for cleaner output" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Serial"

    run_test_case "Dry-run shows '[DRY-RUN]'" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "DRY-RUN"

    run_test_case "Dry-run with -vv" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run -vv 2>&1" \
        assert_contains "DRY-RUN"

    print_section_header "Mode: Summary Output"

    run_test_case "Serial mode shows summary" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial 2>&1" \
        assert_contains "Sync Summary"

    run_test_case "Parallel mode shows summary" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Sync Summary"

    run_test_case "Summary shows Total" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Total:"

    run_test_case "Summary shows OK count" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "OK:"

    run_test_case "Summary shows SKIP count" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "SKIP:"
}
