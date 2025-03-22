# Use Red Hat UBI 8 base image
FROM registry.access.redhat.com/ubi8/ubi

# Install Apache (httpd)
RUN yum install -y httpd && yum clean all

# Set working directory
WORKDIR /var/www/html

# Copy website files from the build context to the Apache directory
COPY . /var/www/html/

# Expose port 80 for web traffic
EXPOSE 80

# Start Apache in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]

