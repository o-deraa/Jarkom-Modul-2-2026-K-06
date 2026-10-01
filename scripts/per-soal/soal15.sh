# ============================================================
# SOAL 15 - Jalur Proxy Khusus (/eternal di Penny, /orion di Abbey)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instal PHP-FPM =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
apk update
apk add php84 php84-fpm apache2-proxy
php-fpm84

# ===== 2 - Membuat Direktori dan File PHP =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
mkdir -p /var/www/eternal

cat > /var/www/eternal/index.php <<'EOF'
<?php
echo "<h1>Eternal - Penny</h1>\n";
echo "<p>Jalur khusus /eternal dengan eksekusi PHP.</p>\n";
echo "<p>Waktu server: " . date("Y-m-d H:i:s") . "</p>\n";
EOF

# ===== 3 - Konfigurasi Apache untuk /eternal =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
cat > /etc/apache2/conf.d/eternal.conf <<'EOF'
ProxyPass "/eternal" "!"
Alias "/eternal" "/var/www/eternal"

<Directory "/var/www/eternal">
    Options +Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOF

httpd -t
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== 1 - Membuat Direktori dan File Statis =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
mkdir -p /var/www/orion

cat > /var/www/orion/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head><title>Orion - Abbey</title></head>
<body>
    <h1>Orion - Abbey</h1>
    <p>Jalur khusus /orion yang disajikan secara statis.</p>
</body>
</html>
EOF

cat > /var/www/orion/data.txt <<'EOF'
File statis pada jalur /orion.
EOF

# ===== 2 - Konfigurasi Nginx untuk /orion =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
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
nginx -t
nginx -s reload

# ===== C. Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: client
curl http://penny.k06.com/eternal/

# [PERINTAH/TESTING] >>> dijalankan di: client
curl http://static.k06.com/orion/
curl http://static.k06.com/orion/data.txt

# ===== Script penny =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh
# /root/soal15.sh - penny (/eternal dengan PHP)

apk info -e php84-fpm >/dev/null 2>&1 || {
    apk update
    apk add php84 php84-fpm apache2-proxy
}

pgrep -x php-fpm84 >/dev/null 2>&1 || php-fpm84

mkdir -p /var/www/eternal
if [ ! -f /var/www/eternal/index.php ]; then
    cat > /var/www/eternal/index.php <<'PHP'
<?php
echo "<h1>Eternal - Penny</h1>\n";
echo "<p>Jalur khusus /eternal dengan eksekusi PHP.</p>\n";
echo "<p>Waktu server: " . date("Y-m-d H:i:s") . "</p>\n";
PHP
fi

cat > /etc/apache2/conf.d/eternal.conf <<'EOF'
ProxyPass "/eternal" "!"
Alias "/eternal" "/var/www/eternal"

<Directory "/var/www/eternal">
    Options +Indexes
    AllowOverride None
    Require all granted
    DirectoryIndex index.php
</Directory>

<FilesMatch "\.php$">
    SetHandler "proxy:fcgi://127.0.0.1:9000"
</FilesMatch>
EOF

httpd -t || exit 1
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== Script abbey =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
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

# [PERINTAH/TESTING] >>> dijalankan di: abbey
# penny
sh /root/soal11.sh >/tmp/soal11.log 2>&1
sh /root/soal12.sh >/tmp/soal12.log 2>&1
sh /root/soal13.sh >/tmp/soal13.log 2>&1
sh /root/soal15.sh >/tmp/soal15.log 2>&1

# abbey
sh /root/soal11.sh >/tmp/soal11.log 2>&1
sh /root/soal13.sh >/tmp/soal13.log 2>&1
sh /root/soal15.sh >/tmp/soal15.log 2>&1
