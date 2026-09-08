#!/bin/bash
# ============================================================================
# test_show_output.sh — Verify --show-output flag behavior
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Show Output: Flag parsing"

    run_test_case "--show-output is accepted (no error)" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial --show-output 2>&1" \
        assert_contains "DRY-RUN"

    run_test_case "--show-output with -v" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial --show-output -v 2>&1" \
        assert_contains "DRY-RUN"

    run_test_case "--show-output in parallel mode" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --show-output -v 2>&1" \
        assert_contains "Parallel"

    run_test_case "--show-output does not force serial mode" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --show-output -v 2>&1" \
        assert_contains "Parallel"

    print_section_header "Show Output: Dry-run behavior"

    # In dry-run mode, the DRY-RUN marker is always shown regardless of
    # --show-output (it is the core purpose of dry-run).
    run_test_case "Dry-run shows DRY-RUN marker without --show-output" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial 2>&1" \
        assert_contains "DRY-RUN"

    run_test_case "Dry-run shows DRY-RUN marker with --show-output" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial --show-output 2>&1" \
        assert_contains "DRY-RUN"
}
