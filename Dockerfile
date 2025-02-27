FROM alpine:latest

# Instalar dependências e Shellinabox
RUN apk add --no-cache shellinabox shadow && \
    echo 'root:root' | chpasswd

# Expor a porta do Shellinabox
EXPOSE 4200

# Iniciar Shellinabox
CMD ["/usr/bin/shellinaboxd", "-t", "-s", "/:LOGIN"]
