# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário automaticamente
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Atualiza pacotes e instala dependências
RUN apt-get update && \
    apt-get install -y curl gnupg shellinabox openssh-server npm && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala a versão mais recente do Node.js
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs

# Reinstala LocalTunnel corretamente
RUN npm install -g localtunnel

# Configuração do SSH para permitir login com chave pública
RUN mkdir -p /root/.ssh && \
    curl -fsSL https://raw.githubusercontent.com/GustavoLucianoDev/chavepub/refs/heads/main/id_rsa.pub -o /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# Força a recriação do host key do SSH
RUN ssh-keygen -A

# Expõe portas necessárias
EXPOSE 4200 22

# Script de inicialização atualizado
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    npx localtunnel --port 22 & \
    tail -f /dev/null"]
