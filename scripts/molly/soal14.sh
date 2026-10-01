#!/bin/sh
# /root/soal14.sh - backend core Nginx

mkdir -p /etc/nginx/http.d /var/log/nginx

cat > /etc/nginx/http.d/00-real-ip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent"';
EOF

if ! grep -q 'access_log /var/log/nginx/access.log realip;' /etc/nginx/http.d/core.conf; then
    sed -i '/server_name /a\    access_log /var/log/nginx/access.log realip;' /etc/nginx/http.d/core.conf
fi

nginx -t || exit 1
nginx -s reload 2>/dev/null || nginx
