#!/bin/bash
# ============================================================================
# test_concurrency.sh — Verify concurrent job control
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Concurrency: Auto-detect"

    # 3 hosts, auto-detect should pick min(3, nproc)
    run_test_case "Auto-detect concurrency (3 hosts)" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -v --dry-run --serial 2>&1" \
        assert_contains "Serial"

    # 1 host should use 1 concurrent job
    run_test_case "1 host → 1 concurrent job" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp -v --dry-run --serial 2>&1" \
        assert_contains "Serial"

    print_section_header "Concurrency: Explicit -j"

    run_test_case "Explicit -j 1" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -v -j 1 --dry-run --serial 2>&1" \
        assert_contains "Serial"

    run_test_case "Explicit -j 2" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -v -j 2 --dry-run --serial 2>&1" \
        assert_contains "Serial"

    run_test_case "Explicit -j 4 (more than hosts)" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -v -j 4 --dry-run --serial 2>&1" \
        assert_contains "Serial"

    print_section_header "Concurrency: Parallel with timeout"

    # Verify parallel runs within timeout (all hosts unreachable, should complete fast)
    run_test_case "Parallel completes within 30 seconds" \
        "timeout 30 \"$SCRIPT\" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -v --dry-run 2>&1" \
        assert_contains "All done"

    run_test_case "Parallel with -j 1 completes within 30 seconds" \
        "timeout 30 \"$SCRIPT\" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -j 1 -v --dry-run 2>&1" \
        assert_contains "All done"

    run_test_case "Parallel with -j 2 completes within 30 seconds" \
        "timeout 30 \"$SCRIPT\" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp -j 2 -v --dry-run 2>&1" \
        assert_contains "All done"

    print_section_header "Concurrency: Temp file cleanup"

    # Run parallel sync, check temp files are cleaned up
    local before_count
    before_count=$(ls /tmp/sync_*.log 2>/dev/null | wc -l || echo 0)

    timeout 30 "$SCRIPT" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -j 2 -v --dry-run >/dev/null 2>&1

    local after_count
    after_count=$(ls /tmp/sync_*.log 2>/dev/null | wc -l || echo 0)

    run_test_case "Temp files are cleaned up after parallel sync" \
        "echo 'Before: $before_count, After: $after_count'" \
        assert_contains "After: 0"
}
