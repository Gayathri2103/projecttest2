# Use Red Hat UBI 8 base image
FROM registry.access.redhat.com/ubi8/ubi

# Install Apache (httpd)
RUN yum install -y httpd && yum clean all

# Ensure Apache directory exists
RUN mkdir -p /var/www/html

# Copy website files from the build context to the Apache directory
COPY . /var/www/html/ # Consider specific files or .dockerignore

# Set correct ownership and permissions for the apache user
RUN chown -R apache:apache /var/www/html

# Switch to the apache user
USER apache

# Expose port 80 for web traffic
EXPOSE 80

# Start Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]

HEALTHCHECK --interval=30s --timeout=30s --start-period=5s --retries=3 \
    CMD curl -f http://localhost/ || exit 1

