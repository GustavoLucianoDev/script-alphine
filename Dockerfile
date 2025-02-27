# Usa a imagem mais recente do Ubuntu
FROM ubuntu:latest

# Define o fuso horário automaticamente para evitar interação manual
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

# Configura senha do root como 1234
RUN echo 'root:1234' | chpasswd

# Configuração do SSH para permitir login com senha
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication no/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    echo 'PermitEmptyPasswords no' >> /etc/ssh/sshd_config

# Garante que o SSH inicie corretamente no contêiner
RUN service ssh restart

# Instala o LocalTunnel globalmente via npm
RUN npm install -g localtunnel

# Expõe portas necessárias
EXPOSE 4200 22

# Comando de inicialização do contêiner
CMD bash -c "\
    /usr/sbin/sshd -D & \
    shellinaboxd -t -s '/:LOGIN' & \
    lt --port 22 & \
    tail -f /dev/null"
