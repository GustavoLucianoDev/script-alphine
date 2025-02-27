# Use uma imagem base que suporte systemd
FROM ubuntu:20.04

# Instala pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox openssh-server wget unzip && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configura senha do root
RUN echo 'root:root' | chpasswd

# Configuração do SSH
RUN mkdir /var/run/sshd && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Baixa e instala o ngrok
RUN wget -O /tmp/ngrok.zip https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-stable-linux-amd64.zip && \
    unzip /tmp/ngrok.zip -d /usr/local/bin/ && \
    rm /tmp/ngrok.zip

# Define a variável de ambiente para a chave de autenticação do ngrok (substitua pelo seu token)
ENV NGROK_AUTH_TOKEN="2tdswqKoBI3H5G5LSPoZX3kBhJ2_33iB5k5q6a9Do9GoaumfK"

# Expõe portas
EXPOSE 4200 22

# Script de inicialização
CMD bash -c "\
    /usr/sbin/sshd && \
    shellinaboxd -t -s '/:LOGIN' & \
    ngrok authtoken $NGROK_AUTH_TOKEN && \
    ngrok tcp 22 & \
    wait"
