#!/usr/bin/env bash
# --
# Copyright (C) 2012 Znuny GmbH, https://znuny.com/
# --
# This software comes with ABSOLUTELY NO WARRANTY. For details, see
# the enclosed file COPYING for license information (AGPL). If you
# did not receive this file, see http://www.gnu.org/licenses/agpl.txt.
# --

set -euo pipefail

Usage() {
    cat <<'EOF'
Usage: bin/znuny.CodePolicy.Docker.sh [options] [target-dir] [codepolicy-options]

    Build (if needed) and run Znuny CodePolicy in a Docker container against a
    target repository. The target directory is mounted at /workspace.
    By default CodePolicy processes all changed files (staged and unstaged)
    that are already known to Git.

Docker options:
    -h, --help                 Show this usage message
        --rebuild              Force rebuild of the Docker image

CodePolicy options (passed through to bin/znuny.CodePolicy.pl):
    -v, --verbose              Activate diagnostics (shows loaded extensions config files)
    -i, --install-eslint       Install ESLint via npm
    -m, --mode                 Use custom Code::TidyAll mode (default: cli)
    -p, --process-limit        Max. number of processes to use (default: environment
                               variable ZNUNY_CODE_POLICY_PROCESS_LIMIT if set, otherwise 6)
    -a, --all-files            Checks all files in all subdirectories recursively
    -s, --staged-files         Checks only files staged for a Git commit
    -f, --file-path            Checks only given file
    -d, --directory            Checks only given directory

Environment:
    ZNUNY_CODEPOLICY_DOCKER_IMAGE   Image name (default: znuny-codepolicy:local)
    ZNUNY_CODEPOLICY_FORCE_BUILD    Set to 1 to force rebuild (same as --rebuild)

Examples:
    bin/znuny.CodePolicy.Docker.sh
    bin/znuny.CodePolicy.Docker.sh --rebuild
    bin/znuny.CodePolicy.Docker.sh --all-files
    bin/znuny.CodePolicy.Docker.sh /path/to/repo --all-files
    bin/znuny.CodePolicy.Docker.sh --rebuild /path/to/repo --file-path Kernel/System/Main.pm
    bin/znuny.CodePolicy.Docker.sh --mode ci --staged-files
EOF
    exit 0
}

CODEPOLICY_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
IMAGE_NAME="${ZNUNY_CODEPOLICY_DOCKER_IMAGE:-znuny-codepolicy:local}"
FORCE_BUILD="${ZNUNY_CODEPOLICY_FORCE_BUILD:-0}"

FILTERED_ARGS=()
for Arg in "$@"; do
    case "${Arg}" in
        -h|--help)
            Usage
            ;;
        --rebuild)
            FORCE_BUILD=1
            ;;
        *)
            FILTERED_ARGS+=("${Arg}")
            ;;
    esac
done
set -- "${FILTERED_ARGS[@]}"

TARGET_DIR="${PWD}"
if [[ $# -gt 0 && "${1}" != "-"* && -d "${1}" ]]; then
    TARGET_DIR="$(cd "${1}" && pwd)"
    shift
fi

if [[ "${FORCE_BUILD}" == "1" ]] \
    || ! docker image inspect "${IMAGE_NAME}" >/dev/null 2>&1; then
    docker build \
        --tag "${IMAGE_NAME}" \
        --file "${CODEPOLICY_DIR}/docker/Dockerfile" \
        "${CODEPOLICY_DIR}"
fi

docker run --rm \
    -u "$(id -u):$(id -g)" \
    -v "${TARGET_DIR}:/workspace" \
    -w /workspace \
    "${IMAGE_NAME}" "$@"
