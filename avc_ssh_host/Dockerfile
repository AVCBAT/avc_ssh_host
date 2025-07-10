FROM ubuntu:22.04

# Actualizamos e instalamos lo esencial
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openssh-server sudo bash build-essential curl git \
    locales libx11-6 libxkbfile1 libsecret-1-0 && \
    rm -rf /var/lib/apt/lists/*

# Configuramos locales (en_US.UTF-8)
RUN locale-gen en_US.UTF-8
ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

# Creamos usuario avctrust con sudo sin contraseña
RUN useradd -m -u 1000 -s /bin/bash avctrust && \
    echo "avctrust ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers && \
    echo 'avctrust:avcpass' | chpasswd

# Preparamos SSH
RUN mkdir /var/run/sshd

# Habilitamos PasswordAuthentication (útil para pruebas; para producción mejor solo keys)
RUN sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config && \
    sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin no/' /etc/ssh/sshd_config

# Exponemos puerto SSH interno
EXPOSE 22

# Comando de arranque
CMD ["/usr/sbin/sshd", "-D"]
