FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=user

# Instalar desktop leve + VNC stack
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    xvfb \
    x11vnc \
    novnc \
    websockify \
    dbus-x11 \
    sudo \
    && apt clean

# Criar usuário
RUN useradd -m -s /bin/bash user && \
    echo "user:user" | chpasswd && \
    adduser user sudo

WORKDIR /home/user

# Script de inicialização
RUN echo '#!/bin/bash\n\
export USER=user\n\
export DISPLAY=:1\n\
\n\
# Iniciar X virtual\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
sleep 2\n\
\n\
# Iniciar XFCE\n\
startxfce4 &\n\
sleep 2\n\
\n\
# Iniciar VNC\n\
x11vnc -display :1 -nopw -forever -shared &\n\
\n\
# Iniciar noVNC (processo principal)\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
