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

# Configura o SSH para permitir login com senha e rodar na porta 2222
RUN mkdir -p /var/run/sshd && \
    echo "root:root" | chpasswd && \  # Define a senha do usuário root como "root"
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#Port 22/Port 2222/' /etc/ssh/sshd_config && \  # Altera a porta do SSH para 2222
    echo 'AllowTcpForwarding yes' >> /etc/ssh/sshd_config && \
    echo 'GatewayPorts yes' >> /etc/ssh/sshd_config

# Expõe a porta 2222
EXPOSE 2222

# Inicia o SSH na porta correta e o Cloudflare Tunnel
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    cloudflared tunnel --url ssh://localhost:2222 --no-autoupdate"]
