FROM nginx
COPY nginx.conf /etc/nginx/nginx.conf
COPY http_auth.conf /etc/nginx/conf.d/http_auth.conf
COPY fastcgi_params /etc/nginx/fastcgi_params
COPY nginx_auth.cgi /usr/local/bin
RUN mkdir -p /etc/nginx/mail.d/
COPY smtp.conf /etc/nginx/mail.d/smtp.conf
COPY imap.conf /etc/nginx/mail.d/imap.conf
COPY supervisord.conf /etc
COPY docker_entrypoint.sh /
COPY smtp_nesono_com.conf /etc/stunnel/smtp_nesono_com.conf
RUN apt-get update && \
    apt-get install -y  --no-install-recommends \
    python3-pip supervisor stunnel && \
    pip install flup
RUN mkdir -p /var/run/fcgi && \
    chown nginx:nginx /var/run/fcgi

ENTRYPOINT ["/docker_entrypoint.sh"]
