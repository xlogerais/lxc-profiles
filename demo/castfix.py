"""Post-process an autocast recording (asciicast v2), in place.

- Scenarios with an empty autocast prompt rely on the shell's own prompt (PS1):
  autocast drops the very first one and the one a !Clear erases, so they are
  put back (at the start, and after each screen clear).
- Progress dots (cloud-init status --wait prints one per second) are squeezed,
  so that a long wait does not take a minute of the animation.
"""

import json
import re
import sys

DOT_GAP = 0.05

path = sys.argv[1]
with open(path, encoding="utf-8") as f:
    header, *events = (json.loads(line) for line in f if line.strip())

ps1 = header.get("env", {}).get("PS1", "")
prompt = ps1.replace("AUTOCAST_PROMPT", "").replace("\\[", "").replace("\\]", "").replace("\\e", "\x1b")
first = next((e for e in events if e[1] == "o"), None)
if prompt and first and not first[2].startswith(prompt):
    events.insert(0, [0.0, "o", prompt])
if prompt:
    for event in events:
        if event[1] == "o" and event[2].endswith("\x1b[2J\x1b[3J"):
            event[2] += prompt

shift, previous = 0.0, 0.0
for event in events:
    time = event[0]
    gap = time - previous
    previous = time
    if event[1] == "o" and re.fullmatch(r"\.+", event[2]) and gap > DOT_GAP:
        shift += gap - DOT_GAP
    event[0] = round(time - shift, 6)
if events:
    header["duration"] = events[-1][0]

with open(path, "w", encoding="utf-8") as f:
    for record in (header, *events):
        f.write(json.dumps(record, ensure_ascii=False) + "\n")
