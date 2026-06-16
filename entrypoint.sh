#!/usr/bin/env sh
set -eu

# O repo é montado em /workspace como somente-leitura, mas o FastContext grava
# a trajetória relativa ao cwd (.fastcontext/...). Para nao quebrar, se o usuario
# nao passar --traj/-t, gravamos no volume gravavel /out.
for arg in "$@"; do
    case "$arg" in
        --traj | -t)
            exec fastcontext "$@"
            ;;
    esac
done

exec fastcontext --traj "/out/trajectory_$(date +%Y-%m-%d-%H%M%S).jsonl" "$@"