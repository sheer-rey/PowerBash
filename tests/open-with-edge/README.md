# OpenWithEdge Tests

Tests for `HOME/.nicetools/bin/OpenWithEdge`.

## Test Files

| File | Description |
|------|-------------|
| `test_open_with_edge.sh` | WSL gate behavior and target resolution via `--dry-run` |

## What is tested

- **WSL environment probe:** Inside WSL the gate passes and `--help` is
  reachable; outside WSL the tool must exit with an error before doing
  anything else. The suite is environment-aware, so the assertions follow
  the machine it runs on.
- **Target resolution (`--dry-run`):** WSL-only, requires `msedge.exe`.
  Verifies absolute/relative WSL paths become `file://` URIs, Windows paths
  are normalized, `http(s)://` URLs pass through, multiple targets are all
  converted, and nonexistent paths fail with an error. No Edge window opens.

## Running

```bash
# From repo root:
./tests/run_tests.sh open-with-edge

# Or directly:
bash tests/open-with-edge/test_open_with_edge.sh
```

To verify the non-WSL rejection path, run the suite on a plain Linux host,
e.g. sync the needed files and execute the component tests there:

```bash
rsync -aR tests/test_runner.sh tests/open-with-edge/ \
    HOME/.nicetools/bin/OpenWithEdge HOME/.nicetools/predefined \
    Plain-Linux-Host:/tmp/owetest/
ssh Plain-Linux-Host 'cd /tmp/owetest && ROOT_DIR=$PWD bash -c \
    "source tests/test_runner.sh; source tests/open-with-edge/test_open_with_edge.sh; run_tests"'
```
