# Usa a imagem base do Ubuntu
FROM ubuntu:latest

# Atualiza os pacotes e instala o OpenSSH Server
RUN apt-get update && apt-get install -y openssh-server && rm -rf /var/lib/apt/lists/*

# Cria o diretório necessário para o SSH
RUN mkdir /var/run/sshd

# Define uma senha para o usuário root (altere conforme necessário)
RUN echo 'root:rootpassword' | chpasswd

# Permite login do root via SSH (não recomendado para produção)
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config

# Evita que a sessão seja encerrada ao iniciar o container
RUN echo "export VISIBLE=now" >> /etc/profile

# Expõe a porta SSH
EXPOSE 22

# Inicia o serviço SSH
CMD ["/usr/sbin/sshd", "-D"]
