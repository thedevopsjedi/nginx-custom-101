FROM nginx:1.21.1-alpine
COPY ./site-content /usr/share/nginx/html
COPY ./default.conf /etc/nginx/conf.d/default.conf
EXPOSE 4000/tcp