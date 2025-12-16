#!/usr/bin/env bash
#
# run-quality-gates.sh
#
# Runs quality gates (tests, linters, builds) appropriate for the project type.
# Detects project type and executes the relevant quality checks.
#
# Exit codes:
#   0 - All quality gates passed
#   1 - One or more quality gates failed
#
# Usage:
#   ./run-quality-gates.sh [--skip-tests] [--skip-lint] [--skip-build]
#
# Options:
#   --skip-tests   Skip test execution
#   --skip-lint    Skip linting
#   --skip-build   Skip build step

set -euo pipefail

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SKIP_TESTS=false
SKIP_LINT=false
SKIP_BUILD=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --skip-tests)
            SKIP_TESTS=true
            shift
            ;;
        --skip-lint)
            SKIP_LINT=true
            shift
            ;;
        --skip-build)
            SKIP_BUILD=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--skip-tests] [--skip-lint] [--skip-build]"
            exit 1
            ;;
    esac
done

# Track results
GATES_PASSED=0
GATES_FAILED=0
FAILED_GATES=()

echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Running Quality Gates${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""

# Helper function to run a gate
run_gate() {
    local gate_name=$1
    local gate_command=$2

    echo -e "${BLUE}▶${NC} Running: $gate_name"
    echo "  Command: $gate_command"
    echo ""

    if eval "$gate_command"; then
        echo -e "${GREEN}✓ $gate_name passed${NC}"
        echo ""
        ((GATES_PASSED++))
        return 0
    else
        echo -e "${RED}✗ $gate_name failed${NC}"
        echo ""
        ((GATES_FAILED++))
        FAILED_GATES+=("$gate_name")
        return 1
    fi
}

# Detect project type and run appropriate gates

# Node.js / JavaScript / TypeScript
if [ -f "package.json" ]; then
    echo -e "${YELLOW}Detected: Node.js project${NC}"
    echo ""

    # Determine package manager
    if [ -f "pnpm-lock.yaml" ]; then
        PKG_MANAGER="pnpm"
    elif [ -f "yarn.lock" ]; then
        PKG_MANAGER="yarn"
    else
        PKG_MANAGER="npm"
    fi

    # Tests
    if [ "$SKIP_TESTS" = false ]; then
        # Check if test script exists in package.json
        if grep -q '"test"' package.json; then
            run_gate "Tests" "$PKG_MANAGER test" || true
        else
            echo -e "${YELLOW}⊘ No test script found in package.json${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}⊘ Skipping tests${NC}"
        echo ""
    fi

    # Linting
    if [ "$SKIP_LINT" = false ]; then
        if grep -q '"lint"' package.json; then
            run_gate "Linter" "$PKG_MANAGER run lint" || true
        elif command -v eslint &> /dev/null; then
            run_gate "Linter" "eslint ." || true
        else
            echo -e "${YELLOW}⊘ No lint script or eslint found${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}⊘ Skipping linting${NC}"
        echo ""
    fi

    # Type checking (if TypeScript)
    if [ -f "tsconfig.json" ] && [ "$SKIP_LINT" = false ]; then
        if grep -q '"type-check"' package.json; then
            run_gate "Type Check" "$PKG_MANAGER run type-check" || true
        elif command -v tsc &> /dev/null; then
            run_gate "Type Check" "tsc --noEmit" || true
        fi
    fi

    # Build
    if [ "$SKIP_BUILD" = false ]; then
        if grep -q '"build"' package.json; then
            run_gate "Build" "$PKG_MANAGER run build" || true
        else
            echo -e "${YELLOW}⊘ No build script found in package.json${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}⊘ Skipping build${NC}"
        echo ""
    fi

# Python
elif [ -f "requirements.txt" ] || [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    echo -e "${YELLOW}Detected: Python project${NC}"
    echo ""

    # Tests
    if [ "$SKIP_TESTS" = false ]; then
        if command -v pytest &> /dev/null; then
            run_gate "Tests (pytest)" "pytest" || true
        elif [ -f "manage.py" ]; then
            run_gate "Tests (Django)" "python manage.py test" || true
        else
            echo -e "${YELLOW}⊘ No test framework found (pytest, unittest)${NC}"
            echo ""
        fi
    else
        echo -e "${YELLOW}⊘ Skipping tests${NC}"
        echo ""
    fi

    # Linting
    if [ "$SKIP_LINT" = false ]; then
        if command -v ruff &> /dev/null; then
            run_gate "Linter (ruff)" "ruff check ." || true
        elif command -v flake8 &> /dev/null; then
            run_gate "Linter (flake8)" "flake8 ." || true
        elif command -v pylint &> /dev/null; then
            run_gate "Linter (pylint)" "pylint **/*.py" || true
        else
            echo -e "${YELLOW}⊘ No linter found (ruff, flake8, pylint)${NC}"
            echo ""
        fi

        # Type checking
        if command -v mypy &> /dev/null; then
            run_gate "Type Check (mypy)" "mypy ." || true
        fi
    else
        echo -e "${YELLOW}⊘ Skipping linting${NC}"
        echo ""
    fi

# Go
elif [ -f "go.mod" ]; then
    echo -e "${YELLOW}Detected: Go project${NC}"
    echo ""

    # Tests
    if [ "$SKIP_TESTS" = false ]; then
        run_gate "Tests" "go test ./..." || true
    else
        echo -e "${YELLOW}⊘ Skipping tests${NC}"
        echo ""
    fi

    # Linting
    if [ "$SKIP_LINT" = false ]; then
        if command -v golangci-lint &> /dev/null; then
            run_gate "Linter (golangci-lint)" "golangci-lint run ./..." || true
        elif command -v staticcheck &> /dev/null; then
            run_gate "Linter (staticcheck)" "staticcheck ./..." || true
        else
            run_gate "Vet" "go vet ./..." || true
        fi

        run_gate "Format Check" "test -z \$(gofmt -l .)" || true
    else
        echo -e "${YELLOW}⊘ Skipping linting${NC}"
        echo ""
    fi

    # Build
    if [ "$SKIP_BUILD" = false ]; then
        run_gate "Build" "go build ./..." || true
    else
        echo -e "${YELLOW}⊘ Skipping build${NC}"
        echo ""
    fi

# Rust
elif [ -f "Cargo.toml" ]; then
    echo -e "${YELLOW}Detected: Rust project${NC}"
    echo ""

    # Tests
    if [ "$SKIP_TESTS" = false ]; then
        run_gate "Tests" "cargo test" || true
    else
        echo -e "${YELLOW}⊘ Skipping tests${NC}"
        echo ""
    fi

    # Linting
    if [ "$SKIP_LINT" = false ]; then
        run_gate "Linter (clippy)" "cargo clippy -- -D warnings" || true
        run_gate "Format Check" "cargo fmt -- --check" || true
    else
        echo -e "${YELLOW}⊘ Skipping linting${NC}"
        echo ""
    fi

    # Build
    if [ "$SKIP_BUILD" = false ]; then
        run_gate "Build" "cargo build" || true
    else
        echo -e "${YELLOW}⊘ Skipping build${NC}"
        echo ""
    fi

# Makefile-based projects
elif [ -f "Makefile" ]; then
    echo -e "${YELLOW}Detected: Makefile project${NC}"
    echo ""

    if [ "$SKIP_TESTS" = false ] && grep -q "^test:" Makefile; then
        run_gate "Tests" "make test" || true
    fi

    if [ "$SKIP_LINT" = false ] && grep -q "^lint:" Makefile; then
        run_gate "Linter" "make lint" || true
    fi

    if [ "$SKIP_BUILD" = false ] && grep -q "^build:" Makefile; then
        run_gate "Build" "make build" || true
    fi

else
    echo -e "${RED}✗ Could not detect project type${NC}"
    echo ""
    echo "No recognized project files found (package.json, requirements.txt, go.mod, Cargo.toml, Makefile)"
    echo "Please run quality gates manually or customize this script for your project."
    echo ""
    exit 1
fi

# Summary
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo -e "${BLUE}Quality Gates Summary${NC}"
echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${NC}"
echo ""
echo "Gates passed: ${GREEN}$GATES_PASSED${NC}"
echo "Gates failed: ${RED}$GATES_FAILED${NC}"
echo ""

if [ $GATES_FAILED -eq 0 ]; then
    echo -e "${GREEN}✓ All quality gates passed!${NC}"
    echo ""
    exit 0
else
    echo -e "${RED}✗ Quality gates failed${NC}"
    echo ""
    echo "Failed gates:"
    for gate in "${FAILED_GATES[@]}"; do
        echo "  • $gate"
    done
    echo ""
    echo "Please fix the failures above or file P0 issues if fixes will take time."
    echo ""
    exit 1
fi
