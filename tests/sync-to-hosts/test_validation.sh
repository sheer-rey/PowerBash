#!/bin/bash
# ============================================================================
# test_validation.sh — Verify argument validation
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Argument Validation"

    # Missing both --src and --file
    run_test_case "Exit 1 when missing both --src and --file" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' --dry-run" \
        assert_exit_code 1

    # Missing --dst
    run_test_case "Exit 1 when missing --dst" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp --dry-run" \
        assert_exit_code 1

    # Missing --src and --file with --dst
    run_test_case "Exit 1 when missing --src/--file but has --dst" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' --dst /tmp --dry-run" \
        assert_exit_code 1

    # Valid minimal args (dry-run, so doesn't actually sync)
    run_test_case "Exit 0 with valid --src --dst --dry-run" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run" \
        assert_exit_code 0

    # Valid minimal args with --file
    run_test_case "Exit 0 with valid --file --dst --dry-run" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -f /etc/hostname -d /tmp --dry-run" \
        assert_exit_code 0

    # Error mentions missing --src/--file
    run_test_case "Error mentions --src or --file requirement" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' --dry-run" \
        assert_contains "src"

    # Error mentions --dst requirement
    run_test_case "Error mentions --dst requirement" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp --dry-run" \
        assert_contains "--dst"

    # Invalid option
    run_test_case "Exit 1 on unrecognized option" \
        "$SCRIPT --ssh-timeout 1 --bogus --dry-run" \
        assert_exit_code 1

    # Unknown short option
    run_test_case "Exit 1 on unknown short option" \
        "$SCRIPT --ssh-timeout 1 -z --dry-run" \
        assert_exit_code 1

    # Valid multiple --src
    run_test_case "Accept multiple --src" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -s /var -d /dest --dry-run" \
        assert_exit_code 0

    # Valid multiple --file
    run_test_case "Accept multiple --file" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -f /etc/hostname -f /etc/passwd -d /dest --dry-run" \
        assert_exit_code 0

    # Valid --exclude
    run_test_case "Accept --exclude" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /dest -e '*.bak' --dry-run" \
        assert_exit_code 0

    # Valid --timeout
    run_test_case "Accept --timeout" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /dest --timeout 60 --dry-run" \
        assert_exit_code 0

    # Valid --ssh-timeout
    run_test_case "Accept --ssh-timeout" \
        "$SCRIPT --hosts '10.0.0.1' -s /tmp -d /dest --ssh-timeout 10 --dry-run" \
        assert_exit_code 0

    # Valid --jobs
    run_test_case "Accept -j" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /dest -j 4 --dry-run" \
        assert_exit_code 0
}
