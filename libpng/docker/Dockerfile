ARG UBUNTU_VERSION=10.04
FROM ubuntu:${UBUNTU_VERSION}

# Install libraries and dependency script
COPY share/dinosaurs/lib/*.sh /opt/dinosaurs/share/dinosaurs/lib/
COPY libpng/docker/dependencies.sh /opt/dinosaurs/bin/

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Install the entrypoint and run it
COPY libpng/docker/entrypoint.sh /opt/dinosaurs/bin/
ENTRYPOINT ["/opt/dinosaurs/bin/entrypoint.sh"]