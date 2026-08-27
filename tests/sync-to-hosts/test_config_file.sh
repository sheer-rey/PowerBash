#!/bin/bash
# ============================================================================
# test_config_file.sh — Verify config file reading
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"
TMP_CONF=$(mktemp "/tmp/sync_test_config_XXXXXX.conf")

run_tests() {
    # Cleanup temp file
    trap "rm -f '$TMP_CONF'" EXIT

    print_section_header "Config File: Basic"

    # Single host
    echo "10.0.0.1" > "$TMP_CONF"
    run_test_case "Config with single IP" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       1"

    # Multiple hosts
    cat > "$TMP_CONF" <<'EOF'
10.0.0.1
deploy@10.0.0.2
Hygon-*
EOF
    run_test_case "Config with multiple hosts" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    print_section_header "Config File: Comments and Blank Lines"

    # Comments and blank lines
    cat > "$TMP_CONF" <<'EOF'
# This is a comment
10.0.0.1

# Another comment
deploy@10.0.0.2
EOF
    run_test_case "Config with comments and blank lines" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    # Inline comments
    cat > "$TMP_CONF" <<'EOF'
10.0.0.1 # inline comment
10.0.0.2 # another inline comment
EOF
    run_test_case "Config with inline comments" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    print_section_header "Config File: Edge Cases"

    # Empty file
    cat > "$TMP_CONF" <<'EOF'
# Only comments

# And blank lines

EOF
    run_test_case "Config with only comments and blanks → no hosts" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_exit_code 1

    # Non-existent file
    run_test_case "Non-existent config file → error" \
        "$SCRIPT --ssh-timeout 1 -c '/tmp/does_not_exist_12345.conf' -s /tmp -d /tmp" \
        assert_exit_code 1

    # Config combined with --hosts
    echo "10.0.0.1" > "$TMP_CONF"
    run_test_case "Config + --hosts combined" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' --hosts '10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    # Config with --serial
    echo "10.0.0.1" > "$TMP_CONF"
    run_test_case "Config with --serial" \
        "$SCRIPT --ssh-timeout 1 -c '$TMP_CONF' -s /tmp -d /tmp --dry-run --serial" \
        assert_contains "Serial"
}
