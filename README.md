# Linux desktop in a docker container

It is a fresh VM of Ubuntu with the Mate desktop - accessible via SSH/VNC.

The primary use case is a virtualized development environment.
The user's home directory is persistently kept in the host file system under `persistent_home`.
Other changed files inside the VM may be made persistent via `docker commit` later or by an extension to the `Dockerfile` script.

## Requirements

- docker
- docker compose

## Configuration

One must adopt the values in `.env` to his own needs.
Especially __USER_NAME__, __USER_UID__,  __USER_GID__ and __SSH_AUTHORIZED_KEY__ must be changed in order access the VM later and have convenient host filesystem access.

Also the user and group IDs must match the ones of the directory `persistent_home`, so when it's mounted later, sshd lets us in.

The VNC password & the user's password inside the VM is not security relevant, because the only way to access the machine over the network is SSH with public/private key
authentication. The default password for VNC and for the user inside the VM is: 'x'.


## Build the VM once

`docker compose build` 

## Start the VM

`docker compose up`

## Access over the network:

You may install tigervnc-viewer or any other VNC viewer to access the VM.
`sudo apt install tigervnc-viewer`

The VM is designed to be accessed exclusively via a secure SSH tunnel.

A last hint before using it: You may find the F8 key helpful to access tiger-vncviewer's menu (e.g. for a disconnect)

### Way 1: using a separate ssh tunnel

shell #1: `ssh -p 23 -N -L 5901:localhost:5901 [DEV_USER]@[HOST]`  
shell #2: `vncviewer localhost::5901`

### Way 2: use tightvnc built-in tunnel gateway (in linux version)

```
export VNC_VIA_CMD='/usr/bin/ssh -f -N -L "$L":"$H":"$R" "$G" "-p 23" sleep 20'  # necessary because we use a custom ssh port
vncviewer -FullScreen -FullscreenSystemKeys -via [DEV_USER]@[HOST] localhost::5901
``` 

Enjoy!
