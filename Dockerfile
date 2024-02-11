FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY http_auth.conf /etc/nginx/conf.d/http_auth.conf
COPY fastcgi_params /etc/nginx/fastcgi_params
COPY nginx_auth.cgi /usr/local/bin
COPY supervisord.conf /etc
COPY docker_entrypoint.sh /
RUN apt update && \
    apt install -y  --no-install-recommends \
    python3-pip supervisor && \
    pip install flup
RUN mkdir -p /var/run/fcgi && \
    chown nginx:nginx /var/run/fcgi \
RUN mkdir -p /etc/nginx/mail.d/
COPY smtp.conf /etc/nginx/mail.d/smtp.conf
COPY imap.conf /etc/nginx/mail.d/imap.conf

ENTRYPOINT ["/docker_entrypoint.sh"]
