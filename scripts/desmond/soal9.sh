#!/bin/sh
# /root/soal9.sh

# Tunggu koneksi internet siap (untuk apk).
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install Apache hanya bila belum ada.
command -v httpd >/dev/null 2>&1 || { apk update; apk add apache2; }

# 2. Pastikan direktori log ada (httpd gagal start bila tidak ada).
mkdir -p /var/log/apache2

# 3. Direktori arsip + isi contoh.
mkdir -p /arsip
[ -f /arsip/readme.txt ] || {
    echo "Arsip rahasia The Mesh - node vault" > /arsip/readme.txt
    echo "data operasi 001" > /arsip/operasi-001.txt
    echo "data operasi 002" > /arsip/operasi-002.txt
}

# 4. Virtual host dengan autoindex.
cat > /etc/apache2/conf.d/vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName desmond.k06.com
    DocumentRoot /arsip

    <Directory /arsip>
        Options +Indexes
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
EOF

# 5. Bunuh httpd apa pun secara paksa, lalu tunggu port 80 benar-benar kosong.
#    Ini mencegah httpd bawaan/hantu (DocumentRoot default -> 404) menahan port 80
#    sehingga httpd baru gagal bind dan mati diam-diam.
pkill -9 httpd 2>/dev/null
j=0
while [ $j -lt 10 ]; do
    netstat -tulnp 2>/dev/null | grep -q ':80 ' || break
    pkill -9 httpd 2>/dev/null
    j=$((j+1))
    sleep 1
done

# 6. Start httpd (kini vault.conf pasti dimuat).
httpd
