# vuln-login — an INTENTIONALLY weak SSH login target for the Hydra demo.
# Local lab only. Reachable solely from crackstation over the internal Docker
# network (no published host ports). Do NOT deploy this anywhere reachable.
FROM alpine:3.20

RUN apk add --no-cache openssh \
 && ssh-keygen -A \
 && adduser -D labuser \
 && echo 'labuser:password123' | chpasswd \
 # Weak-on-purpose sshd config: password auth on, root off, generous retries so
 # the in-class demo is fast and reliable.
 && printf '%s\n' \
      'PasswordAuthentication yes' \
      'PermitRootLogin no' \
      'AllowUsers labuser' \
      'MaxAuthTries 30' \
      'MaxStartups 60:30:120' \
      'LoginGraceTime 60' \
      'PrintMotd no' \
      > /etc/ssh/sshd_config.d/lab.conf

EXPOSE 22
# -D foreground, -e log to stderr so `docker logs vuln-login` shows attempts.
CMD ["/usr/sbin/sshd", "-D", "-e"]
