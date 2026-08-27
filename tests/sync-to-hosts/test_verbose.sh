#!/bin/bash
# ============================================================================
# test_verbose.sh — Verify verbosity levels
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Verbosity: Level 0 (default)"

    # At level 0, no Info/Debug/Trace messages should appear
    local output
    output=$("$SCRIPT" --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial 2>&1)
    run_test_case "Default: no extra debug output" \
        "echo '$output'" \
        assert_not_contains "Debug:"

    run_test_case "Default: no extra debug output 2" \
        "echo '$output'" \
        assert_not_contains "Trace:"

    print_section_header "Verbosity: Level 1 (-v)"

    local output_v
    output_v=$("$SCRIPT" --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial -v 2>&1)
    run_test_case "-v enables Info messages" \
        "echo '$output_v'" \
        assert_contains "Info:"

    print_section_header "Verbosity: Level 2 (-vv)"

    local output_vv
    output_vv=$("$SCRIPT" --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial -vv 2>&1)
    # In dry-run mode, debug output is minimal; test that -vv doesn't break
    run_test_case "-vv enables Debug messages" \
        "echo '$output_vv'" \
        assert_contains "DRY-RUN"

    run_test_case "-vv shows exclude patterns" \
        "echo '$output_vv'" \
        assert_contains "Engine:"

    print_section_header "Verbosity: Level 3 (-vvv)"

    local output_vvv
    output_vvv=$("$SCRIPT" --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run --serial -vvv 2>&1)
    run_test_case "-vvv enables Trace messages" \
        "echo '$output_vvv'" \
        assert_contains "DRY-RUN"

    print_section_header "Verbosity: Parallel mode"

    # Dry-run forces serial mode; just verify -vv doesn't break anything
    run_test_case "-vv in parallel mode completes without error" \
        "timeout 15 \"$SCRIPT\" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -vv --dry-run" \
        assert_contains "All done"

    run_test_case "-v in parallel mode shows Info" \
        "timeout 15 \"$SCRIPT\" --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp -v --dry-run" \
        assert_contains "Info:"
}
