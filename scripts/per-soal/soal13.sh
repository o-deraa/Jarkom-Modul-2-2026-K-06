# ============================================================
# SOAL 13 - Redirect Kanonik
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1. Konfigurasi Redirect =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
cat > /etc/apache2/conf.d/redirect-penny.conf <<'EOF'
<VirtualHost *:80>
    ServerName 192.214.3.2
    ServerAlias penny.k06.com
    Redirect permanent / http://www.k06.com/
</VirtualHost>
EOF

# ===== 2. Validasi dan Restart Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
httpd -t
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== 1. Konfigurasi Redirect =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
cat > /etc/nginx/http.d/redirect-abbey.conf <<'EOF'
server {
    listen 80;
    server_name 192.214.2.2 abbey.k06.com;
    return 302 http://static.k06.com/;
}
EOF

# ===== 2. Validasi dan Reload Nginx =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
nginx -t
nginx -s reload 2>/dev/null || nginx

# ===== Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
curl -i http://192.214.3.2/
curl -i http://penny.k06.com/
curl -i http://192.214.2.2/
curl -i http://abbey.k06.com/

# ===== Script penny =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh
# /root/soal13.sh

cat > /etc/apache2/conf.d/redirect-penny.conf <<'EOF'
<VirtualHost *:80>
    ServerName 192.214.3.2
    ServerAlias penny.k06.com
    Redirect permanent / http://www.k06.com/
</VirtualHost>
EOF

pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== Script abbey =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
#!/bin/sh
# /root/soal13.sh

cat > /etc/nginx/http.d/redirect-abbey.conf <<'EOF'
server {
    listen 80;
    server_name 192.214.2.2 abbey.k06.com;
    return 302 http://static.k06.com/;
}
EOF

nginx -s reload 2>/dev/null || nginx

# ===== `init.sh` penny =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh
sh /root/soal11.sh >/tmp/soal11.log 2>&1
sh /root/soal12.sh >/tmp/soal12.log 2>&1
sh /root/soal13.sh >/tmp/soal13.log 2>&1

# ===== `init.sh` abbey =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
#!/bin/sh
sh /root/soal11.sh >/tmp/soal11.log 2>&1
sh /root/soal13.sh >/tmp/soal13.log 2>&1

# [PERINTAH/TESTING] >>> dijalankan di: penny
chmod +x /root/init.sh /root/soal11.sh /root/soal12.sh /root/soal13.sh

chmod +x /root/init.sh /root/soal11.sh /root/soal13.sh
