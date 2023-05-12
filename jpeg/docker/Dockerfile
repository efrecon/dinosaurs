FROM ubuntu:10.04

# Install libraries and scripts
COPY share/dinosaurs/*.sh /opt/dinosaurs/share/dinosaurs/
COPY jpeg/docker/*.sh /opt/dinosaurs/bin/
RUN chmod +x /opt/dinosaurs/bin/*.sh

# Install dependencies
RUN /opt/dinosaurs/bin/dependencies.sh

# Run the entrypoint installed earlier
ENTRYPOINT ["/opt/dinosaurs/bin/entrypoint.sh"]