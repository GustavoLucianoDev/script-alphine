# Usar a imagem base do Ubuntu
FROM ubuntu:20.04

# Definir modo não interativo para evitar prompts durante a instalação
ENV DEBIAN_FRONTEND=noninteractive

# Instalar pacotes necessários: Nginx, Shellinabox (terminal web), Systemd, e outras dependências
RUN apt-get update && \
    apt-get install -y nginx shellinabox systemd curl iputils-ping && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Criar o arquivo de configuração nginx.conf dentro do container
RUN echo 'events {} \
http { \
    server { \
        listen 80; \
        location / { \
            proxy_pass http://localhost; \
            proxy_set_header Host $host; \
            proxy_set_header X-Real-IP $remote_addr; \
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for; \
            proxy_set_header X-Forwarded-Proto $scheme; \
        } \
    } \
}' > /etc/nginx/nginx.conf

# Definir senha para o root
RUN echo 'root:root' | chpasswd

# Expor as portas necessárias: 80 (Nginx) e 4200 (Shellinabox)
EXPOSE 80 4200

# Iniciar o Nginx e o Shellinabox
CMD ["/bin/bash", "-c", "service nginx start && /usr/bin/shellinaboxd -t -s /:LOGIN"]
