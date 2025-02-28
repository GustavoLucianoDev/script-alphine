# Use a base image
FROM ubuntu:20.04

# Install necessary packages
RUN apt-get update && \
    apt-get install -y shellinabox systemd curl openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Install Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Set root password
RUN echo 'root:root' | chpasswd

# Enable SSH
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Expose ports
EXPOSE 4200 22

# Start services
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    echo 'Iniciando túnel para SSH...' && \
    cloudflared tunnel --no-autoupdate run --token eyJhIjoiYTNmMjI3MzkxMTIwZGE5MzcyOTc5NTdmNmM1MDJhYWIiLCJ0IjoiZDM3NzYzZGMtMDk1ZC00NjNjLTlkMzgtOWFjNTk0Nzg0MmZjIiwicyI6Ik9UVmtOakZoTmpFdE5ETXlZeTAwTVdFekxUZ3pOMk10TkRGbE1tUXdOR1k1TlRBeiJ9 > /tmp/cloudflare_ssh.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_ssh.log && \
    echo 'Iniciando túnel para WebShell...' && \
    cloudflared tunnel --no-autoupdate --url http://localhost:4200 > /tmp/cloudflare_web.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_web.log && \
    tail -f /tmp/cloudflare_ssh.log /tmp/cloudflare_web.log"]
