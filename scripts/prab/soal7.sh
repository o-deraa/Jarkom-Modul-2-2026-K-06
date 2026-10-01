#!/bin/sh
# /root/soal7.sh - prab
# Menambahkan A record vault/core dan CNAME www/static ke zona k06.com.
# Dipanggil dari post-up SETELAH soal5.sh. Idempoten + menunggu soal5 siap.

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
