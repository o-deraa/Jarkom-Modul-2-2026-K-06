#!/bin/sh
# /root/soal12.sh - penny (Basic Authentication /admin)

# Tunggu koneksi jaringan siap.
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

# Buat atau perbarui kredensial Basic Authentication.
htpasswd -bc /etc/apache2/.htpasswd prabs 'pakar_pinter_jadi_gob***'
chown root:apache /etc/apache2/.htpasswd
chmod 640 /etc/apache2/.htpasswd

# Konfigurasi reverse proxy + pengecualian /admin.
cat > /etc/apache2/conf.d/proxy-vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName penny.k06.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP "%{REMOTE_ADDR}s"

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
