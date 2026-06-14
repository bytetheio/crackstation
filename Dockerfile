# crackstation — the toolbox attendees work in.
# Kali rolling packages John, Hashcat, Hydra, CeWL, crunch, hashid, seclists, rockyou.
FROM kalilinux/kali-rolling

ENV DEBIAN_FRONTEND=noninteractive
# Give Hashcat a CPU OpenCL backend inside Docker: Mesa's rusticl exposes an
# llvmpipe (software/CPU) device. RUSTICL_ENABLE makes Hashcat find it automatically.
ENV RUSTICL_ENABLE=llvmpipe
RUN apt-get update && apt-get install -y --no-install-recommends \
        john \
        hashcat \
        mesa-opencl-icd \
        ocl-icd-libopencl1 \
        clinfo \
        hydra \
        hashid \
        cewl \
        crunch \
        wordlists \
        seclists \
        python3 \
        python3-pip \
        python3-bcrypt \
        openssh-client \
        ncat \
        curl ca-certificates dos2unix less vim-tiny iproute2 \
    && rm -rf /var/lib/apt/lists/*

# name-that-hash (nicer hash identifier). Tolerate offline builds.
RUN pip3 install --no-cache-dir --break-system-packages name-that-hash || true

# Pre-decompress rockyou so it's ready to go, and expose a handy $ROCKYOU var.
RUN if [ -f /usr/share/wordlists/rockyou.txt.gz ]; then \
        gunzip -k /usr/share/wordlists/rockyou.txt.gz || true ; fi
ENV ROCKYOU=/usr/share/wordlists/rockyou.txt

WORKDIR /work
# Bake the lab content into the image so it's staged out-of-the-box. The
# docker-compose bind mount of the repo at /lab takes precedence when present;
# this baked copy (and the entrypoint symlink) is the fallback for plain `docker run`.
COPY sample-hashes/  /opt/lab/sample-hashes/
COPY wordlists/      /opt/lab/wordlists/
COPY rules/          /opt/lab/rules/
COPY web/            /opt/lab/web/
COPY entrypoint.sh   /opt/lab/entrypoint.sh
RUN chmod +x /opt/lab/entrypoint.sh 2>/dev/null || true

# The entrypoint stages /lab, ensures rockyou, prints a welcome banner, then runs CMD.
ENTRYPOINT ["/opt/lab/entrypoint.sh"]
CMD ["/bin/bash"]
