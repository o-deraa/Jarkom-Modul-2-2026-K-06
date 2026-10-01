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
