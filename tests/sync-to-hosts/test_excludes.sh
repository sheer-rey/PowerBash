#!/bin/bash
# ============================================================================
# test_excludes.sh — Verify default exclude patterns and --no-default-excludes
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

# The test environment cannot establish real SSH connections, so do_sync would
# return early at the connection check before building the rsync command. To
# exercise the exclude-merge logic, copy the script and override
# test_host_connection to always succeed.
#
# The copy must live in the same directory as the original so that script_root
# resolves the ../predefined file correctly.
TEST_SCRIPT="$(dirname "$SCRIPT")/SyncToHosts_test_tmp"
cp "$SCRIPT" "$TEST_SCRIPT"
chmod +x "$TEST_SCRIPT"
sed -i 's/^# --- Run ---/function test_host_connection { return 0; }\n\n# --- Run ---/' "$TEST_SCRIPT"

run_tests() {
    print_section_header "Excludes: Default behavior"

    # By default, user excludes are appended to the built-in defaults.
    run_test_case "Default excludes applied with user exclude" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' 2>&1" \
        assert_contains "exclude=.git"

    run_test_case "User exclude appended to defaults" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' 2>&1" \
        assert_contains "exclude=*.bak"

    print_section_header "Excludes: --no-default-excludes"

    # With --no-default-excludes, only user-supplied patterns are used.
    run_test_case "--no-default-excludes removes default .git" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' --no-default-excludes 2>&1" \
        assert_not_contains "exclude=.git"

    run_test_case "--no-default-excludes keeps user exclude" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' --no-default-excludes 2>&1" \
        assert_contains "exclude=*.bak"

    run_test_case "--no-default-excludes removes default *.log" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' --no-default-excludes 2>&1" \
        assert_not_contains "exclude=*.log"

    run_test_case "--no-default-excludes removes default known_hosts*" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial -e '*.bak' --no-default-excludes 2>&1" \
        assert_not_contains "exclude=known_hosts*"

    print_section_header "Excludes: Flag parsing"

    run_test_case "--no-default-excludes is accepted" \
        "$TEST_SCRIPT --ssh-timeout 1 --hosts '127.0.0.1' -s /tmp -d /tmp --dry-run --serial --no-default-excludes 2>&1" \
        assert_contains "DRY-RUN"

    # Clean up the temporary copy.
    rm -f "$TEST_SCRIPT"
}
