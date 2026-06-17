#!/usr/bin/env bash
# crackstation entrypoint: stage everything so attendees need ZERO setup.
# Prints a welcome banner, then drops into the shell (or runs the passed command).

# If the repo isn't bind-mounted at /lab (e.g. plain `docker run`), fall back to
# the copy baked into the image so every /lab/... path in the docs still works.
if [ ! -e /lab/sample-hashes ]; then
    ln -sfn /opt/lab /lab 2>/dev/null || true
fi

# Safety net: make sure rockyou is decompressed (the image already does this).
if [ ! -f /usr/share/wordlists/rockyou.txt ] && [ -f /usr/share/wordlists/rockyou.txt.gz ]; then
    gunzip -k /usr/share/wordlists/rockyou.txt.gz 2>/dev/null || true
fi

# Auto-serve the fake "company intranet" so Challenge 5 (CeWL) is a SINGLE command —
# no need to start a web server yourself. It's reachable only inside this container.
#   cewl http://127.0.0.1:8000/intranet.html -m 4 -w /work/custom.txt
if [ -d /lab/web ] && command -v python3 >/dev/null 2>&1; then
    ( cd /lab/web && python3 -m http.server 8000 --bind 127.0.0.1 ) >/dev/null 2>&1 &
fi

# Show the banner only for interactive sessions.
if [ -t 1 ]; then
cat <<BANNER

============================================================
  Cracking the Code  —  crackstation
  LAB ONLY · synthetic data · keep it in the lab
============================================================
  Everything is staged. No setup needed.

    hashes    ->  /lab/sample-hashes/   (c1..c8 + bonus)
    wordlists ->  /lab/wordlists/  and  \$ROCKYOU
                  ($ROCKYOU)
    rules     ->  /lab/rules/class.rule
    C5 intranet-> http://127.0.0.1:8000/intranet.html  (already served — just CeWL it)
    your loot ->  /work   (saved to your PC)

  First crack (Challenge 1):
    john --format=raw-md5 -w \$ROCKYOU /lab/sample-hashes/c1_md5.txt
    john --show --format=raw-md5 /lab/sample-hashes/c1_md5.txt

  Hashcat works on CPU here too, e.g.:
    hashcat -m 0 -a 0 /lab/sample-hashes/c1_md5.txt \$ROCKYOU

  Hydra target is up at:  ssh://vuln-login   (user: labuser)
  Flags look like:        DC256{...}
  Challenges & how-to:    see README.md in this repo
============================================================

BANNER
fi

exec "$@"
