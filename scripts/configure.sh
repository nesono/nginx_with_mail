#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

if [[ -r /etc/nginx/nginx.conf.bup ]]; then
  echo "Rolling back nginx.conf changes" >&2
  cp /etc/nginx/nginx.conf.bup /etc/nginx/nginx.conf
else
  echo "Backing up original nginx.conf" >&2
  cp /etc/nginx/nginx.conf /etc/nginx/nginx.conf.bup
fi

echo "Setting up nginx.conf" >&2
echo "Adding mail extension to nginx.conf" >&2
cat >> /etc/nginx/nginx.conf <<EOF

mail {
    server_name mail.nesono.com;

    proxy_pass_error_message on;

    proxy     on;
EOF

echo "Adding mail_auth.conf to /etc/nginx/conf.d/" >&2
cat > /etc/nginx/conf.d/mail_auth.conf <<'EOF'
server {
    listen 8080 default_server;
    listen [::]:8080 default_server;
    root /var/www/html;
    server_name _;
    location /auth_smtp_imap {
        include /etc/nginx/fastcgi_params;
        fastcgi_param PATH_INFO $fastcgi_script_name;
        fastcgi_pass unix:/var/run/fcgi/nginx_smtp_imap_auth.sock;
    }
    location /auth_submission {
            include /etc/nginx/fastcgi_params;
            fastcgi_param PATH_INFO $fastcgi_script_name;
            fastcgi_pass unix:/var/run/fcgi/nginx_submission_auth.sock;
    }
}
EOF


if [[ -n ${MAIL_TLS_CERT:-} && -n ${MAIL_TLS_KEY:-} ]]; then
  echo "Setting up SSL in nginx.conf" >&2
  cat >> /etc/nginx/nginx.conf <<EOF
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_certificate      ${MAIL_TLS_CERT};
    ssl_certificate_key  ${MAIL_TLS_KEY};
    ssl_session_timeout 10m;
EOF
else
  echo "NO SSL SET UP MAIL_TLS_CERT: \"${MAIL_TLS_CERT:-}\", MAIL_TLS_KEY: \"${MAIL_TLS_KEY:-}\"" >&2
fi

cat >> /etc/nginx/nginx.conf <<EOF

    include /etc/nginx/mail.d/*.conf;
}
EOF

if [[ -n ${SIEVE_SERVER:-} && -n ${SIEVE_PORT:-} ]]; then
  echo "Adding sieve configuration" >&2
  cat >> /etc/nginx/nginx.conf <<EOF

stream {
  server {

EOF
  if [[ -n ${MAIL_TLS_CERT:-} && -n ${MAIL_TLS_KEY:-} ]]; then
  cat >> /etc/nginx/nginx.conf <<EOF
    listen 64190 ssl;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_certificate      ${MAIL_TLS_CERT};
    ssl_certificate_key  ${MAIL_TLS_KEY};
    ssl_session_timeout 10m;
EOF
  else
  echo "NO SSL SET UP FOR SIEVE MAIL_TLS_CERT: ${MAIL_TLS_CERT:-}, MAIL_TLS_KEY: ${MAIL_TLS_KEY:-}" >&2
  cat >> /etc/nginx/nginx.conf <<EOF
    listen 64190;
EOF
  fi
  cat >> /etc/nginx/nginx.conf <<EOF
    proxy_pass ${SIEVE_SERVER}:${SIEVE_PORT};
  }
}
EOF
else
  echo "NO SIEVE CONFIGURATION ADDED" >&2
fi


: ${SMTP_BANNER_NAME:=smtp.nginx}
: ${IMAP_BANNER_NAME:=imap.nginx}
export SMTP_BANNER_NAME
export IMAP_BANNER_NAME
echo "Creating nginx mail configuration from templates" >&2
envsubst < /etc/nginx/mail.d/smtp.template > /etc/nginx/mail.d/smtp.conf
envsubst < /etc/nginx/mail.d/submission.template > /etc/nginx/mail.d/submission.conf
envsubst < /etc/nginx/mail.d/imap.template > /etc/nginx/mail.d/imap.conf

echo "Configure done" >&2