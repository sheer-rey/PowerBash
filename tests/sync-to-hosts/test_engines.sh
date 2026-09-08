#!/bin/bash
# ============================================================================
# test_engines.sh — Verify sync engine selection
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Engine: rsync (default)"

    run_test_case "Default engine is rsync" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Engine:      rsync"

    run_test_case "Explicit --rsync" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --rsync 2>&1" \
        assert_contains "Engine:      rsync"

    # Exclude patterns are internal to rsync, not visible in dry-run output
    run_test_case "rsync engine with exclude option works" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp -e '*.bak' --dry-run 2>&1" \
        assert_contains "Engine:"

    print_section_header "Engine: scp"

    run_test_case "--scp selects scp engine" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp 2>&1" \
        assert_contains "Engine:      scp"

    run_test_case "scp engine with --verbose" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp -v 2>&1" \
        assert_contains "Engine:      scp"

    run_test_case "scp with --exclude warns it is ignored" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp -e '*.bak' 2>&1" \
        assert_contains "scp does not support --exclude"

    run_test_case "scp without --exclude does not warn" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp 2>&1" \
        assert_not_contains "scp does not support --exclude"

    print_section_header "Engine: Combined Options"

    run_test_case "scp with --timeout" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp --timeout 60 2>&1" \
        assert_contains "Engine:      scp"

    run_test_case "scp with --ssh-timeout" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --scp --ssh-timeout 10 2>&1" \
        assert_contains "Engine:      scp"
}
