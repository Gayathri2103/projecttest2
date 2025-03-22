# Use Red Hat UBI 8 base image
FROM registry.access.redhat.com/ubi8/ubi

# Switch to root user to install packages
USER root

# Install Apache (httpd)
RUN yum install -y httpd && yum clean all

# Ensure Apache directory exists
RUN mkdir -p /var/www/html

# Set working directory
WORKDIR /var/www/html

# Copy website files from the build context to the Apache directory
COPY . /var/www/html/

# Set correct ownership and permissions
RUN chown -R 1001:0 /var/www/html && chmod -R 755 /var/www/html

# Expose port 80 for web traffic
EXPOSE 80

# Start Apache in the foreground (keep root to avoid permission issues)
CMD ["httpd", "-D", "FOREGROUND"]

