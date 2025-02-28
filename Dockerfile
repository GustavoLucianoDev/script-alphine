# Use uma imagem base do Ubuntu
FROM ubuntu:20.04

# Definir variáveis para evitar prompts interativos
ENV DEBIAN_FRONTEND=noninteractive

# Instalar pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox curl openssh-server net-tools && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instalar o Cloudflare Tunnel
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Definir senha para o usuário root
RUN echo 'root:root' | chpasswd

# Configurar SSH
RUN mkdir -p /var/run/sshd && \
    echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config

# Expor portas necessárias
EXPOSE 4200 22

# Script de inicialização
CMD ["/bin/bash", "-c", "\
    echo 'Iniciando SSH...' && service ssh start && \
    echo 'Iniciando ShellInABox...' && shellinaboxd -t -s '/:LOGIN' & \
    echo 'Iniciando túnel SSH...' && cloudflared tunnel --no-autoupdate --url ssh://localhost:22 > /tmp/cloudflare_ssh.log 2>&1 & \
    echo 'Iniciando túnel WebShell...' && cloudflared tunnel --no-autoupdate --url http://localhost:4200 > /tmp/cloudflare_web.log 2>&1 & \
    tail -f /tmp/cloudflare_ssh.log /tmp/cloudflare_web.log"]
