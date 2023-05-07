FROM ubuntu:10.04

# Install libraries and scripts
COPY share/dinosaurs/*.sh /usr/local/share/dinosaurs/
COPY tcl/docker/*.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/*.sh

# Install dependencies
RUN /usr/local/bin/dependencies.sh

# Run the entrypoint installed earlier
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]