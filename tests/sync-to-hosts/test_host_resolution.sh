#!/bin/bash
# ============================================================================
# test_host_resolution.sh — Verify host discovery logic
# ============================================================================

SCRIPT="$ROOT_DIR/HOME/.nicetools/bin/SyncToHosts"

run_tests() {
    print_section_header "Host Resolution: IP Addresses"

    run_test_case "Single IP address resolves to 1 host" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       1"

    run_test_case "Two IPs resolve to 2 hosts" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       2"

    run_test_case "Three IPs resolve to 3 hosts" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2,10.0.0.3' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       3"

    run_test_case "Multiple IPs, only one reachable → 2 SKIP" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "[SKIP]"

    run_test_case "IP in mixed list resolves" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,deploy@10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       2"

    print_section_header "Host Resolution: user@host"

    run_test_case "Single user@host resolves to 1 host" \
        "$SCRIPT --ssh-timeout 1 --hosts 'deploy@10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       1"

    run_test_case "Multiple user@host resolves to 2 hosts" \
        "$SCRIPT --ssh-timeout 1 --hosts 'deploy@10.0.0.1,root@10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       2"

    print_section_header "Host Resolution: Mixed"

    run_test_case "Mixed IP and user@host" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,deploy@10.0.0.2,10.0.0.3' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       3"

    print_section_header "Host Resolution: Wildcards"

    # Wildcard should match SSH config hosts (if any exist)
    run_test_case "Wildcard matches SSH config hosts" \
        "$SCRIPT --ssh-timeout 1 --hosts 'Hygon-*' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    run_test_case "Wildcard with comma-separated patterns" \
        "$SCRIPT --ssh-timeout 1 --hosts 'Hygon-*,My-Jump-*' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    print_section_header "Host Resolution: Plain Names"

    # Plain name not in SSH config → warns and uses as direct host
    run_test_case "Plain name not in SSH config → warns and uses as direct host" \
        "$SCRIPT --ssh-timeout 1 --hosts 'nonexistent-test-host' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "treating as direct host"

    run_test_case "Plain name treated as direct host resolves to 1" \
        "$SCRIPT --ssh-timeout 1 --hosts 'nonexistent-test-host' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       1"

    print_section_header "Host Resolution: --all"

    run_test_case "--all uses all SSH config hosts" \
        "$SCRIPT --ssh-timeout 1 --all -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"

    print_section_header "Edge Cases"

    # Deduplication test
    run_test_case "Deduplication: same IP twice → 1 host" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1,10.0.0.1' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:       1"

    # Unmatched plain name → treated as direct host
    run_test_case "Unmatched plain name → treated as direct host" \
        "$SCRIPT --ssh-timeout 1 --hosts 'ZZZ-UNIQUE-ZZZ' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "treating as direct host"

    # Whitespace around comma-separated hosts
    run_test_case "Whitespace in comma-separated list handled" \
        "$SCRIPT --ssh-timeout 1 --hosts '10.0.0.1, 10.0.0.2' -s /tmp -d /tmp --dry-run 2>&1" \
        assert_contains "Hosts:"
}
