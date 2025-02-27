FROM ubuntu:latest

# Atualizar pacotes e instalar OpenSSH Server e Shellinabox
RUN apt-get update && apt-get install -y openssh-server shellinabox

# Criar diretório necessário para o SSH
RUN mkdir /var/run/sshd

# Criar um usuário para SSH
RUN useradd -m -s /bin/bash usuario && echo "usuario:senha123" | chpasswd

# Habilitar login de root via SSH (opcional e não recomendado para produção)
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config

# Habilitar Shellinabox para rodar na porta 4200
RUN echo "SHELLINABOX_ARGS=\"--no-beep -s /:LOGIN --disable-ssl\"" > /etc/default/shellinabox

# Expor portas do SSH e Shellinabox
EXPOSE 22 4200

# Iniciar o SSH e Shellinabox quando o contêiner for executado
CMD service ssh start && service shellinabox start && tail -f /dev/null
