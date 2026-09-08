# Tests

Bash test suite for nicetools scripts.

## Structure

```
tests/
├── README.md               # This file
├── test_runner.sh          # Common test infrastructure
└── <component>/            # Tests for each component
    ├── README.md           # Component-specific documentation
    └── test_*.sh           # Individual test files
```

## How to run all tests

```bash
# Run all tests
./tests/run_tests.sh

# Run a specific component
./tests/run_tests.sh sync-to-hosts
./tests/run_tests.sh completions
```

## How to add new tests

1. Create a directory under `tests/` for the new component
2. Write `test_*.sh` files that call the component with various inputs
3. Each test should:
   - Print `Test: <description>` before running
   - Print `Result: <expected>` before checking output
   - Print `PASS` or `FAIL` after verification
4. Add the component to the `COMPONENTS` list in `run_tests.sh`
