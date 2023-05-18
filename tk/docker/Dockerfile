ARG UBUNTU_VERSION=10.04
FROM ubuntu:${UBUNTU_VERSION}

# Install libraries and dependency script
COPY share/dinosaurs/*.sh /opt/dinosaurs/share/dinosaurs/
COPY tk/docker/dependencies.sh /opt/dinosaurs/bin/

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Install the entrypoint and run it
COPY tk/docker/entrypoint.sh /opt/dinosaurs/bin/
ENTRYPOINT ["/opt/dinosaurs/bin/entrypoint.sh"]