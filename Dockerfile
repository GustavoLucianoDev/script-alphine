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

# Configuração do SSH para permitir login por chave pública
RUN mkdir -p /root/.ssh && chmod 700 /root/.ssh

# Adiciona a chave pública ao authorized_keys
RUN echo "AAAAB3NzaC1yc2EAAAADAQABAAACAQCRK8UKHF3Bmd9/OYjgahmoN7SaopJa83snbwfnOwoXFipvPeDYnEPLloEpc99IFgLGst5mj3rCw7dExPyP9T2YwC1hJtBGUgF696oZF9bdZ20EsZ+fuIgzmB5SYrfwUf8xxVui9SzUgX2HirfR+SIf57aNLJF5wbZ2eMi+RS/tZShNUEut0gvlcY08dC+9gLao8edOhc+GipkuSkvoHZrMBUDcSkm7MrWyIgR/S59Tv3an0aq+PiNlOVgA2JEtTi+asM7V3GFJAnZ0heJv5a0iDiLnggmUJAt49T2OjbcKqKTyZndEv0K7m3dmz8UHxnpK4nNtKUh5vfzx+b4nCkiEwwSLfzxqQOmi1DfmZRI2ftFQyZtMfH9axUcGtdW9eD+nIYCa+B+6kx6hBfqA8ze6I2jYk4a+eT8tZr2Pj61wS4/HR37cgHuHubMjI1GEfTOHBknvihmr24D6goN7Q154XFCrS9H7QulequxAYqkWudg1KVXQq4PvD7BL1eTlihmKBma5KnEIX0MP8Oe90AosQx+IU0NR50QeUlXCub+V49YO0v64cHGmOVcFET270cw4mLfuxN+awyJvHRrhETfNgcC7V1Y5EMZirw7E3qUg/pMr7/n5T0/L/bcv2a5qDHwsZppgqjlUfxLo6GDNhLiPv0lbT0jgHTDp3kRwLkrMQw==" > /root/.ssh/authorized_keys

# Define permissões corretas
RUN chmod 600 /root/.ssh/authorized_keys

# Configuração do SSH para permitir login por chave pública e desativar senha
RUN mkdir -p /var/run/sshd && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin without-password/' /etc/ssh/sshd_config && \
    sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config && \
    echo 'PubkeyAuthentication yes' >> /etc/ssh/sshd_config

# Força a recriação do host key do SSH (caso necessário)
RUN ssh-keygen -A

# Expõe portas necessárias
EXPOSE 4200 22

# Script de inicialização atualizado
CMD ["/bin/bash", "-c", "\
    service ssh start && \
    shellinaboxd -t -s '/:LOGIN' & \
    npx localtunnel --port 22 & \
    tail -f /dev/null"]
