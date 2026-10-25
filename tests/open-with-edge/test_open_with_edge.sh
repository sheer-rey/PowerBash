#!/bin/bash
# ============================================================================
# test_open_with_edge.sh — Verify PowerBash OpenWithEdge tool
# ============================================================================
# WSL-gate behavior is environment-aware: run the suite inside WSL to verify
# the gate passes and target resolution works (via --dry-run, no Edge window
# opens), or on a plain Linux host to verify the gate rejects execution.
# ============================================================================

ROOT_DIR="${ROOT_DIR:-$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)}"
TOOL="$ROOT_DIR/HOME/.nicetools/bin/OpenWithEdge"

# Load test infrastructure when executed directly (runner already sourced it)
if ! declare -f assert_eq >/dev/null; then
    source "$ROOT_DIR/tests/test_runner.sh"
fi

# ── WSL environment detection (same logic as OpenWithEdge itself) ──────────
ow_is_wsl=0
if [ -n "${WSL_DISTRO_NAME:-}" ] || grep -qi microsoft /proc/version 2>/dev/null; then
    ow_is_wsl=1
fi

run_tests() {
    print_section_header "WSL environment probe"

    # --help must be reachable only after the WSL gate passes; outside WSL
    # the tool must refuse before doing anything else.
    local out rc
    out=$(bash "$TOOL" --help 2>&1)
    rc=$?
    if [ $ow_is_wsl -eq 1 ]; then
        assert_eq "$rc" "0" "WSL gate passes inside WSL (--help reachable)"
        assert_contains "$out" "Microsoft Edge" "WSL gate: help printed inside WSL"
    else
        assert_eq "$rc" "1" "OpenWithEdge rejected outside WSL"
        assert_contains "$out" "only works inside a WSL environment" "WSL gate: rejection message"
        assert_not_contains "$out" "Usage" "WSL gate: help not printed when rejected"
    fi

    if [ $ow_is_wsl -eq 0 ]; then
        echo "  SKIP: target resolution tests require a WSL environment"
        return 0
    fi

    print_section_header "Target resolution (dry-run)"

    # Dry-run prints the resolved launch command; its exit status also serves
    # as a gate for WSL hosts without Edge installed.
    out=$(bash "$TOOL" --dry-run 2>&1)
    if [ $? -ne 0 ]; then
        echo "  SKIP: no msedge.exe found, dry-run tests require it"
        return 0
    fi
    assert_not_contains "$out" "file://" "dry-run without arguments opens start page"

    local tmp expected win_expected
    tmp=$(mktemp -d)
    touch "$tmp/sample.txt"

    # absolute WSL path -> file:// URL via wslpath -m
    expected="file://$(wslpath -m "$tmp/sample.txt")"
    out=$(bash "$TOOL" --dry-run "$tmp/sample.txt" 2>&1)
    assert_contains "$out" "$expected" "absolute WSL path becomes file:// URL"

    # relative WSL path -> same file:// URL after realpath resolution
    out=$(cd "$tmp" && bash "$TOOL" --dry-run sample.txt 2>&1)
    assert_contains "$out" "$expected" "relative WSL path resolved before conversion"

    # http(s) URLs pass through untouched
    out=$(bash "$TOOL" --dry-run "https://example.com" 2>&1)
    assert_contains "$out" "https://example.com" "https URL passes through"

    # Windows path -> file:// URL of its normalized form (only when C: mounted)
    if [ -d "/mnt/c/Windows" ]; then
        win_expected="file://$(wslpath -m /mnt/c/Windows)"
        out=$(bash "$TOOL" --dry-run 'C:\Windows' 2>&1)
        assert_contains "$out" "$win_expected" "Windows path becomes file:// URL"
    fi

    # multiple targets -> all converted, opened as separate tabs
    out=$(bash "$TOOL" --dry-run "$tmp/sample.txt" "https://example.com" 2>&1)
    assert_contains "$out" "$expected" "multi-target: file converted"
    assert_contains "$out" "https://example.com" "multi-target: URL kept"

    # nonexistent local path -> error message and exit code 1
    out=$(bash "$TOOL" --dry-run "$tmp/no-such-file.txt" 2>&1)
    rc=$?
    assert_eq "$rc" "1" "nonexistent path exits with error code"
    assert_contains "$out" "does not exist" "nonexistent path reports error"

    rm -rf "$tmp"
}

# Allow direct execution in addition to running via tests/run_tests.sh
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    run_tests
    print_summary
    [[ $FAIL_COUNT -eq 0 ]] || exit 1
fi
