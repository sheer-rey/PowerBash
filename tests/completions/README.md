# Completions Tests

Tests for `HOME/.nicetools/completions/powerbash-completions.bash`.

## Test Files

| File | Description |
|------|-------------|
| `test_completions.sh` | Completion bindings and option completion for all commands |

## What is tested

- **Bindings:** Each command (`osc_yank`, `fix_owner`, `ArchivetoRDN`, `CreateSSHTunnel`, `SyncToHosts`) is bound to its completion function via `complete -F`.
- **Option completion:** Verifies that typing `--` or `-` produces the correct set of long/short options.
- **Prefix filtering:** Verifies that `compgen` filters candidates by the current prefix (e.g. `--no` → `--no-dereference`).

## Running

```bash
# From repo root:
./tests/run_tests.sh completions

# Or directly:
bash tests/completions/test_completions.sh
```
