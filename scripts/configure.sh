#!/usr/bin/env bash
set -o errexit -o nounset -o pipefail

echo "Setting up nginx.conf" >&2

cat >> /etc/nginx/nginx.conf <<EOF

mail {
    server_name mail.nesono.com;
    auth_http localhost:8080/auth;

    proxy_pass_error_message on;

    proxy     on;
EOF

if [[ -n ${TLS_CERT:-} && -n ${TLS_KEY:-} ]]; then
  cat >> /etc/nginx/nginx.conf <<EOF
    starttls only;
    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_certificate      ${TLS_CERT};
    ssl_certificate_key  ${TLS_KEY};
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
EOF
else
  echo "NO SSL SET UP TLS_CERT: ${TLS_CERT:-}, TLS_KEY: ${TLS_KEY:-}" >&2
fi

cat >> /etc/nginx/nginx.conf <<EOF

    include /etc/nginx/mail.d/*.conf;
}
EOF

if [[ -n ${SIEVE_BACKEND:-} ]]; then
  echo "Adding sieve configuration"
  cat >> /etc/nginx/nginx.conf <<EOF

stream {
  server {

EOF
  if [[ -n ${TLS_CERT:-} && -n ${TLS_KEY:-} ]]; then
  cat >> /etc/nginx/nginx.conf <<EOF
    listen 61490 ssl;

    ssl_protocols TLSv1.2 TLSv1.3;
    ssl_ciphers 'ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305:DHE-RSA-AES128-GCM-SHA256:DHE-RSA-AES256-GCM-SHA384';
    ssl_prefer_server_ciphers off;
    ssl_certificate      ${TLS_CERT};
    ssl_certificate_key  ${TLS_KEY};
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;
EOF
  else
  echo "NO SSL SET UP FOR SIEVE TLS_CERT: ${TLS_CERT:-}, TLS_KEY: ${TLS_KEY:-}" >&2
  cat >> /etc/nginx/nginx.conf <<EOF
    listen 61490;
EOF
  fi
fi
  cat >> /etc/nginx/nginx.conf <<EOF
    proxy_pass ${SIEVE_BACKEND};
  }
}
EOF
else
  echo "NO SIEVE CONFIGURATION ADDED"
fi

echo "Configure done"