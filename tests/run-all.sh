#!/usr/bin/env bash
# Runs every browser test; each prints "errors: []" when the page threw no JavaScript errors.
set -u; cd "$(dirname "$0")"; mkdir -p out; fail=0
for f in *.test.js; do r=$(node "$f" 2>&1 | grep -E 'errors:|Error' | head -1); echo "$f: $r"; [[ "$r" == "errors: []" ]] || fail=1; done
exit $fail
