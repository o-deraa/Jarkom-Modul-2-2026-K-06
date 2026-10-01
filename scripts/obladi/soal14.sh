#!/bin/sh
# /root/soal14.sh - backend vault Apache

mkdir -p /etc/apache2/conf.d /var/log/apache2

cat > /etc/apache2/conf.d/real-ip.conf <<'EOF'
LoadModule remoteip_module modules/mod_remoteip.so
RemoteIPHeader X-Real-IP
RemoteIPTrustedProxy 192.214.3.2
LogFormat "%a - %u %t \"%r\" %>s %b \"%{Referer}i\" \"%{User-Agent}i\"" realip
EOF

sed -i 's#CustomLog /var/log/apache2/access.log combined#CustomLog /var/log/apache2/access.log realip#' /etc/apache2/conf.d/vault.conf

httpd -t || exit 1
pkill -9 httpd 2>/dev/null
sleep 1
httpd
