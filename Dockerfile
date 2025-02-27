# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário automaticamente
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Atualiza pacotes e instala dependências
RUN apt-get update && \
    apt-get install -y curl gnupg shellinabox openssh-server && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala o Cloudflare Tunnel (cloudflared)
RUN curl -fsSL https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 -o /usr/local/bin/cloudflared && \
    chmod +x /usr/local/bin/cloudflared

# Configuração do SSH para aceitar chaves públicas
RUN mkdir -p /root/.ssh && \
    curl -fsSL https://raw.githubusercontent.com/GustavoLucianoDev/chavepub/refs/heads/main/id_rsa.pub -o /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# Força a recriação do host key do SSH
RUN ssh-keygen -A

# Expõe portas necessárias
EXPOSE 22 4200

# Define a variável de ambiente para o Token do Cloudflare Tunnel
ENV CLOUDFLARED_TOKEN="eyJhIjoiYTNmMjI3MzkxMTIwZGE5MzcyOTc5NTdmNmM1MDJhYWIiLCJ0IjoiZDM3NzYzZGMtMDk1ZC00NjNjLTlkMzgtOWFjNTk0Nzg0MmZjIiwicyI6Ik9UVmtOakZoTmpFdE5ETXlZeTAwTVdFekxUZ3pOMk10TkRGbE1tUXdOR1k1TlRBeiJ9"

# Comando de inicialização
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    cloudflared tunnel --no-autoupdate run --token $CLOUDFLARED_TOKEN & \
    tail -f /dev/null"]
