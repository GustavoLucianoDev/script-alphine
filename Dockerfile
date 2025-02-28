# Use uma imagem base do Ubuntu
FROM ubuntu:20.04

# Definir porta SSH
ARG SSH_PORT=2222

# Instalar pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox systemd curl openssh-server net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalar o Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Definir senha para o usuário root
RUN echo 'root:root' | chpasswd

# Configurar SSH (usando porta configurável)
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    sed -i "s/#Port 22/Port ${SSH_PORT}/" /etc/ssh/sshd_config && \
    systemctl enable ssh

# Expor portas necessárias
EXPOSE 4200 ${SSH_PORT}

# Comando de inicialização
CMD ["/bin/bash", "-c", "\
    echo 'Iniciando SSH na porta ${SSH_PORT}...' && \
    service ssh start && \
    netstat -tlnp | grep :${SSH_PORT} && \
    shellinaboxd -t -s '/:LOGIN' & \
    echo 'Iniciando túnel SSH...' && \
    cloudflared tunnel --no-autoupdate --token eyJhIjoiYTNmMjI3MzkxMTIwZGE5MzcyOTc5NTdmNmM1MDJhYWIiLCJ0IjoiZDM3NzYzZGMtMDk1ZC00NjNjLTlkMzgtOWFjNTk0Nzg0MmZjIiwicyI6Ik9UVmtOakZoTmpFdE5ETXlZeTAwTVdFekxUZ3pOMk10TkRGbE1tUXdOR1k1TlRBeiJ9 > /tmp/cloudflare_ssh.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_ssh.log && \
    echo 'Iniciando túnel WebShell...' && \
    cloudflared tunnel --no-autoupdate --url http://localhost:4200 > /tmp/cloudflare_web.log 2>&1 & \
    sleep 5 && \
    cat /tmp/cloudflare_web.log && \
    tail -f /tmp/cloudflare_ssh.log /tmp/cloudflare_web.log"]
