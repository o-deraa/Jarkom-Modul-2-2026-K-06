#!/bin/sh
# /root/soal15.sh - abbey (/orion statis)

mkdir -p /var/www/orion
if [ ! -f /var/www/orion/index.html ]; then
    cat > /var/www/orion/index.html <<'HTML'
<!DOCTYPE html>
<html>
<head><title>Orion - Abbey</title></head>
<body>
    <h1>Orion - Abbey</h1>
    <p>Jalur khusus /orion yang disajikan secara statis.</p>
</body>
</html>
HTML
    echo "File statis pada jalur /orion." > /var/www/orion/data.txt
fi

cat > /etc/nginx/http.d/orion.conf <<'EOF'
upstream core {
    server 192.214.1.21;
    server 192.214.1.22;
}

server {
    listen 80;
    server_name static.k06.com;

    location /orion/ {
        alias /var/www/orion/;
        autoindex on;
    }

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

rm -f /etc/nginx/http.d/proxy-core.conf

nginx -t || exit 1
nginx -s reload 2>/dev/null || nginx
