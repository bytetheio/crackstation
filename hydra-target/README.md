# vuln-login — intentionally weak SSH target (LAB ONLY)

A minimal Alpine + OpenSSH container with a single account (`labuser`) set to a
**deliberately weak password** — one that appears in the bundled demo wordlist, so Hydra
finds it in seconds. (Discovering it is Challenge **C6**.)

It exists to demonstrate **online password guessing** with Hydra against a service you
own and control. Safety properties:

- **No published host ports** (`docker-compose.yml` has no `ports:` for this service).
- Lives on the **`internal: true`** `cracklab` network — no internet/LAN reachability at runtime.
- Reachable **only** from the `crackstation` container, as the hostname `vuln-login`.

## Demo (run from inside crackstation)

```bash
# tiny wordlist so the demo finishes in seconds
hydra -l labuser -P /lab/wordlists/hydra-small.txt ssh://vuln-login
```

Expected: Hydra recovers `labuser`'s password and prints it. That's Challenge **C6**.

## Watch the attack land (instructor, separate terminal)

```bash
docker logs -f vuln-login      # see the failed/accepted auth attempts stream by
```

> ⚠️ Never expose this container to a real network. It is weak by design. `docker compose down -v`
> removes it completely.
