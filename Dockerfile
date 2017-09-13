FROM ubuntu:rolling

RUN apt update && apt install -y nginx
RUN rm /etc/nginx/sites-enabled/default

ADD nginx.conf /etc/nginx
ADD proxy /etc/nginx/sites-enabled

EXPOSE 8888

CMD service nginx start
