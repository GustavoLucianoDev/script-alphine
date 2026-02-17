FROM ubuntu:22.04

# Variáveis de ambiente
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
    wget curl \
    && apt clean

# Criar usuário
RUN useradd -m -s /bin/bash user && \
    echo "user:user" | chpasswd && \
    adduser user sudo

WORKDIR /home/user

# Copiar e criar script de inicialização
RUN echo '#!/bin/bash\n\
export USER=user\n\
export DISPLAY=:1\n\
\n\
# Iniciar X virtual\n\
Xvfb :1 -screen 0 1024x768x16 &\n\
XVFB_PID=$!\n\
echo "Xvfb iniciado PID $XVFB_PID"\n\
\n\
# Iniciar XFCE\n\
startxfce4 &\n\
XFCE_PID=$!\n\
echo "XFCE iniciado PID $XFCE_PID"\n\
\n\
# Espera até o display estar pronto\n\
sleep 5\n\
\n\
# Iniciar x11vnc no background\n\
x11vnc -display :1 -nopw -forever -shared -bg\n\
echo "x11vnc iniciado"\n\
\n\
# Iniciar noVNC (processo principal, foreground)\n\
websockify --web=/usr/share/novnc/ 8080 localhost:5900\n\
' > /start.sh && chmod +x /start.sh

# Expor porta para Render
EXPOSE 8080

# CMD principal
CMD ["/start.sh"]
