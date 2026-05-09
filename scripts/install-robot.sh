#!/usr/bin/env bash
# install-robot.sh — fetch a pinned ROBOT release into ~/.cache/robot/
# Usage: bash scripts/install-robot.sh
# Exports nothing; sets up $HOME/.cache/robot/robot.jar and prints the path.
set -euo pipefail

ROBOT_VERSION="${ROBOT_VERSION:-1.9.5}"
CACHE_DIR="${HOME}/.cache/robot"
JAR_PATH="${CACHE_DIR}/robot-${ROBOT_VERSION}.jar"
SYMLINK="${CACHE_DIR}/robot.jar"
URL="https://github.com/ontodev/robot/releases/download/v${ROBOT_VERSION}/robot.jar"

mkdir -p "${CACHE_DIR}"

if [[ ! -f "${JAR_PATH}" ]]; then
  echo "Downloading ROBOT v${ROBOT_VERSION} from ${URL}"
  curl -fsSL "${URL}" -o "${JAR_PATH}"
fi

# Atomic-ish update of the unversioned symlink.
ln -sf "robot-${ROBOT_VERSION}.jar" "${SYMLINK}"

echo "${SYMLINK}"
