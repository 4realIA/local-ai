#!/bin/bash
# check-connections.sh — list the open network connections of a local AI app.
#
# Usage:  ./check-connections.sh ["process name pattern"]
# Default pattern: "LM Studio" (matches the app and its helper processes).
# Examples:
#   ./check-connections.sh
#   ./check-connections.sh "mlx_video"
#   ./check-connections.sh "Draw Things"
#
# Run it while the model is answering with no tools in use: the list should
# be empty. macOS only (uses pgrep and lsof, both built in). No sudo needed
# for your own processes.

set -u
pattern="${1:-LM Studio}"

pids=$(pgrep -f "$pattern" | tr '\n' ',' | sed 's/,$//')
if [ -z "$pids" ]; then
  echo "No running process matches \"$pattern\"."
  exit 1
fi

echo "Processes matching \"$pattern\": ${pids//,/ }"
echo

# -a: AND the filters; -i: network files only; -n -P: no DNS or port-name lookups
out=$(lsof -a -nP -i -p "$pids" 2>/dev/null)

if [ -z "$out" ]; then
  echo "No open network connections."
  exit 0
fi

echo "$out" | head -1
echo "$out" | tail -n +2 | sort -u
echo
echo "Notes:"
echo "  - 127.0.0.1 / [::1] / localhost entries are local only (for example the"
echo "    app's own server on port 1234). They don't leave the machine."
echo "  - LISTEN lines are open ports waiting for connections, not outbound traffic."
echo "  - Anything ESTABLISHED to another address is going off the machine:"
echo "    look up who it is before trusting it."
