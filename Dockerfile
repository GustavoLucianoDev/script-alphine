FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive
ENV DISPLAY=:1
ENV VNC_PORT=5901
ENV NOVNC_PORT=8080

# Instalar desktop leve + VNC + noVNC
RUN apt update && apt install -y \
    xfce4 xfce4-goodies \
    tightvncserver \
    novnc websockify \
    sudo wget curl \
    && apt clean

# Criar usuário
RUN useradd -m user && echo "user:user" | chpasswd && adduser user sudo

USER user
WORKDIR /home/user

# Configurar VNC
RUN mkdir ~/.vnc && \
    echo "user" | vncpasswd -f > ~/.vnc/passwd && \
    chmod 600 ~/.vnc/passwd

EXPOSE 8080

CMD vncserver :1 && \
    websockify --web=/usr/share/novnc/ 8080 localhost:5901
