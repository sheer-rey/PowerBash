####################################################################################################
# @file     powerbash-completions.bash
# @brief    Bash completion for PowerBash exported functions and nicetools scripts.
#
# @author   sheer.rey<sheer.rey@gmail.com>
# @date     09/08/2026
# @version  0.1.0
####################################################################################################

# ============================================================================
# Shared helpers
# ============================================================================

## List host names defined in ~/.ssh/config (excluding wildcard/negation entries)
_powerbash_ssh_hosts() {
    local config_file="${HOME}/.ssh/config"
    if [ -f "${config_file}" ]; then
        awk '
            /^[[:space:]]*Host[[:space:]]/ {
                for (i = 1; i <= NF; i++) {
                    if ($i == "Host") {
                        for (j = i + 1; j <= NF; j++) print $j
                        break
                    }
                }
            }
        ' "${config_file}" | grep -v '^[*!]'
    fi
}

## List SSH config profiles (same as hosts, used for --jump-profile)
_powerbash_ssh_profiles() {
    _powerbash_ssh_hosts
}

# ============================================================================
# osc_yank
# ============================================================================
_osc_yank() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        -h|--help)
            return 0
            ;;
    esac

    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help" -- "${cur}") )
        return 0
    fi

    # complete with readable files
    COMPREPLY=( $(compgen -f -- "${cur}") )
    return 0
}
complete -F _osc_yank osc_yank

# ============================================================================
# fix_owner
# ============================================================================
_fix_owner() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        -h|--help)
            return 0
            ;;
    esac

    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "--dereference --no-dereference -h --help" -- "${cur}") )
        return 0
    fi

    # complete with directories
    COMPREPLY=( $(compgen -d -- "${cur}") )
    return 0
}
complete -F _fix_owner fix_owner

# ============================================================================
# ArchivetoRDN
# ============================================================================
_ArchivetoRDN() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        -H|--host)
            COMPREPLY=( $(compgen -W "$(_powerbash_ssh_hosts)" -- "${cur}") )
            return 0
            ;;
        -U|--user)
            COMPREPLY=( $(compgen -u -- "${cur}") )
            return 0
            ;;
        -C|--directory)
            COMPREPLY=( $(compgen -d -- "${cur}") )
            return 0
            ;;
        -h|--help)
            return 0
            ;;
    esac

    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-H --host -U --user -C --directory -t --transfer -d --delete -D --delete-all -h --help" -- "${cur}") )
        return 0
    fi

    # complete with files
    COMPREPLY=( $(compgen -f -- "${cur}") )
    return 0
}
complete -F _ArchivetoRDN ArchivetoRDN

# ============================================================================
# CreateSSHTunnel
# ============================================================================
_CreateSSHTunnel() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        -p|--port)
            COMPREPLY=( $(compgen -W "$(seq 1 65535)" -- "${cur}") )
            return 0
            ;;
        -P|--jump-profile)
            COMPREPLY=( $(compgen -W "$(_powerbash_ssh_profiles)" -- "${cur}") )
            return 0
            ;;
        -U|--jump-user)
            COMPREPLY=( $(compgen -u -- "${cur}") )
            return 0
            ;;
        -H|--jump-host)
            COMPREPLY=( $(compgen -W "$(_powerbash_ssh_hosts)" -- "${cur}") )
            return 0
            ;;
        -h|--help)
            return 0
            ;;
    esac

    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-v --verbose -p --port -P --jump-profile -U --jump-user -H --jump-host -h --help" -- "${cur}") )
        return 0
    fi

    # complete with hosts (remote_ip:port)
    COMPREPLY=( $(compgen -W "$(_powerbash_ssh_hosts)" -- "${cur}") )
    return 0
}
complete -F _CreateSSHTunnel CreateSSHTunnel

# ============================================================================
# SyncToHosts
# ============================================================================
_SyncToHosts() {
    local cur prev
    cur="${COMP_WORDS[COMP_CWORD]}"
    prev="${COMP_WORDS[COMP_CWORD-1]}"

    case "${prev}" in
        --hosts)
            COMPREPLY=( $(compgen -W "$(_powerbash_ssh_hosts)" -- "${cur}") )
            return 0
            ;;
        -c|--config)
            COMPREPLY=( $(compgen -f -- "${cur}") )
            return 0
            ;;
        -s|--src)
            COMPREPLY=( $(compgen -d -- "${cur}") )
            return 0
            ;;
        -f|--file)
            COMPREPLY=( $(compgen -f -- "${cur}") )
            return 0
            ;;
        -d|--dst)
            COMPREPLY=( $(compgen -d -- "${cur}") )
            return 0
            ;;
        -e|--exclude)
            return 0
            ;;
        --timeout|--ssh-timeout|-j|--jobs)
            COMPREPLY=( $(compgen -W "$(seq 1 100)" -- "${cur}") )
            return 0
            ;;
        -h|--help)
            return 0
            ;;
    esac

    if [[ "${cur}" == -* ]]; then
        COMPREPLY=( $(compgen -W "-h --help -v --serial --dry-run --show-output --hosts -c --config --all -s --src -f --file -d --dst --rsync --scp -e --exclude --no-default-excludes --timeout --ssh-timeout -j --jobs" -- "${cur}") )
        return 0
    fi

    # complete with hosts
    COMPREPLY=( $(compgen -W "$(_powerbash_ssh_hosts)" -- "${cur}") )
    return 0
}
complete -F _SyncToHosts SyncToHosts
