# ============================================================
# SOAL 10 - Web Dinamis PHP-FPM + Nginx (Area Core)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instal Nginx dan PHP-FPM =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
apk update
apk add nginx php84 php84-fpm

# ===== 2 - Membuat Aplikasi (Beranda dan Profil) =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
mkdir -p /var/www/core

cat > /var/www/core/index.php <<'EOF'
<?php
echo "<h1>Beranda - The Mesh Core</h1>\n";
echo "<p>Selamat datang di layanan web dinamis area core.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF

cat > /var/www/core/profil.php <<'EOF'
<?php
echo "<h1>Profil - The Mesh Core</h1>\n";
echo "<p>Halaman profil aplikasi dinamis.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF

# ===== 3 - Konfigurasi Nginx (dengan Rewrite Clean URL) =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
rm -f /etc/nginx/http.d/default.conf
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name oblada.k06.com;
    root /var/www/core;
    index index.php;

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
EOF

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
rm -f /etc/nginx/http.d/default.conf
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name molly.k06.com;
    root /var/www/core;
    index index.php;

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
EOF

# ===== 4 - Menjalankan PHP-FPM dan Nginx =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
nginx -t
php-fpm84
nginx

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
pgrep -x nginx
pgrep -x php-fpm84

# ===== 5 - Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
curl http://oblada.k06.com/
curl http://oblada.k06.com/profil
curl http://molly.k06.com/
curl http://molly.k06.com/profil

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
#!/bin/sh
# /root/soal10.sh

# Berhenti kalau nginx sudah jalan.
pgrep -x nginx >/dev/null 2>&1 && exit 0

# Tunggu koneksi internet siap (untuk apk).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install nginx + php-fpm
apk update
apk add nginx php84 php84-fpm

# 2. Aplikasi beranda + profil
mkdir -p /var/www/core
cat > /var/www/core/index.php <<'EOF'
<?php
echo "<h1>Beranda - The Mesh Core</h1>\n";
echo "<p>Selamat datang di layanan web dinamis area core.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF
cat > /var/www/core/profil.php <<'EOF'
<?php
echo "<h1>Profil - The Mesh Core</h1>\n";
echo "<p>Halaman profil aplikasi dinamis.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF

# 3. Konfigurasi nginx (clean URL /profil via named location @php)
rm -f /etc/nginx/http.d/default.conf
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name oblada.k06.com;
    root /var/www/core;
    index index.php;

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
EOF

# 4. Start php-fpm + nginx
php-fpm84
nginx

# [PERINTAH/TESTING] >>> dijalankan di: oblada dan molly
#!/bin/sh
# /root/soal10.sh

# Berhenti kalau nginx sudah jalan.
pgrep -x nginx >/dev/null 2>&1 && exit 0

# Tunggu koneksi internet siap (untuk apk).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install nginx + php-fpm
apk update
apk add nginx php84 php84-fpm

# 2. Aplikasi beranda + profil
mkdir -p /var/www/core
cat > /var/www/core/index.php <<'EOF'
<?php
echo "<h1>Beranda - The Mesh Core</h1>\n";
echo "<p>Selamat datang di layanan web dinamis area core.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF
cat > /var/www/core/profil.php <<'EOF'
<?php
echo "<h1>Profil - The Mesh Core</h1>\n";
echo "<p>Halaman profil aplikasi dinamis.</p>\n";
echo "<p>Dilayani oleh: " . gethostname() . "</p>\n";
EOF

# 3. Konfigurasi nginx (clean URL /profil via named location @php)
rm -f /etc/nginx/http.d/default.conf
cat > /etc/nginx/http.d/core.conf <<'EOF'
server {
    listen 80;
    server_name molly.k06.com;
    root /var/www/core;
    index index.php;

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
EOF

# 4. Start php-fpm + nginx
php-fpm84
nginx

# [KONFIGURASI] >>> dijalankan di: oblada dan molly
    post-up nohup sh /root/soal10.sh >/tmp/soal10.log 2>&1 &
