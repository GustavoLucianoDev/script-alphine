FROM ubuntu:minimal

# Instalar pacotes necessários
RUN apt-get update && \
    apt-get install -y shellinabox && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# Definir senha do root
RUN echo 'root:root' | chpasswd

# Expor a porta do Shellinabox
EXPOSE 4200

# Iniciar Shellinabox
CMD ["/usr/bin/shellinaboxd", "-t", "-s", "/:LOGIN"]
