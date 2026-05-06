#!/bin/bash
# When Diamond launches QuestaSim from its Tools menu, vsim inherits
# Diamond's stdin. If Diamond was started from a `.desktop` entry the
# inherited stdin is /dev/null and there's no controlling terminal, so
# vsim drops into batch mode, processes the empty input, and exits 0
# silently — no GUI ever appears. Force `-gui` when there's no tty.
#
# Diamond also passes an empty argv[1] which vsim treats as a filename
# to open; drop empty args before forwarding.
args=()
for a in "$@"; do
	[ -n "$a" ] && args+=("$a")
done
if [ ! -t 0 ]; then
	args=(-gui "${args[@]}")
fi
exec -a "$0" /opt/diamond/questasim/linux_x86_64/vsim.real "${args[@]}"
