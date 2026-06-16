# vuln-login — intentionally weak SSH target (LAB ONLY)

A minimal Alpine + OpenSSH container with a single account (`labuser`) set to a
**deliberately weak password**. It's the target for the **C6** online-guessing challenge.

It exists to demonstrate **online password guessing** against a service you own and
control. Safety properties:

- **No published host ports** (`docker-compose.yml` has no `ports:` for this service).
- Lives on the **`internal: true`** `cracklab` network — no internet/LAN reachability at runtime.
- Reachable **only** from the `crackstation` container, as the hostname `vuln-login`.

## How it's used

From the `crackstation` container, point an online login brute-forcer at `ssh://vuln-login`
(username `labuser`). Working out the password is the challenge — no spoilers here; your
instructor has the answer key.

## Watch the attack land (instructor, separate terminal)

```bash
docker logs -f vuln-login      # see the failed/accepted auth attempts stream by
```

> ⚠️ Never expose this container to a real network. It is weak by design. `docker compose down -v`
> removes it completely.
