# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário automaticamente
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone

# Atualiza pacotes e instala dependências
RUN apt-get update && \
    apt-get install -y curl gnupg shellinabox openssh-server autossh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

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
    autossh -M 0 -o 'StrictHostKeyChecking=no' -o 'ServerAliveInterval=60' -o 'ServerAliveCountMax=3' -R 2222:localhost:22 serveo.net & \
    tail -f /dev/null"]
