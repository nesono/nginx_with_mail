# nginx with mail Docker image

Some modifications to use nginx with mail reverse proxy configuration.

Docker Compose example:

```yaml
  nginx-proxy:
    image: nesono/nginx_with_mail:2024-02-15.1.pre
    container_name: nginx-proxy
    # The ports are ignored, since we use network_mode: host
#    ports:
#      - "80:80"
#      - "443:443"
#      - "2525:2525"
    volumes:
#      - nginx_conf:/etc/nginx/conf.d:ro
#      - nginx_mail:/etc/nginx/mail.d:ro
#      - nginx_vhost:/etc/nginx/vhost.d:ro
#      - nginx_html:/usr/share/nginx/html
      - /svc/volumes/acme/certs/mail.nesono.com:/etc/nginx/certs:ro
    environment:
      TLS_CERT: /etc/nginx/certs/fullchain.pem
      TLS_KEY: /etc/nginx/certs/key.pem
      IMAP_SERVER: localhost
      IMAP_PORT: 1111
      SMTP_SERVER: localhost
      SMTP_PORT: 1110
      SIEVE_SERVER: localhost
      SIEVE_PORT: 1112
#    labels:
#      - "com.github.jrcs.letsencrypt_nginx_proxy_companion.nginx_proxy"
    network_mode: host
    restart: on-failure
```