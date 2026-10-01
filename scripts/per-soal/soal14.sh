# ============================================================
# SOAL 14 - Access Log dengan IP Asli Klien
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Memastikan Penny Meneruskan IP Asli =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
sed -i 's#RequestHeader set X-Real-IP.*#RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}#' \
/etc/apache2/conf.d/proxy-vault.conf

httpd -t
pkill -9 httpd 2>/dev/null
sleep 2
httpd

# ===== 2 - Konfigurasi Backend Vault (Apache) =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
cat > /etc/apache2/conf.d/real-ip.conf <<'EOF'
LoadModule remoteip_module modules/mod_remoteip.so

RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy 192.214.3.2

LogFormat "%a - %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" realip
EOF

sed -i 's#CustomLog /var/log/apache2/access.log combined#CustomLog /var/log/apache2/access.log realip#' \
/etc/apache2/conf.d/vault.conf

httpd -t
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== 3 - Konfigurasi Backend Core (Nginx) =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
cat > /etc/nginx/http.d/00-real-ip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent"';
EOF

# [KONFIGURASI] >>> dijalankan di: oblada dan molly
access_log /var/log/nginx/access.log realip;

# [KONFIGURASI] >>> dijalankan di: oblada dan molly
server {
    listen 80;
    server_name oblada.k06.com;
    root /var/www/core;
    index index.php;

    access_log /var/log/nginx/access.log realip;

    location / {
        try_files $uri $uri/ @php;
    }

    location @php {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi.conf;
        fastcgi_param SCRIPT_FILENAME $document_root$uri.php;
    }

    location ~ \.php$ {
        fastcgi_pass 127.0.0.1:9000;
        include fastcgi.conf;
    }
}

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
nginx -t
nginx -s reload

# ===== 4 - Menghasilkan Request dari Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
curl http://www.k06.com/
curl http://static.k06.com/

# ===== 5 - Memeriksa Access Log Backend =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi atau desmond
tail -n 10 /var/log/apache2/access.log

# [PERINTAH/TESTING] >>> dijalankan di: oblada atau molly
tail -n 10 /var/log/nginx/access.log

# ===== Script pada obladi dan desmond =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
#!/bin/sh
# /root/soal14.sh - backend vault Apache

mkdir -p /etc/apache2/conf.d /var/log/apache2

cat > /etc/apache2/conf.d/real-ip.conf <<'EOF'
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy 192.214.3.2

LogFormat "%a - %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" realip
EOF

sed -i 's#CustomLog /var/log/apache2/access.log combined#CustomLog /var/log/apache2/access.log realip#' \
/etc/apache2/conf.d/vault.conf

httpd -t || exit 1
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== Script pada oblada dan molly =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
#!/bin/sh
# /root/soal14.sh - backend core Nginx

mkdir -p /etc/nginx/http.d /var/log/nginx

cat > /etc/nginx/http.d/00-real-ip-log.conf <<'EOF'
log_format realip '$http_x_real_ip - $remote_addr - $remote_user [$time_local] "$request" '
                  '$status $body_bytes_sent "$http_referer" '
                  '"$http_user_agent"';
EOF

# Tambahkan access_log ke server block core satu kali.
if ! grep -q 'access_log /var/log/nginx/access.log realip;' /etc/nginx/http.d/core.conf; then
    sed -i '/server_name /a\    access_log /var/log/nginx/access.log realip;' /etc/nginx/http.d/core.conf
fi

nginx -t || exit 1
nginx -s reload 2>/dev/null || nginx

# [PERINTAH/TESTING] >>> dijalankan di: obladi, desmond, oblada, dan molly
chmod +x /root/soal14.sh

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
#!/bin/sh
sh /root/soal9.sh >/tmp/soal9.log 2>&1
sh /root/soal14.sh >/tmp/soal14.log 2>&1

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
#!/bin/sh
sh /root/soal10.sh >/tmp/soal10.log 2>&1
sh /root/soal14.sh >/tmp/soal14.log 2>&1
