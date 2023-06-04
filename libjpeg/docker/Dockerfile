FROM ubuntu:10.04

# Install libraries and dependency script
COPY share/dinosaurs/lib/*.sh /opt/dinosaurs/share/dinosaurs/lib/
COPY libjpeg/docker/dependencies.sh /opt/dinosaurs/bin/

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Install the entrypoint and run it
COPY libjpeg/docker/build.sh /opt/dinosaurs/bin/
ENTRYPOINT ["/opt/dinosaurs/bin/build.sh"]