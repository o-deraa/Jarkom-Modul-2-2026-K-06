# ============================================================
# SOAL 12 - Basic Authentication pada Path `/admin`
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instalasi Tools Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
apk update
apk add apache2 apache2-proxy apache2-utils

# ===== 2 - Membuat Direktori dan File Rahasia =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
mkdir -p /var/www/admin
echo "Dokumen rahasia sindikat The Mesh" > /var/www/admin/rahasia.txt

cat > /var/www/admin/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Ruang Rahasia The Mesh</title>
</head>
<body>
    <h1>Dokumen Rahasia Sindikat The Mesh</h1>
    <p>Akses berhasil menggunakan Basic Authentication.</p>
</body>
</html>
EOF

# ===== 3 - Membuat File Kredensial =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chown root:apache /etc/apache2/.htpasswd
chmod 640 /etc/apache2/.htpasswd

# ===== 4 - Konfigurasi Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
cat > /etc/apache2/conf.d/proxy-vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k06.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    # /admin dilayani lokal oleh penny, bukan diteruskan ke backend.
    ProxyPass "/admin" "!"
    Alias "/admin" "/var/www/admin"

    <Directory "/var/www/admin">
        Options -Indexes
        AllowOverride None
        AuthType Basic
        AuthName "Ruang Rahasia The Mesh"
        AuthUserFile "/etc/apache2/.htpasswd"
        Require valid-user
    </Directory>

    <Proxy "balancer://vault">
        BalancerMember "http://192.214.1.11"
        BalancerMember "http://192.214.1.12"
    </Proxy>

    ProxyPass        "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"
</VirtualHost>
EOF

# ===== 5 - Validasi dan Menjalankan Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
httpd -t
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# ===== Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: klien, contoh: alpha
curl -i http://penny.k06.com/admin/

# [PERINTAH/TESTING] >>> dijalankan di: klien, contoh: alpha
curl -i -u 'prabs:pakar_pinter_jadi_gob***' http://penny.k06.com/admin/

# [PERINTAH/TESTING] >>> dijalankan di: klien, contoh: alpha
curl -i -u 'prabs:password-salah' http://penny.k06.com/admin/

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh
# /root/soal12.sh - penny (

i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i + 1))
    sleep 1
done

# Instal Apache dan tools yang diperlukan jika belum tersedia.
if ! apk info -e apache2 >/dev/null 2>&1 || \
   ! apk info -e apache2-proxy >/dev/null 2>&1 || \
   ! apk info -e apache2-utils >/dev/null 2>&1; then
    apk update
    apk add apache2 apache2-proxy apache2-utils
fi

mkdir -p /etc/apache2/conf.d /var/log/apache2 /var/www/admin

echo "Dokumen rahasia sindikat The Mesh" > /var/www/admin/rahasia.txt

cat > /var/www/admin/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Ruang Rahasia The Mesh</title>
</head>
<body>
    <h1>Dokumen Rahasia Sindikat The Mesh</h1>
    <p>Akses berhasil menggunakan Basic Authentication.</p>
</body>
</html>
EOF

# Buat atau perbarui kredensial Basic Authentication.
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chown root:apache /etc/apache2/.htpasswd
chmod 640 /etc/apache2/.htpasswd

# Konfigurasi reverse proxy + pengecualian /admin.
cat > /etc/apache2/conf.d/proxy-vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k06.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    ProxyPass "/admin" "!"
    Alias "/admin" "/var/www/admin"

    <Directory "/var/www/admin">
        Options -Indexes
        AllowOverride None
        AuthType Basic
        AuthName "Ruang Rahasia The Mesh"
        AuthUserFile "/etc/apache2/.htpasswd"
        Require valid-user
    </Directory>

    <Proxy "balancer://vault">
        BalancerMember "http://192.214.1.11"
        BalancerMember "http://192.214.1.12"
    </Proxy>

    ProxyPass        "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"
</VirtualHost>
EOF

# Terapkan konfigurasi terbaru.
httpd -t || exit 1
pkill -9 httpd 2>/dev/null
sleep 1
httpd

# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh

sh /root/soal11.sh >/tmp/soal11.log 2>&1
status11=$?

sh /root/soal12.sh >/tmp/soal12.log 2>&1
status12=$?

[ "$status11" -eq 0 ] && [ "$status12" -eq 0 ]

# [PERINTAH/TESTING] >>> dijalankan di: penny
[ -f /root/init.sh ] && [ -x /root/init.sh ] && /root/init.sh

# [PERINTAH/TESTING] >>> dijalankan di: penny
chmod +x /root/init.sh
chmod +x /root/soal11.sh
chmod +x /root/soal12.sh
