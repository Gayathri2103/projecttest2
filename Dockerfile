# Use Red Hat UBI 8 base image
FROM registry.access.redhat.com/ubi8/ubi

# Switch to root user to install packages
USER root

# Install Apache (httpd)
RUN yum install -y httpd && yum clean all

# Set working directory
WORKDIR /var/www/html

# Copy website files from the build context to the Apache directory
COPY . /var/www/html/

# Set correct ownership and permissions
RUN chown -R 1001:0 /var/www/html && chmod -R 755 /var/www/html

# Expose port 80 for web traffic
EXPOSE 80

# Switch to Apache’s default non-root user for security
USER 1001

# Start Apache in the foreground
CMD ["httpd", "-D", "FOREGROUND"]

