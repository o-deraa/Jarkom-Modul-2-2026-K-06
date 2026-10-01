# ============================================================
# SOAL 8 - Reverse Zone dan PTR Record
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Deklarasi Reverse Zone di prab (Master) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat >> /etc/bind/named.conf <<'EOF'

zone "1.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.1";
    notify yes;
    allow-transfer { 192.214.1.3; };
};

zone "2.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.2";
    notify yes;
    allow-transfer { 192.214.1.3; };
};

zone "3.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.3";
    notify yes;
    allow-transfer { 192.214.1.3; };
};
EOF

# ===== 2 - Membuat File Reverse Zone / PTR (di prab) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat > /etc/bind/zones/db.192.214.1 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

11      IN      PTR     obladi.k06.com.
12      IN      PTR     desmond.k06.com.
21      IN      PTR     oblada.k06.com.
22      IN      PTR     molly.k06.com.
EOF

# [PERINTAH/TESTING] >>> dijalankan di: prab
cat > /etc/bind/zones/db.192.214.2 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

2       IN      PTR     abbey.k06.com.
EOF

# [PERINTAH/TESTING] >>> dijalankan di: prab
cat > /etc/bind/zones/db.192.214.3 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

2       IN      PTR     penny.k06.com.
EOF

# ===== 3 - Validasi dan Menerapkan Perubahan =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
chown -R named:named /etc/bind/zones
named-checkconf /etc/bind/named.conf
named-checkzone 1.214.192.in-addr.arpa /etc/bind/zones/db.192.214.1
named-checkzone 2.214.192.in-addr.arpa /etc/bind/zones/db.192.214.2
named-checkzone 3.214.192.in-addr.arpa /etc/bind/zones/db.192.214.3
rndc reload

# ===== 4 - Konfigurasi Slave di tedd =====
# [PERINTAH/TESTING] >>> dijalankan di: tedd
cat >> /etc/bind/named.conf <<'EOF'

zone "1.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.1";
};

zone "2.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.2";
};

zone "3.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.3";
};
EOF

named-checkconf /etc/bind/named.conf
rndc reload

# ===== 5 - Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
host -t ptr 192.214.2.2
host -t ptr 192.214.3.2
host -t ptr 192.214.1.11
host -t ptr 192.214.1.12
host -t ptr 192.214.1.21
host -t ptr 192.214.1.22

# [PERINTAH/TESTING] >>> dijalankan di: prab
# prab 
dig -x 192.214.2.2 @192.214.1.2 +short
dig -x 192.214.1.11 @192.214.1.2 +short

# tedd 
dig -x 192.214.2.2 @192.214.1.3 +short
dig -x 192.214.1.11 @192.214.1.3 +short

# ===== Persistensi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
#!/bin/sh
# /root/soal8.sh

CONF=/etc/bind/named.conf

# Tunggu named siap (soal4 sudah jalan).
i=0
while [ $i -lt 120 ]; do
    pgrep -x named >/dev/null 2>&1 && [ -f "$CONF" ] && break
    i=$((i+1))
    sleep 1
done

# Idempoten: kalau reverse zone sudah ada di named.conf, berhenti.
grep -q 'in-addr.arpa' "$CONF" && exit 0

# Tambahkan deklarasi tiga reverse zone (master).
cat >> "$CONF" <<'EOF'

zone "1.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.1";
    notify yes;
    allow-transfer { 192.214.1.3; };
};

zone "2.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.2";
    notify yes;
    allow-transfer { 192.214.1.3; };
};

zone "3.214.192.in-addr.arpa" {
    type master;
    file "/etc/bind/zones/db.192.214.3";
    notify yes;
    allow-transfer { 192.214.1.3; };
};
EOF

# File PTR segmen 1 (vault + core).
cat > /etc/bind/zones/db.192.214.1 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

11      IN      PTR     obladi.k06.com.
12      IN      PTR     desmond.k06.com.
21      IN      PTR     oblada.k06.com.
22      IN      PTR     molly.k06.com.
EOF

# File PTR segmen 2 (abbey).
cat > /etc/bind/zones/db.192.214.2 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

2       IN      PTR     abbey.k06.com.
EOF

# File PTR segmen 3 (penny).
cat > /etc/bind/zones/db.192.214.3 <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100408 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@       IN      NS      prab.k06.com.
@       IN      NS      tedd.k06.com.

2       IN      PTR     penny.k06.com.
EOF

chown -R named:named /etc/bind/zones
rndc reload 2>/dev/null || { pkill named; named -c /etc/bind/named.conf -u named; }

# [PERINTAH/TESTING] >>> dijalankan di: prab
#!/bin/sh
# /root/soal8.sh

CONF=/etc/bind/named.conf

i=0
while [ $i -lt 120 ]; do
    pgrep -x named >/dev/null 2>&1 && [ -f "$CONF" ] && break
    i=$((i+1))
    sleep 1
done

grep -q 'in-addr.arpa' "$CONF" && exit 0

cat >> "$CONF" <<'EOF'

zone "1.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.1";
};

zone "2.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.2";
};

zone "3.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.3";
};
EOF

rndc reload 2>/dev/null || { pkill named; named -c /etc/bind/named.conf -u named; }

# [KONFIGURASI] >>> dijalankan di: prab
# prab
    post-up nohup sh /root/soal8.sh >/tmp/soal8.log 2>&1 &

# tedd
    post-up nohup sh /root/soal8.sh >/tmp/soal8.log 2>&1 &
