#!/usr/bin/env bash
# Corre cada fixture de tests/fixtures/should-block/* y should-pass/* contra
# el hook pre-commit real, en un repo git temporal aislado, y verifica que
# el resultado (bloqueado / permitido) sea el esperado.
#
# Uso: tests/run-tests.sh
set -u

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOOK="$ROOT/.githooks/pre-commit"
FIXTURES="$ROOT/tests/fixtures"
FAILED=0
TOTAL=0

run_case() {
    local dir="$1" expect_block="$2"
    local name tmp
    name="$(basename "$dir")"
    tmp="$(mktemp -d)"
    TOTAL=$((TOTAL + 1))

    (
        cd "$tmp" || exit 1
        git init -q
        git config user.email "test@example.com"
        git config user.name "Test"
        cp -r "$dir"/. .
        git add -A
    )

    (cd "$tmp" && sh "$HOOK") >/tmp/hook-output.$$ 2>&1
    local exit_code=$?
    rm -f /tmp/hook-output.$$
    rm -rf "$tmp"

    if [ "$expect_block" = "1" ]; then
        if [ "$exit_code" -eq 1 ]; then
            echo "  OK   $name (bloqueado como se esperaba)"
        else
            echo "  FAIL $name (se esperaba que bloqueara, exit=$exit_code)"
            FAILED=$((FAILED + 1))
        fi
    else
        if [ "$exit_code" -eq 0 ]; then
            echo "  OK   $name (permitido como se esperaba)"
        else
            echo "  FAIL $name (se esperaba que pasara limpio, exit=$exit_code)"
            FAILED=$((FAILED + 1))
        fi
    fi
}

echo "=== deberian bloquear el commit ==="
for dir in "$FIXTURES"/should-block/*/; do
    [ -d "$dir" ] || continue
    run_case "${dir%/}" 1
done

echo ""
echo "=== deberian permitir el commit ==="
for dir in "$FIXTURES"/should-pass/*/; do
    [ -d "$dir" ] || continue
    run_case "${dir%/}" 0
done

echo ""
echo "$((TOTAL - FAILED))/$TOTAL casos pasaron"

[ "$FAILED" -eq 0 ]
