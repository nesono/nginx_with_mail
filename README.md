# nginx with mail Docker image

Some modifications to use nginx with mail reverse proxy configuration.

Docker Compose example:

```yaml
  nginx-proxy:
    image: nesono/nginx_with_mail:2024-03-05
    container_name: nginx-proxy
    ports:
      - "80:80"     # HTTP (for acme-companion)
      - "443:443"   # HTTPS
      - "25:25"     # SMTP
      - "587:587"   # SUBMISSION
      - "465:465"   # SMTPS (terminated here)
      - "143:143"   # IMAP
      - "993:993"   # IMAPS (terminated here)
    volumes:
      - nginx_conf:/etc/nginx/conf.d:ro
      - nginx_mail:/etc/nginx/mail.d:ro
      - nginx_vhost:/etc/nginx/vhost.d:ro
      - nginx_html:/usr/share/nginx/html
      - /svc/volumes/acme/certs/mail.nesono.com:/etc/nginx/certs:ro
    environment:
      MAIL_TLS_CERT: /etc/nginx/certs/fullchain.pem
      MAIL_TLS_KEY: /etc/nginx/certs/key.pem
      SERVER_NAME: mail.example.com
      SMTP_BANNER_NAME: smtp.example.com
      IMAP_BANNER_NAME: imap.example.com
      SMTP_SERVER: localhost
      SMTP_PORT: 25
      SUBMISSION_SERVER: localhost
      SUBMISSION_PORT: 587
      IMAP_SERVER: localhost
      IMAP_PORT: 143
      SIEVE_SERVER: localhost
      SIEVE_PORT: 4190
    labels:
      - "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy"
    restart: on-failure
```