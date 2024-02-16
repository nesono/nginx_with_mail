FROM nginx
LABEL maintainer="Jochen Issing <c.333+github@nesono.com> (@jochenissing)"

RUN apt-get update && \
    apt-get install -y  --no-install-recommends \
    python3-pip supervisor stunnel python3-venv

COPY scripts/configure.sh /usr/local/bin

RUN rm -f /etc/nginx/conf.d/default.conf
COPY nginx/conf.d/http_auth.conf /etc/nginx/conf.d/http_auth.conf
COPY nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY nginx_auth.cgi /usr/local/bin
RUN mkdir -p /etc/nginx/mail.d/
COPY nginx/mail.d/smtp.conf /etc/nginx/mail.d/smtp.conf
COPY nginx/mail.d/imap.conf /etc/nginx/mail.d/imap.conf
COPY nginx/mail.d/sieve.conf /etc/nginx/mail.d/sieve.conf

RUN python3 -m venv /opt/venv && /opt/venv/bin/pip3 install flup
RUN mkdir -p /var/run/fcgi && \
    chown nginx:nginx /var/run/fcgi

COPY supervisord/programs.conf /etc/supervisor/conf.d/
COPY docker_entrypoint.sh /

COPY stunnel/stunnel.conf /etc/stunnel/


ENTRYPOINT ["/docker_entrypoint.sh"]
