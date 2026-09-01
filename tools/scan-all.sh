#!/bin/sh
# Auditoria "en frio" de varios repos locales de una sola pasada: implante
# "A8-3424-1 / EtherHiding" + identidad de committer conocida del mecanismo
# de injerto (yugin0120).
#
# A diferencia de post-merge/post-checkout (que solo revisan lo que acaba de
# llegar con un pull/checkout puntual), este script revisa en cada repo:
#   - el arbol completo de HEAD (no solo lo staged ni lo recien traido)
#   - TODO el historial alcanzable (git log --all), no solo un rango reciente
# Pensado para correr manualmente de vez en cuando sobre varios repos a la
# vez, no como hook.
#
# Uso:
#   ./tools/scan-all.sh /ruta/repo1 /ruta/repo2 ...
#   ./tools/scan-all.sh --root /ruta/con/varios/repos   (autodetecta cada .git)
#
# Codigo de salida: 0 si todos limpios, 1 si algun repo tuvo hallazgos.

RED='\033[0;31m'
GRN='\033[0;32m'
NC='\033[0m'

LITERAL_PATTERN="global.i[ 	]*=[ 	]*['\"]A8-|global\['!'\]=|global\['e'\]='app-[a-z]+-eval'|_\\\$_1e42|windowsHide.{0,80}detached|detached.{0,80}windowsHide|ETH_RPC_URL|eth\.blockscout\.com|ethereum-rpc\.publicnode\.com|eth\.drpc\.org|1rpc\.io/eth|blastapi\.io|SvcHostUpdate|97icr5|main\.inz\.cjs|q4FZkxX"
RISKY_CONFIG_RE='(^|/)(vite\.config\.(js|ts|mjs|cjs)|webpack\.(config|mix)\.js|postcss\.config\.(js|cjs|mjs)|tailwind\.config\.(js|cjs|mjs)|babel\.config\.(js|cjs)|\.babelrc.*|next\.config\.(js|mjs)|rollup\.config\.js|jest\.config\.(js|cjs))$'
MAXLEN=400
BAD_COMMITTER="yugin0120"

EXIT_CODE=0

scan_one() {
    repo="$1"
    name=$(basename "$repo")

    if [ ! -d "$repo/.git" ]; then
        printf "%-25s NO ES UN REPO GIT (sin .git)\n" "$name"
        return
    fi

    FOUND=0
    DETAILS=""

    FILES=$(git -C "$repo" ls-files 2>/dev/null)
    for f in $FILES; do
        case "$f" in
            .githooks/*|.github/workflows/security-*.yml|*.QUARANTINED|tests/fixtures/*) continue ;;
        esac
        [ -f "$repo/$f" ] || continue
        if grep -qEa "$LITERAL_PATTERN" "$repo/$f" 2>/dev/null; then
            DETAILS="$DETAILS
  - firma conocida del implante en: $f"
            FOUND=1
            continue
        fi
        if printf '%s' "$f" | grep -qE "$RISKY_CONFIG_RE"; then
            longest=$(awk '{ print length }' "$repo/$f" 2>/dev/null | sort -rn | head -1)
            if [ -n "$longest" ] && [ "$longest" -gt "$MAXLEN" ]; then
                DETAILS="$DETAILS
  - $f: linea de $longest bytes (limite $MAXLEN)"
                FOUND=1
            fi
        fi
    done

    if [ -f "$repo/.vscode/tasks.json" ] && grep -q "folderOpen" "$repo/.vscode/tasks.json" 2>/dev/null; then
        DETAILS="$DETAILS
  - .vscode/tasks.json: tarea con runOn:folderOpen"
        FOUND=1
    fi

    if git -C "$repo" log --all --format='%cn' 2>/dev/null | grep -qx "$BAD_COMMITTER"; then
        bad_commits=$(git -C "$repo" log --all --format='%h %cn' 2>/dev/null | grep " $BAD_COMMITTER\$" | awk '{print $1}' | tr '\n' ' ')
        DETAILS="$DETAILS
  - historial contiene commit(s) con committer '$BAD_COMMITTER': $bad_commits"
        FOUND=1
    fi

    if [ "$FOUND" -eq 1 ]; then
        printf "${RED}%-25s HALLAZGOS${NC}\n" "$name"
        printf '%s\n' "$DETAILS"
        EXIT_CODE=1
    else
        printf "${GRN}%-25s limpio${NC}\n" "$name"
    fi
}

if [ "$1" = "--root" ]; then
    root="$2"
    [ -z "$root" ] && { echo "uso: $0 --root <directorio>"; exit 2; }
    gitdirs=$(find "$root" -maxdepth 6 -type d -name ".git" 2>/dev/null)
    oldIFS="$IFS"
    IFS='
'
    for gitdir in $gitdirs; do
        scan_one "$(dirname "$gitdir")"
    done
    IFS="$oldIFS"
else
    [ "$#" -eq 0 ] && { echo "uso: $0 <repo1> [repo2] ... | --root <directorio>"; exit 2; }
    for repo in "$@"; do
        scan_one "$repo"
    done
fi

exit $EXIT_CODE
