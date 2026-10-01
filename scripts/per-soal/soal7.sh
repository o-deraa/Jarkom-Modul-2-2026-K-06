# ============================================================
# SOAL 7 - A Record vault/core dan CNAME www/static
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Menambahkan A Record vault dan core (di prab) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat >> /etc/bind/zones/k06.com.db <<'EOF'

vault           IN      A       192.214.1.11
vault           IN      A       192.214.1.12
core            IN      A       192.214.1.21
core            IN      A       192.214.1.22
EOF

# ===== 2 - Menambahkan CNAME www dan static =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat >> /etc/bind/zones/k06.com.db <<'EOF'
www             IN      CNAME   penny.k06.com.
static          IN      CNAME   abbey.k06.com.
EOF

# ===== 3 - Menaikkan Serial SOA dan Menerapkan Perubahan =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
sed -i 's/[0-9]\{10\} ; Serial/2026100407 ; Serial/' /etc/bind/zones/k06.com.db
chown named:named /etc/bind/zones/k06.com.db
named-checkzone k06.com /etc/bind/zones/k06.com.db
rndc reload k06.com

# ===== 4 - Verifikasi dari Dua Klien Berbeda =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig vault.k06.com +short
dig core.k06.com +short
dig www.k06.com +short
dig static.k06.com +short

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
#!/bin/sh
# /root/soal7.sh - prab

ZONE=/etc/bind/zones/k06.com.db

# Tunggu record soal5 (alpha) sudah terpasang agar urutan record konsisten.
i=0
while [ $i -lt 120 ]; do
    if [ -f "$ZONE" ] && grep -q '^alpha' "$ZONE" && pgrep -x named >/dev/null 2>&1; then
        break
    fi
    i=$((i+1))
    sleep 1
done

# Idempoten: kalau record vault sudah ada, tidak usah menambah lagi.
grep -q '^vault' "$ZONE" && exit 0

# Tambahkan A record vault/core dan CNAME www/static.
cat >> "$ZONE" <<'EOF'

vault           IN      A       192.214.1.11
vault           IN      A       192.214.1.12
core            IN      A       192.214.1.21
core            IN      A       192.214.1.22
www             IN      CNAME   penny.k06.com.
static          IN      CNAME   abbey.k06.com.
EOF

# Set serial absolut untuk soal 7 (selalu lebih besar dari soal sebelumnya).
sed -i 's/[0-9]\{10\} ; Serial/2026100407 ; Serial/' "$ZONE"

# Terapkan perubahan.
chown named:named "$ZONE"
rndc reload k06.com 2>/dev/null || { pkill named; named -c /etc/bind/named.conf -u named; }

# [KONFIGURASI] >>> dijalankan di: prab
    post-up nohup sh /root/soal4.sh >/tmp/soal4.log 2>&1 &
    post-up nohup sh /root/soal5.sh >/tmp/soal5.log 2>&1 &
    post-up nohup sh /root/soal7.sh >/tmp/soal7.log 2>&1 &
