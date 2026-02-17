FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV USER=user

# Instalar Openbox + VNC stack leve
RUN apt update && apt install -y \
    openbox \
    x11vnc \
    xvfb \
    novnc \
    websockify \
    dbus-x11 \
    sudo \
    wget curl \
    netcat \
    && apt clean

# Criar usuário
RUN useradd -m -s /bin/bash user && \
    echo "user:user" | chpasswd && \
    adduser user sudo

WORKDIR /home/user

# Script de inicialização leve
RUN echo '#!/bin/bash\n\
export USER=user\n\
export DISPLAY=:1\n\
\n\
# Limitar memória por processo (~500MB)\n\
ulimit -v 500000\n\
\n\
# Iniciar X virtual\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
XVFB_PID=$!\n\
echo "Xvfb iniciado PID $XVFB_PID"\n\
\n\
# Iniciar Openbox leve\n\
openbox &\n\
OPENBOX_PID=$!\n\
echo "Openbox iniciado PID $OPENBOX_PID"\n\
\n\
# Espera até o display estar pronto\n\
sleep 2\n\
\n\
# Iniciar x11vnc no background\n\
x11vnc -display :1 -nopw -forever -shared &\n\
X11VNC_PID=$!\n\
echo "x11vnc iniciado PID $X11VNC_PID"\n\
\n\
# Esperar até a porta 5900 estar aberta\n\
while ! nc -z localhost 5900; do sleep 1; done\n\
echo "x11vnc pronto em localhost:5900"\n\
\n\
# Iniciar noVNC (foreground)\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900\n\
' > /start.sh && chmod +x /start.sh

EXPOSE 8080

CMD ["/start.sh"]
