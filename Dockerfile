FROM ubuntu:rolling
MAINTAINER bitmagier@mailbox.org

ARG USER_NAME
ARG USER_UID
ARG USER_GID
ARG USER_PASSWORD
ARG VNC_PASSWORD
ARG SSH_AUTHORIZED_KEY
ARG X_GEOMETRY
ARG HTTP_PROXY

ENV USER_PASSWORD=$USER_PASSWORD
ENV http_proxy=$HTTP_PROXY
ENV https_proxy=$HTTP_PROXY


RUN if [ -n "$http_proxy" ]; then \
      echo "Acquire::http::Proxy \"$http_proxy\";" >> /etc/apt/apt.conf.d/proxy; \
      echo "Acquire::https::Proxy \"$http_proxy\";" >> /etc/apt/apt.conf.d/proxy; \
      echo "export http_proxy=$http_proxy" >> /etc/environment; \
      echo "export https_proxy=$http_proxy" >> /etc/environment; \
    fi

RUN yes | /usr/local/sbin/unminimize

RUN userdel ubuntu
RUN rm -rf /home/ubuntu

# remomve (if exists) and completely disable snapd
RUN apt purge snapd -y
RUN echo "Package: snapd" >> /etc/apt/preferences.d/nosnap.pref
RUN echo "Pin: release a=*" >> /etc/apt/preferences.d/nosnap.pref
RUN echo "Pin-Priority: -10" >> /etc/apt/preferences.d/nosnap.pref

RUN apt-get install -y openssh-server
RUN echo "PasswordAuthentication no" >> /etc/ssh/sshd_config

RUN apt-get install -y less pwgen git vim
RUN apt install -y tigervnc-standalone-server 
RUN apt-get install -y xfonts-100dpi xfonts-75dpi
RUN apt-get install -y mate-desktop-environment mate-menu mate-tweak

RUN groupadd --gid $USER_GID $USER_NAME || echo "Group with desired ID already exists"
RUN useradd --uid $USER_UID --gid $USER_GID --create-home --shell /bin/bash $USER_NAME
RUN echo "$USER_NAME:$USER_PASSWORD" | chpasswd

RUN apt-get install -y sudo
RUN echo >> /etc/sudoers
RUN echo "$USER_NAME ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

RUN mkdir /user_preparation
COPY vnc_xstartup /user_preparation/
RUN chown -R $USER_NAME /user_preparation

EXPOSE 22/tcp

ENV USER=$USER_NAME
ENV USER_UID=$USER_UID
ENV USER_GID=$USER_GID
ENV SSH_AUTHORIZED_KEY=$SSH_AUTHORIZED_KEY
ENV VNC_PASSWORD=$VNC_PASSWORD
ENV X_GEOMETRY=$X_GEOMETRY

USER $USER_UID

CMD uid_gid=$(stat --printf="%u:%g" /home/$USER); if [ "$uid_gid" != "$USER_UID:$USER_GID" ]; then echo "Invalid UID/GID ($uid_gid) of mounted 'persistent_home' directory - must match UID/GID in .env ($USER_UID:$USER_GID)."; exit 1; fi && \
chmod 755 /home/$USER && \
mkdir -p /home/$USER/.ssh && \
echo "$SSH_AUTHORIZED_KEY" > /home/$USER/.ssh/authorized_keys && \
chmod 700 /home/$USER/.ssh && \
chmod 600 /home/$USER/.ssh/* && \
mkdir -p /home/$USER/.vnc && \
cp /user_preparation/vnc_xstartup /home/$USER/.vnc/xstartup && \
chmod +x /home/$USER/.vnc/xstartup && \
echo "$VNC_PASSWORD" | vncpasswd -f > /home/$USER/.vnc/passwd && \
chmod 700 /home/$USER/.vnc/passwd && \
sudo rm -rf /user_preparation && \
sudo /etc/init.d/ssh start && \
/usr/bin/vncserver -geometry $X_GEOMETRY -depth 24 -rfbauth /home/$USER/.vnc/passwd && \
sleep infinity
