# Use Alpine como base
FROM alpine:latest

# Instalar os pacotes necessários
RUN apk add --no-cache shellinabox shadow

# Definir senha para root
RUN echo "root:root" | chpasswd

# Expor a porta do terminal web
EXPOSE 4200

# Iniciar o Shellinabox
CMD ["shellinaboxd", "-t", "-s", "/:LOGIN"]
