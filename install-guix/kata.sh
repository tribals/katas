#!/bin/sh

set -x

set -o errexit
set -o nounset

readonly _system=aarch64

# shellcheck disable=SC2016
exec guix shell \
  --system="${_system}"-linux \
  file \
  -- \
  sh -c 'qemu-'"${_system}"' $(which file) $(which file)'
