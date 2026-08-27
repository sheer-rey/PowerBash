# SyncToHosts Tests

Tests for `HOME/.nicetools/bin/SyncToHosts`.

## Test Files

| File | Description |
|------|-------------|
| `test_syntax.sh` | Script syntax validation |
| `test_help.sh` | Help output correctness |
| `test_validation.sh` | Argument validation (missing required args) |
| `test_host_resolution.sh` | Host discovery: IP, user@host, wildcards, mixed |
| `test_config_file.sh` | Config file reading |
| `test_engines.sh` | Sync engine selection (rsync/scp) |
| `test_modes.sh` | Parallel vs serial mode |
| `test_verbose.sh` | Verbosity levels |
| `test_concurrency.sh` | Concurrent job control |

## Running

```bash
# From repo root:
./tests/run_tests.sh sync-to-hosts

# Or directly:
bash tests/sync-to-hosts/test_syntax.sh
```
