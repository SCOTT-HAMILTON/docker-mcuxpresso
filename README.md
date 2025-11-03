# docker-mcuexpresso
Run mcuexpresso in a docker container with X11 forwarding

# Building
- Download the mcuxpressoide debian bin from NXP
- Set the IDE_VERSION variable in the docker-compose.yml file to match the bin
- Set the UID and the GID to the *currently logged in user*
- sudo UID=1001 GID=100 WAYLAND_DISPLAY=wayland-0 docker-compose build

# Run
- sudo UID=1001 GID=100 WAYLAND_DISPLAY=wayland-0 docker compose up

mcuxpresso should start automatically.
