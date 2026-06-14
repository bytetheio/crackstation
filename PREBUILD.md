# 🏗️ Prebuilding & distributing the image

The `crackstation` image is ~4.8 GB. Don't make 30 attendees each build it on venue Wi-Fi. Prebuild
once; have them **pull** (or **load**) it.

Image names (set in `docker-compose.yml`):
`ghcr.io/bytetheio/crackstation:latest` and `ghcr.io/bytetheio/vuln-login:latest`.

## Option A — GitHub Actions → GHCR (recommended, hands-off)

The workflow in [`.github/workflows/build-image.yml`](.github/workflows/build-image.yml) builds both
images in the cloud and publishes them to GHCR using the built-in `GITHUB_TOKEN` (no PAT needed).

1. Push this repo to `bytetheio/crackstation` (commands below).
2. Repo → **Actions** tab → enable workflows if prompted. The build runs on every push to `main`, or
   trigger it manually with **Run workflow**. The crackstation build takes ~15–25 min.
3. When it's done: your GitHub profile → **Packages** → `crackstation` → **Package settings** →
   **Change visibility → Public** (repeat for `vuln-login`). Now anyone can pull without logging in.

**Attendees then run:**
```bash
git clone https://github.com/bytetheio/crackstation
cd crackstation
docker compose pull
docker compose run --rm crackstation
```

## Option B — push your already-built local image to GHCR

If you built it locally already:
```bash
# PAT (classic) with the write:packages scope, then:
docker login ghcr.io -u bytetheio
docker tag <local-image> ghcr.io/bytetheio/crackstation:latest   # if not already tagged
docker push ghcr.io/bytetheio/crackstation:latest
docker push ghcr.io/bytetheio/vuln-login:latest
```
Then make the packages Public (Option A, step 3).

## Option C — offline tarball (USB / no internet)

```bash
docker save ghcr.io/bytetheio/crackstation:latest ghcr.io/bytetheio/vuln-login:latest \
  | gzip > crackstation-images.tar.gz          # ~1.2 GB
```
Attendees: `docker load -i crackstation-images.tar.gz` then `docker compose run --rm crackstation`.

## Pushing this repo

```bash
cd crackstation
git init
git add .
git commit -m "crackstation lab + GHCR build workflow"
git branch -M main
git remote add origin https://github.com/bytetheio/crackstation.git
git push -u origin main
```

## Shrinking the image (optional)

Most of the size is the `seclists` package. No graded challenge needs it (we use `rockyou` + the
small bundled lists). Remove `seclists` from the [`Dockerfile`](Dockerfile) to roughly halve the
image for faster pulls.

## Multi-arch note

The workflow builds **amd64**. Apple Silicon Macs run it under emulation automatically (slower but
works). For native arm64, add `platforms: linux/amd64,linux/arm64` to the build step plus
`docker/setup-qemu-action` (doubles build time).
