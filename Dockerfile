# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário automaticamente
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Atualiza pacotes e instala dependências
RUN apt-get update && \
    apt-get install -y curl gnupg shellinabox openssh-server wget && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala Cloudflared para túnel temporário
RUN wget -O /usr/local/bin/cloudflared https://github.com/cloudflare/cloudflared/releases/latest/download/cloudflared-linux-amd64 && \
    chmod +x /usr/local/bin/cloudflared

# Baixa a chave pública SSH do repositório
RUN mkdir -p /root/.ssh && \
    wget -O /root/.ssh/authorized_keys https://raw.githubusercontent.com/GustavoLucianoDev/chavepub/refs/heads/main/id_rsa.pub && \
    chmod 600 /root/.ssh/authorized_keys

# Configuração do SSH para permitir login apenas com chave pública
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin without-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config

# Força a recriação do host key do SSH
RUN ssh-keygen -A

# Expõe as portas necessárias
EXPOSE 22

# Script de inicialização
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    cloudflared tunnel --url ssh://localhost:22 & \
    tail -f /dev/null"]
