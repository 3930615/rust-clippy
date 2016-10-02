#!/usr/bin/bash

# This run `kcov` on Clippy. The coverage report will be at
# `./target/cov/index.html`.
# `compile-test` is special. `kcov` does not work directly on it so these files
# are compiled manually.

tests=(
    camel_case
    cc_seme
    consts
    dogfood
    issue_825
    matches
    trim_multiline
    used_underscore_binding_macro
    versioncheck
)
tmpdir=$(mktemp -d)

cargo test --no-run --verbose

for t in "${tests[@]}"; do
  kcov \
    --verify \
    --include-path="$(pwd)/src","$(pwd)/clippy_lints/src" \
    "$tmpdir/$t" \
    cargo test --test "$t"
done

for t in ./tests/compile-fail/*.rs; do
  kcov \
    --verify \
    --include-path="$(pwd)/src","$(pwd)/clippy_lints/src" \
    "$tmpdir/compile-fail-$(basename $t)" \
    cargo run -- -L target/debug -L target/debug/deps -Z no-trans "$t"
done

for t in ./tests/run-pass/*.rs; do
  kcov \
    --verify \
    --include-path="$(pwd)/src","$(pwd)/clippy_lints/src" \
    "$tmpdir/run-pass-$(basename $t)" \
    cargo run -- -L target/debug -L target/debug/deps -Z no-trans "$t"
done

kcov --verify --merge target/cov "$tmpdir"/*
