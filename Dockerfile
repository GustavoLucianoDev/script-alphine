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

# Instala LocalTunnel
RUN npm install -g localtunnel

# Cria diretório .ssh e adiciona chave pública
RUN mkdir -p /root/.ssh && \
    echo "AAAAB3NzaC1yc2EAAAADAQABAAACAQCRK8UKHF3Bmd9/OYjgahmoN7SaopJa83sn
    bwfnOwoXFipvPeDYnEPLloEpc99IFgLGst5mj3rCw7dExPyP9T2YwC1hJtBGUgF6
    96oZF9bdZ20EsZ+fuIgzmB5SYrfwUf8xxVui9SzUgX2HirfR+SIf57aNLJF5wbZ2
    eMi+RS/tZShNUEut0gvlcY08dC+9gLao8edOhc+GipkuSkvoHZrMBUDcSkm7MrWy
    IgR/S59Tv3an0aq+PiNlOVgA2JEtTi+asM7V3GFJAnZ0heJv5a0iDiLnggmUJAt4
    9T2OjbcKqKTyZndEv0K7m3dmz8UHxnpK4nNtKUh5vfzx+b4nCkiEwwSLfzxqQOmi
    1DfmZRI2ftFQyZtMfH9axUcGtdW9eD+nIYCa+B+6kx6hBfqA8ze6I2jYk4a+eT8t
    Zr2Pj61wS4/HR37cgHuHubMjI1GEfTOHBknvihmr24D6goN7Q154XFCrS9H7Qule
    quxAYqkWudg1KVXQq4PvD7BL1eTlihmKBma5KnEIX0MP8Oe90AosQx+IU0NR50Qe
    UlXCub+V49YO0v64cHGmOVcFET270cw4mLfuxN+awyJvHRrhETfNgcC7V1Y5EMZi
    rw7E3qUg/pMr7/n5T0/L/bcv2a5qDHwsZppgqjlUfxLo6GDNhLiPv0lbT0jgHTDp
    3kRwLkrMQw==" > /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# Configuração do SSH para apenas permitir login com chave
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo 'AuthorizedKeysFile .ssh/authorized_keys' >> /etc/ssh/sshd_config

# Força a recriação do host key do SSH
RUN ssh-keygen -A

# Expõe portas necessárias
EXPOSE 4200 22

# Script de inicialização atualizado
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    npx localtunnel --port 22 --subdomain meu-tunnel & \
    tail -f /dev/null"]
