# ============================================================
# SOAL 5 - Penamaan Hostname dan Domain per Node
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Penamaan Hostname (Semua Node) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
hostname
cat /etc/hostname

# ===== 2 - Menambahkan A Record per Node =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat >> /etc/bind/zones/k06.com.db <<'EOF'

alpha           IN      A       192.214.4.2
beta            IN      A       192.214.4.3
gamma           IN      A       192.214.4.4
delta           IN      A       192.214.5.2
epsilon         IN      A       192.214.5.3
abbey           IN      A       192.214.2.2
penny           IN      A       192.214.3.2
obladi          IN      A       192.214.1.11
desmond         IN      A       192.214.1.12
oblada          IN      A       192.214.1.21
molly           IN      A       192.214.1.22
EOF

# ===== 3 - Menaikkan Serial SOA =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
sed -i 's/2026100401 ; Serial/2026100402 ; Serial/' /etc/bind/zones/k06.com.db

# ===== 4 - Menerapkan Perubahan =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
chown named:named /etc/bind/zones/k06.com.db
named-checkzone k06.com /etc/bind/zones/k06.com.db
rndc reload k06.com

# ===== 5 - Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 alpha.k06.com +short
dig @127.0.0.1 molly.k06.com +short
dig @127.0.0.1 abbey.k06.com +short

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 alpha.k06.com +short
dig @127.0.0.1 obladi.k06.com +short

# [PERINTAH/TESTING] >>> dijalankan di: prab
ping -c3 beta.k06.com
ping -c3 molly.k06.com
ping -c3 abbey.k06.com

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
#!/bin/sh
# /root/soal5.sh 

ZONE=/etc/bind/zones/k06.com.db

# Tunggu soal4.sh selesai membuat file zona dan menjalankan named.
i=0
while [ $i -lt 90 ]; do
    if [ -f "$ZONE" ] && pgrep -x named >/dev/null 2>&1; then
        break
    fi
    i=$((i+1))
    sleep 1
done

# Idempoten: kalau record node sudah ada, tidak usah menambah lagi.
grep -q '^alpha' "$ZONE" && exit 0

# Tambahkan A record per-node (prab & tedd sudah ada dari soal4, tidak diulang).
cat >> "$ZONE" <<'EOF'

alpha           IN      A       192.214.4.2
beta            IN      A       192.214.4.3
gamma           IN      A       192.214.4.4
delta           IN      A       192.214.5.2
epsilon         IN      A       192.214.5.3
abbey           IN      A       192.214.2.2
penny           IN      A       192.214.3.2
obladi          IN      A       192.214.1.11
desmond         IN      A       192.214.1.12
oblada          IN      A       192.214.1.21
molly           IN      A       192.214.1.22
EOF

# Naikkan serial agar tedd (slave) menarik ulang salinan zona.
sed -i 's/2026100401 ; Serial/2026100402 ; Serial/' "$ZONE"

# Terapkan perubahan: reload lewat rndc, fallback restart named.
chown named:named "$ZONE"
rndc reload k06.com 2>/dev/null || { pkill named; named -c /etc/bind/named.conf -u named; }

# [KONFIGURASI] >>> dijalankan di: prab
    post-up nohup sh /root/soal4.sh >/tmp/soal4.log 2>&1 &
    post-up nohup sh /root/soal5.sh >/tmp/soal5.log 2>&1 &
