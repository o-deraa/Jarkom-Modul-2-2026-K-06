# ============================================================
# SOAL 9 - Web Statis dengan Autoindex (Area Vault)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Instal Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
apk update
apk add apache2

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
apk info -e apache2
httpd -v

# ===== 2 - Membuat Direktori Arsip dan Isi Contoh =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
mkdir -p /arsip

echo "Arsip rahasia The Mesh - node vault" > /arsip/readme.txt
echo "data operasi 001" > /arsip/operasi-001.txt
echo "data operasi 002" > /arsip/operasi-002.txt

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
ls -la /arsip

# ===== 3 - Konfigurasi Virtual Host =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi
cat > /etc/apache2/conf.d/vault.conf <<'EOF'
<VirtualHost *:80>
    ServerName obladi.k06.com
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

# [PERINTAH/TESTING] >>> dijalankan di: desmond
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

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
cat /etc/apache2/conf.d/vault.conf

# ===== 4 - Menjalankan Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
httpd -t

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
httpd

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
ps aux | grep [h]ttpd
netstat -tulnp | grep :80

# ===== 5 - Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: client
curl http://obladi.k06.com
curl http://desmond.k06.com

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: obladi
#!/bin/sh
# /root/soal9.sh - obladi (web statis vault)

# Tunggu koneksi internet untuk apk
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i + 1))
    sleep 1
done

# Install Apache jika belum terpasang
if ! apk info -e apache2 >/dev/null 2>&1; then
    apk update
    apk add apache2
fi

# Pastikan direktori tersedia
mkdir -p /etc/apache2/conf.d
mkdir -p /var/log/apache2
mkdir -p /arsip

# Buat file arsip jika belum ada
if [ ! -f /arsip/readme.txt ]; then
    echo "Arsip rahasia The Mesh - node vault" > /arsip/readme.txt
    echo "data operasi 001" > /arsip/operasi-001.txt
    echo "data operasi 002" > /arsip/operasi-002.txt
fi

# Konfigurasi Virtual Host
cat > /etc/apache2/conf.d/vault.conf <<'APACHE'
<VirtualHost *:80>
    ServerName obladi.k06.com
    DocumentRoot /arsip

    <Directory /arsip>
        Options +Indexes
        AllowOverride None
        Require all granted
    </Directory>

    ErrorLog /var/log/apache2/error.log
    CustomLog /var/log/apache2/access.log combined
</VirtualHost>
APACHE

# Jika Apache masih berjalan, hentikan terlebih dahulu
pkill -x httpd 2>/dev/null

# Tunggu sampai port 80 kosong
j=0
while [ $j -lt 10 ]; do
    netstat -tulnp 2>/dev/null | grep -q ':80 ' || break
    pkill -x httpd 2>/dev/null
    j=$((j + 1))
    sleep 1
done

# Validasi konfigurasi Apache
httpd -t || exit 1

# Jalankan Apache
httpd

# [PERINTAH/TESTING] >>> dijalankan di: desmond
#!/bin/sh

nohup /root/soal9.sh >/tmp/soal9.log 2>&1 &

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond
chmod +x /root/init.sh
chmod +x /root/soal9.sh

# [PERINTAH/TESTING] >>> dijalankan di: obladi dan desmond setelah restart
ps aux | grep [h]ttpd
netstat -tulnp | grep :80

# [PERINTAH/TESTING] >>> dijalankan di: klien setelah restart node
curl http://obladi.k06.com
curl http://desmond.k06.com
