# crackstation — Cracking the Code lab

A safe, **local-only, offline** password-cracking lab for the *Cracking the Code: Passwords, Hashes,
and the Tools that Break Them* class (DC256 × NAC-ISSA). One Docker image gives everyone the same
toolbox — John the Ripper, Hashcat (CPU-ready), Hydra, CeWL, crunch, hashid/name-that-hash, SecLists,
and `rockyou.txt` — plus an intentionally weak local login target for the online-guessing exercise.

> ⚖️ **Lab only.** Everything here runs against **synthetic data we generate ourselves** — toy
> hashes, fake users, deliberately weak passwords. There are **no internet targets**. Cracking
> credentials you don't own or aren't authorized to test is illegal (e.g. the U.S. Computer Fraud and
> Abuse Act). Keep these techniques inside this lab or systems you own / are authorized to test.

---

## Quick start

You need **Docker** (Docker Desktop on Windows/macOS, Docker Engine on Linux). That's the only hard
dependency.

### Fastest — pull the prebuilt image (no build)
```bash
git clone https://github.com/bytetheio/crackstation
cd crackstation
docker compose pull               # pulls the prebuilt images from GHCR
docker compose run --rm crackstation
```

### Or build it yourself (first build ~15–25 min, needs internet)
```bash
git clone https://github.com/bytetheio/crackstation
cd crackstation
docker compose build
docker compose run --rm crackstation
```

Either way you land in a ready-to-go shell. **Everything is pre-staged** — a welcome banner shows you
where the hashes, wordlists, rules, and `$ROCKYOU` live, and the Hydra target starts automatically.

Teardown:
```bash
docker compose down -v
```

## What's inside

```
Dockerfile            # the crackstation toolbox image (Kali + tools + rockyou + CPU OpenCL)
docker-compose.yml    # crackstation + the weak-login Hydra target (internal network, no host ports)
entrypoint.sh         # stages the lab and prints the welcome banner
hydra-target/         # intentionally weak SSH login target (LAB ONLY)
sample-hashes/        # the challenge hashes (c1..c8) — hashes only
wordlists/            # a tiny offline starter list + a small list for the Hydra demo
rules/class.rule      # a small, readable Hashcat/John rule set
web/intranet.html     # a fake local page for the CeWL custom-wordlist exercise
.github/workflows/    # builds & publishes the images to GHCR automatically
```

## The challenge ladder

Crack a hash → recover the password → that's your flag, formatted `DC256{...}`. Difficulty climbs
from warm-up to bonus. (Answer keys are kept out of this repo on purpose.)

| # | Hash / target | Skill it teaches |
|---|---------------|------------------|
| C1 | `sample-hashes/c1_md5.txt` | Identify a hash, then a dictionary attack |
| C1B | `sample-hashes/b1_base64.txt` | **Encoding ≠ hashing** — Base64 is reversible; just `base64 -d` it |
| C2 | `sample-hashes/c2_sha1.txt` | Pick the right algorithm/mode (not everything is MD5) |
| C3 | `sample-hashes/c3_md5.txt` | Rule-based attack (`-r rules/class.rule`) |
| C4 | `sample-hashes/c4_md5.txt` | Mask / smart brute force (`-a 3`) |
| C5 | `sample-hashes/c5_md5.txt` | Custom wordlist with CeWL + hybrid (`-a 6`) |
| C6 | `ssh://vuln-login` | Online guessing with Hydra (local target only) |
| C7 | `sample-hashes/c7_bcrypt.txt` | A slow hash — why key stretching matters |
| C8 | `sample-hashes/c8_ntlm.txt` | NTLM (unsalted) and why it matters in Windows/AD |

Starter commands (run inside the container):
```bash
# identify, then crack C1 with a wordlist
nth -t "$(cat /lab/sample-hashes/c1_md5.txt)"
john --format=raw-md5 -w $ROCKYOU /lab/sample-hashes/c1_md5.txt && john --show /lab/sample-hashes/c1_md5.txt

# Hashcat works on CPU here too
hashcat -m 0 -a 0 /lab/sample-hashes/c1_md5.txt $ROCKYOU

# online guessing against the local toy target
hydra -l labuser -P /lab/wordlists/hydra-small.txt ssh://vuln-login
```

## Notes

- **CPU only by default** — challenges are tuned to finish on CPU in seconds to a couple minutes.
  Hashcat uses a Mesa `rusticl`/`llvmpipe` CPU backend baked into the image; John needs no OpenCL at
  all. For real GPU speed, run Hashcat natively on your host against these same files.
- **Prebuilding & distributing** the ~4.8 GB image for a class: see [PREBUILD.md](PREBUILD.md).
- The challenge hashes in `sample-hashes/` are synthetic and self-contained; the answer key and the
  hash generator are kept with the private instructor materials, not in this public repo.

## License

Lab code & scripts: MIT (see [LICENSE](LICENSE)). Third-party tools (John, Hashcat, Hydra, SecLists,
CeWL, crunch, etc.) retain their own licenses. `rockyou.txt`/SecLists are installed from their public
sources at build time, not redistributed here.
