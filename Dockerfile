FROM alpine:latest

# Install required packages
RUN apk add --no-cache \
    nginx \
    cgit \
    git \
    git-daemon \
    fcgiwrap \
    spawn-fcgi \
    supervisor

# Create git user and setup directories
RUN adduser -D -h /home/gituser gituser && \
    mkdir -p /srv/git \
    /var/run/fcgiwrap \
    /etc/supervisor/conf.d \
    /tmp/nginx_client_temp \
    /tmp/nginx_proxy_temp \
    /tmp/nginx_fastcgi_temp \
    /tmp/nginx_uwsgi_temp \
    /tmp/nginx_scgi_temp && \
    chown -R gituser:gituser /srv/git /var/run/fcgiwrap /home/gituser /tmp/nginx_* && \
    chmod 755 /var/run/fcgiwrap /tmp/nginx_*

# Copy configuration files
COPY configs/nginx.conf /home/gituser/nginx.conf
COPY configs/cgitrc /etc/cgitrc
COPY configs/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Fix ownership and permissions
RUN chown gituser:gituser /home/gituser/nginx.conf && \
    chmod 644 /home/gituser/nginx.conf

# Set proper ownership for git directories
RUN chown -R gituser:gituser /srv/git

# Create sample repo
RUN cd /srv/git && \
    git init --bare sample.git && \
    chown -R gituser:gituser sample.git && \
    echo "Sample Git Repository" > sample.git/description

# Switch to gituser and expose HTTP port
USER gituser
EXPOSE 8080

# Start supervisor as gituser
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]
