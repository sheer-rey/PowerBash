#!/bin/bash
# ============================================================================
# test_completions.sh — Verify PowerBash bash completions
# ============================================================================

COMPLETIONS="$ROOT_DIR/HOME/.nicetools/completions/powerbash-completions.bash"

# ── Helper: run a completion function and capture COMPREPLY ────────────────
# Usage: run_completion <func> <words...>
# Sets COMP_WORDS/COMP_CWORD, invokes the function, echoes COMPREPLY.
run_completion() {
    local func="$1"
    shift
    COMP_WORDS=("$@")
    COMP_CWORD=$(( ${#COMP_WORDS[@]} - 1 ))
    COMPREPLY=()
    "$func"
    echo "${COMPREPLY[*]}"
}

# ── Helper: assert completion output equals expected ───────────────────────
# Usage: assert_completion <func> <expected> <name> <words...>
assert_completion() {
    local func="$1"
    local expected="$2"
    local name="$3"
    shift 3
    local actual
    actual=$(run_completion "$func" "$@")
    assert_eq "$actual" "$expected" "$name"
}

run_tests() {
    print_section_header "Completion Bindings"

    # Verify each command is bound to its completion function
    local bindings
    bindings=$(source "$COMPLETIONS" && complete -p osc_yank fix_owner ArchivetoRDN CreateSSHTunnel SyncToHosts)
    assert_contains "$bindings" "complete -F _osc_yank osc_yank" "osc_yank bound"
    assert_contains "$bindings" "complete -F _fix_owner fix_owner" "fix_owner bound"
    assert_contains "$bindings" "complete -F _ArchivetoRDN ArchivetoRDN" "ArchivetoRDN bound"
    assert_contains "$bindings" "complete -F _CreateSSHTunnel CreateSSHTunnel" "CreateSSHTunnel bound"
    assert_contains "$bindings" "complete -F _SyncToHosts SyncToHosts" "SyncToHosts bound"

    print_section_header "osc_yank"

    source "$COMPLETIONS"
    assert_completion _osc_yank "--help" "osc_yank -- completes long options" osc_yank --
    assert_completion _osc_yank "-h --help" "osc_yank - completes short options" osc_yank -
    assert_completion _osc_yank "-h --help" "osc_yank <space> completes options" osc_yank ""

    print_section_header "fix_owner"

    assert_completion _fix_owner "--dereference --no-dereference --help" "fix_owner -- completes long options" fix_owner --
    assert_completion _fix_owner "--no-dereference" "fix_owner --no filters prefix" fix_owner --no
    assert_completion _fix_owner "--dereference --no-dereference -h --help" "fix_owner - completes all options" fix_owner -
    assert_completion _fix_owner "--dereference --no-dereference -h --help" "fix_owner <space> completes options" fix_owner ""
    assert_completion _fix_owner "--dereference --no-dereference -h --help" "fix_owner <space> after flag completes options" fix_owner --no-dereference ""

    print_section_header "ArchivetoRDN"

    assert_completion _ArchivetoRDN "--host --user --directory --transfer --delete --delete-all --help" "ArchivetoRDN -- completes long options" ArchivetoRDN --
    assert_completion _ArchivetoRDN "-H --host -U --user -C --directory -t --transfer -d --delete -D --delete-all -h --help" "ArchivetoRDN - completes short options" ArchivetoRDN -
    assert_completion _ArchivetoRDN "-H --host -U --user -C --directory -t --transfer -d --delete -D --delete-all -h --help" "ArchivetoRDN <space> completes options" ArchivetoRDN ""

    print_section_header "CreateSSHTunnel"

    assert_completion _CreateSSHTunnel "--verbose --port --jump-profile --jump-user --jump-host --help" "CreateSSHTunnel -- completes long options" CreateSSHTunnel --
    assert_completion _CreateSSHTunnel "-v --verbose -p --port -P --jump-profile -U --jump-user -H --jump-host -h --help" "CreateSSHTunnel - completes short options" CreateSSHTunnel -
    assert_completion _CreateSSHTunnel "-v --verbose -p --port -P --jump-profile -U --jump-user -H --jump-host -h --help" "CreateSSHTunnel <space> completes options" CreateSSHTunnel ""
    assert_completion _CreateSSHTunnel "-v --verbose -p --port -P --jump-profile -U --jump-user -H --jump-host -h --help" "CreateSSHTunnel <space> after flag completes options" CreateSSHTunnel -v ""

    print_section_header "SyncToHosts"

    assert_completion _SyncToHosts "--help --serial --dry-run --show-output --hosts --config --all --src --file --dst --rsync --scp --exclude --no-default-excludes --timeout --ssh-timeout --jobs" "SyncToHosts -- completes long options" SyncToHosts --
    assert_completion _SyncToHosts "--serial --show-output --src --scp --ssh-timeout" "SyncToHosts --s filters prefix" SyncToHosts --s
    assert_completion _SyncToHosts "-h --help -v --serial --dry-run --show-output --hosts -c --config --all -s --src -f --file -d --dst --rsync --scp -e --exclude --no-default-excludes --timeout --ssh-timeout -j --jobs" "SyncToHosts - completes all options" SyncToHosts -
    assert_completion _SyncToHosts "-h --help -v --serial --dry-run --show-output --hosts -c --config --all -s --src -f --file -d --dst --rsync --scp -e --exclude --no-default-excludes --timeout --ssh-timeout -j --jobs" "SyncToHosts <space> completes options" SyncToHosts ""
    assert_completion _SyncToHosts "-h --help -v --serial --dry-run --show-output --hosts -c --config --all -s --src -f --file -d --dst --rsync --scp -e --exclude --no-default-excludes --timeout --ssh-timeout -j --jobs" "SyncToHosts <space> after flag completes options" SyncToHosts --serial ""

    # Comma-separated host list: the prefix before the comma must be preserved.
    local comma_out
    comma_out=$(run_completion _SyncToHosts SyncToHosts --hosts "localhost,")
    assert_contains "$comma_out" "localhost," "SyncToHosts --hosts localhost, keeps comma prefix"
    assert_not_contains "$comma_out" "-h --help" "SyncToHosts --hosts localhost, does not complete options"

    comma_out=$(run_completion _SyncToHosts SyncToHosts --hosts "localhost,Hy")
    assert_contains "$comma_out" "localhost,Hy" "SyncToHosts --hosts localhost,Hy keeps comma prefix"

    # A complete host list (contains a comma but the last part is a full host)
    # should not offer any completion, so the current word is left untouched.
    comma_out=$(run_completion _SyncToHosts SyncToHosts --hosts "localhost,github.com")
    assert_eq "$comma_out" "" "SyncToHosts complete host list offers no completion"
}
