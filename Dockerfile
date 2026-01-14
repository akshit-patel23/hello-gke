
FROM nginx:alpine

# Build-time variable for tagging
ARG BUILD_TAG="local"
ENV BUILD_TAG=$BUILD_TAG

# Copy your HTML file into Nginx's default web root
COPY --chown=nginx:nginx hello.html /usr/share/nginx/html/index.html

# Replace placeholder with actual build tag for visibility
RUN sed -i "s/\${BUILD_TAG}/${BUILD_TAG}/g" /usr/share/nginx/html/index.html

# Expose port 80 for HTTP traffic
EXPOSE 80

# Run as non-root user for security
USER nginx
