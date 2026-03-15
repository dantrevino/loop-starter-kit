#!/bin/bash
# Validation script for loop-starter-kit
# Run this after setup to verify all components are in place

set -e

echo "=== Loop Starter Kit Validation ==="
echo ""

PASS=0
FAIL=0

check_file() {
    if [ -f "$1" ]; then
        echo "[PASS] $1 exists"
        ((PASS++))
    else
        echo "[FAIL] $1 missing"
        ((FAIL++))
    fi
}

check_dir() {
    if [ -d "$1" ]; then
        echo "[PASS] $1/ directory exists"
        ((PASS++))
    else
        echo "[FAIL] $1/ directory missing"
        ((FAIL++))
    fi
}

check_json() {
    if command -v python3 &>/dev/null; then
        if python3 -c "import json; json.load(open('$1'))" 2>/dev/null; then
            echo "[PASS] $1 is valid JSON"
            ((PASS++))
        else
            echo "[FAIL] $1 has invalid JSON"
            ((FAIL++))
        fi
    elif command -v jq &>/dev/null; then
        if jq '.' "$1" >/dev/null 2>&1; then
            echo "[PASS] $1 is valid JSON"
            ((PASS++))
        else
            echo "[FAIL] $1 has invalid JSON"
            ((FAIL++))
        fi
    else
        echo "[SKIP] $1 JSON validation (no python3 or jq)"
    fi
}

# Check required files
echo "--- Checking required files ---"
check_file "CLAUDE.md"
check_file "SOUL.md"
check_file "SKILL.md"
check_file "daemon/loop.md"
check_file "daemon/STATE.md"

# Check required directories
echo ""
echo "--- Checking required directories ---"
check_dir "daemon"
check_dir "memory"

# Check JSON files (health.json should exist after first run)
echo ""
echo "--- Checking JSON files ---"
if [ -f "daemon/health.json" ]; then
    check_json "daemon/health.json"
else
    echo "[SKIP] daemon/health.json (created on first run)"
fi

if [ -f "daemon/queue.json" ]; then
    check_json "daemon/queue.json"
else
    echo "[SKIP] daemon/queue.json (created on first run)"
fi

# Verify CLAUDE.md has required sections
echo ""
echo "--- Checking CLAUDE.md structure ---"
if grep -q "## Trusted Senders" CLAUDE.md; then
    echo "[PASS] Trusted Senders section found"
    ((PASS++))
else
    echo "[FAIL] Trusted Senders section missing"
    ((FAIL++))
fi

if grep -q "## Default Wallet" CLAUDE.md; then
    echo "[PASS] Default Wallet section found"
    ((PASS++))
else
    echo "[FAIL] Default Wallet section missing"
    ((FAIL++))
fi

# Verify loop.md has security sections
echo ""
echo "--- Checking loop.md security ---"
if grep -q "Trusted sender check" daemon/loop.md; then
    echo "[PASS] Trusted sender gate implemented"
    ((PASS++))
else
    echo "[FAIL] Trusted sender gate missing"
    ((FAIL++))
fi

if grep -q "Self-Modification Guardrails" daemon/loop.md; then
    echo "[PASS] Self-modification guardrails section found"
    ((PASS++))
else
    echo "[FAIL] Self-modification guardrails missing"
    ((FAIL++))
fi

if grep -q "loop.md.bak" daemon/loop.md; then
    echo "[PASS] Backup mechanism documented"
    ((PASS++))
else
    echo "[FAIL] Backup mechanism not documented"
    ((FAIL++))
fi

# Summary
echo ""
echo "=== Summary ==="
echo "Passed: $PASS"
echo "Failed: $FAIL"

if [ $FAIL -eq 0 ]; then
    echo "[SUCCESS] All validations passed!"
    exit 0
else
    echo "[ERROR] Some validations failed. Check setup."
    exit 1
fi