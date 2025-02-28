# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Atualiza pacotes e instala dependências
RUN apt-get update && \
    apt-get install -y curl gnupg openssh-server npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala Cloudflare Tunnel
RUN npm install -g cloudflared

# Configura o SSH
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin without-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config && \
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config

# Baixa sua chave pública do GitHub e configura o SSH
RUN mkdir -p /root/.ssh && \
    curl -fsSL https://raw.githubusercontent.com/GustavoLucianoDev/chavepub/refs/heads/main/id_rsa.pub -o /root/.ssh/authorized_keys && \
    chmod 600 /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh

# Expõe portas necessárias (Render não permite acesso direto a portas)
EXPOSE 22

# Inicia o SSH e o Cloudflare Tunnel
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    cloudflared tunnel --url ssh://localhost:22 --no-autoupdate"]
