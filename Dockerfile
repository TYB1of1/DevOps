# Dockerfile
FROM nginx:alpine

# Remove default nginx website files
RUN rm -rf /usr/share/nginx/html/*

# Copy only necessary website assets from the build context
# Assumes your structure is:
# .
# |- index.html
# |- styles.css
# |- assets/
#    |- resume/
#       |- Theophilus_Boakye_CV.pdf
# |- Dockerfile
# |- Jenkinsfile
# |- .dockerignore

COPY index.html /usr/share/nginx/html/
COPY styles.css /usr/share/nginx/html/
COPY assets/ /usr/share/nginx/html/assets/
# Add other specific files or directories like 'js/', 'images/' if they exist

EXPOSE 80

# Nginx will start automatically using the base image's CMD
