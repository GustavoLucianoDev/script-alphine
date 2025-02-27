# Use uma imagem base que suporte systemd
FROM ubuntu:20.04

# Define o fuso horário automaticamente para evitar interação do tzdata
ENV DEBIAN_FRONTEND=noninteractive
RUN ln -fs /usr/share/zoneinfo/America/Sao_Paulo /etc/localtime && \
    echo "America/Sao_Paulo" > /etc/timezone && \
    apt-get update && \
    apt-get install -y tzdata

# Instala pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox openssh-server curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Instala Node.js mais recente
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - && \
    apt-get install -y nodejs && \
    npm install -g localtunnel

# Configura senha do root
RUN echo 'root:root' | chpasswd

# Configuração do SSH
RUN mkdir /var/run/sshd && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Expõe portas
EXPOSE 4200 22

# Script de inicialização
CMD bash -c "\
    /usr/sbin/sshd && \
    shellinaboxd -t -s '/:LOGIN' & \
    lt --port 22 & \
    wait"
