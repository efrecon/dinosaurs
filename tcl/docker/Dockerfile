FROM ubuntu:10.04

# Install libraries and dependency script
COPY share/dinosaurs/*.sh /opt/dinosaurs/share/dinosaurs/
COPY tcl/docker/dependencies.sh /opt/dinosaurs/bin/

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Install the entrypoint and run it
COPY tcl/docker/entrypoint.sh /opt/dinosaurs/bin/
ENTRYPOINT ["/opt/dinosaurs/bin/entrypoint.sh"]