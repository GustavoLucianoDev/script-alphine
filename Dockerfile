# Usa a base Ubuntu 20.04
FROM ubuntu:20.04

# Instala pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox systemd curl openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Define a senha do root
RUN echo 'root:root' | chpasswd

# Configura o SSH
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Expõe as portas necessárias
EXPOSE 4200 22

# Inicia os serviços
CMD ["/bin/bash", "-c", "\
    echo 'Iniciando SSH...' && \
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    echo 'Iniciando túnel para SSH...' && \
    cloudflared tunnel --no-autoupdate --url ssh://localhost:22 > /tmp/cloudflare_ssh.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_ssh.log && \
    echo 'Iniciando túnel para WebShell...' && \
    cloudflared tunnel --no-autoupdate --url http://localhost:4200 > /tmp/cloudflare_web.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_web.log && \
    tail -f /tmp/cloudflare_ssh.log /tmp/cloudflare_web.log"]
