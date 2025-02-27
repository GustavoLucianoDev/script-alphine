# Use a base image que suporta systemd
FROM ubuntu:20.04

# Instalar pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox openssh-server systemd && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Criar e definir senha do root
RUN echo 'root:root' | chpasswd

# Permitir login via SSH para o root
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config

# Criar diretório para o SSH
RUN mkdir -p /run/sshd

# Expor portas
EXPOSE 4200 22

# Iniciar serviços
CMD ["/bin/bash", "-c", "service ssh start && /usr/bin/shellinaboxd -t -s /:LOGIN"]
