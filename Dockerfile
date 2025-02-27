# Use uma imagem base que suporte systemd
FROM ubuntu:20.04

# Instala pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox openssh-server curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Configura senha do root
RUN echo 'root:root' | chpasswd

# Configuração do SSH
RUN mkdir /var/run/sshd && echo 'PermitRootLogin yes' >> /etc/ssh/sshd_config

# Instala o LocalTunnel globalmente
RUN curl -fsSL https://github.com/localtunnel/localtunnel/raw/master/bin/lt -o /usr/local/bin/lt && \
    chmod +x /usr/local/bin/lt

# Expõe portas
EXPOSE 4200 22

# Script de inicialização
CMD bash -c "\
    /usr/sbin/sshd && \
    shellinaboxd -t -s '/:LOGIN' & \
    lt --port 22 & \
    wait"
