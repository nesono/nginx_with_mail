FROM nginx:1.27.4
LABEL maintainer="Jochen Issing <c.333+github@nesono.com> (@jochenissing)"

RUN apt-get update && \
    apt-get install -y  --no-install-recommends \
    python3-pip supervisor stunnel python3-venv

COPY scripts/configure.sh /usr/local/bin

COPY nginx/fastcgi_params /etc/nginx/fastcgi_params
COPY nginx_smtp_imap_auth.cgi /usr/local/bin
COPY nginx_submission_auth.cgi /usr/local/bin

RUN mkdir -p /etc/nginx/mail.d/
COPY nginx/mail.d/smtp.template /etc/nginx/mail.d/smtp.template
COPY nginx/mail.d/submission.template /etc/nginx/mail.d/submission.template
COPY nginx/mail.d/imap.template /etc/nginx/mail.d/imap.template

COPY requirements.txt /opt/
RUN python3 -m venv /opt/venv && /opt/venv/bin/pip3 install -r /opt/requirements.txt
RUN mkdir -p /var/run/fcgi && \
    chown nginx:nginx /var/run/fcgi

COPY supervisord/programs.conf /etc/supervisor/conf.d/
COPY docker_entrypoint.sh /


ENTRYPOINT ["/docker_entrypoint.sh"]
