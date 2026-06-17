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

## Before you start — what to install on your host

**The only things you install on your own machine are Docker and Git.** Every security tool —
John the Ripper, Hashcat, Hydra, CeWL, crunch, hashid/name-that-hash, SecLists, `rockyou.txt` — lives
**inside the container**. You do **not** install any of those on your host.

| Your OS | Install on the host | Notes |
|---------|---------------------|-------|
| **Windows 10/11** | [Docker Desktop](https://docs.docker.com/desktop/install/windows-install/) (use the **WSL 2** backend) + [Git for Windows](https://git-scm.com/download/win) | Enable CPU **virtualization** in BIOS/UEFI (Intel **VT-x** / AMD **SVM-Mode**) and the Windows **"Virtual Machine Platform"** + **WSL2** features — otherwise Docker Desktop won't start. |
| **macOS — Intel** | [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/) + Git (`xcode-select --install`) | Works out of the box. |
| **macOS — Apple Silicon (M1–M4, arm64)** | [Docker Desktop for Mac](https://docs.docker.com/desktop/install/mac-install/) + Git | **Works — runs via emulation.** See the Apple Silicon note below. |
| **Linux** | [Docker Engine + Compose plugin](https://docs.docker.com/engine/install/) + `git` | Add yourself to the `docker` group: `sudo usermod -aG docker $USER` then log out/in, so you don't need `sudo`. |

**Hardware:** ~**5 GB** free disk for the image, **4 GB+ RAM** (Docker Desktop defaults are fine).
Confirm Docker is ready with **`docker info`** — you want a "Server:" section and no connection error.

> 🍎 **Apple Silicon (arm64) note — yes, it works.** This image is built for **linux/amd64**. On an
> M-series Mac, Docker Desktop runs it through **Rosetta / QEMU emulation**, so you'll see a one-line
> warning like *"The requested image's platform (linux/amd64) does not match the detected host
> platform (linux/arm64/v8)."* **That warning is expected and harmless — the container runs fine**
> (just slightly slower than native; the challenges are tuned so you won't notice). `docker-compose.yml`
> already pins `platform: linux/amd64`, which is why everything just works.

---

## Quick start

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
sample-hashes/        # the challenge targets (c1..c8 hashes + one base64 puzzle)
wordlists/            # a tiny offline starter list + a small list for the Hydra demo
rules/class.rule      # a small, readable Hashcat/John rule set
web/intranet.html     # a fake local page for the CeWL custom-wordlist exercise
.github/workflows/    # builds & publishes the images to GHCR automatically
```

## The challenge ladder

Recover the secret behind each target → that's your flag, formatted `DC256{...}`, which you submit to
the class leaderboard. Difficulty climbs from warm-up to hard. **Figuring out the right approach is
the challenge** — so the targets are listed below, but *how* to beat each one is left to you.

> 🚩 This is a **CTF**. Hints, the answer key, walkthroughs, and the slides are **deliberately not in
> this repo** — your instructor has them. No spoilers here.

| # | Target | Difficulty |
|---|--------|:----------:|
| C1 | `sample-hashes/c1_md5.txt` | ⭐ warm-up |
| C1B | `sample-hashes/b1_base64.txt` | ⭐ warm-up — *wait… is this even a hash?* |
| C2 | `sample-hashes/c2_sha1.txt` | ⭐ warm-up |
| C2B | `sample-hashes/c2b_md5.txt` *(read `c2b_README.txt`)* | ⭐⭐ easy |
| C3 | `sample-hashes/c3_md5.txt` | ⭐⭐ easy |
| C4 | `sample-hashes/c4_md5.txt` | ⭐⭐⭐ medium |
| C5 | `sample-hashes/c5_md5.txt` | ⭐⭐⭐ medium |
| C6 | `ssh://vuln-login` | ⭐⭐⭐ medium · live login |
| C7 | `sample-hashes/c7_bcrypt.txt` | ⭐⭐⭐⭐ hard |
| C8 | `sample-hashes/c8_ntlm.txt` | ⭐⭐⭐⭐ hard |

### Your toolbox
Everything is pre-staged at `/lab/` (targets in `/lab/sample-hashes`, `/lab/wordlists`, `$ROCKYOU`,
`/lab/rules`, the CeWL page in `/lab/web`); your output goes in `/work`. The container ships:
`john`, `hashcat` (CPU-ready), `hydra`, `cewl`, `crunch`, `hashid`, `nth` (name-that-hash), plus
`rockyou` and SecLists. Picking the right tool and mode for each target is the whole game.

A reasonable first move on any unknown value is simply to **identify** it before you attack:
```bash
hashid <file>            # or:  nth -t "$(cat <file>)"
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
