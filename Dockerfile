# Lightweight Nginx image
FROM nginx:alpine

# Copy hello.html as index.html
COPY hello.html /usr/share/nginx/html/index.html

# Expose port 80
EXPOSE 80

# Nginx will run in foreground by default via base image's CMD
