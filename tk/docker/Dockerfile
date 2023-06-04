ARG UBUNTU_VERSION=12.04
FROM ubuntu:${UBUNTU_VERSION}

# Install libraries and dependency script
COPY share/dinosaurs/lib/*.sh /opt/dinosaurs/share/dinosaurs/lib/
COPY tk/docker/dependencies.sh /opt/dinosaurs/bin/

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Install the entrypoint and run it
COPY tk/docker/build.sh /opt/dinosaurs/bin/
ENTRYPOINT ["/opt/dinosaurs/bin/build.sh"]