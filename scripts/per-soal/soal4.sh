# ============================================================
# SOAL 4 - DNS Authoritative (Master di prab, Slave di tedd)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== Konfigurasi di prab (Master) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
#!/bin/sh
# /root/soal4.sh - prab (DNS Master untuk zona k06.com)

# Berhenti kalau named sudah jalan (hindari install/start ganda)
pgrep -x named >/dev/null 2>&1 && exit 0

# Tunggu koneksi internet siap (NAT rootkit), karena apk butuh akses mirror.
i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install BIND9
apk update
apk add bind bind-tools

# 2. named.conf (options + zone master)
cat > /etc/bind/named.conf <<'EOF'
options {
    directory "/var/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

zone "k06.com" {
    type master;
    file "/etc/bind/zones/k06.com.db";
    notify yes;
    allow-transfer { 192.214.1.3; };
};
EOF

# 3. File zone
mkdir -p /etc/bind/zones
cat > /etc/bind/zones/k06.com.db <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@               IN      NS      prab.k06.com.
@               IN      NS      tedd.k06.com.

prab            IN      A       192.214.1.2
tedd            IN      A       192.214.1.3

@               IN      A       192.214.3.2
EOF

# 4. Kepemilikan + start
chown -R named:named /etc/bind/zones
named -c /etc/bind/named.conf -u named

# [KONFIGURASI] >>> dijalankan di: prab
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up printf "nameserver 192.214.1.2\nnameserver 192.214.1.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
    post-up nohup sh /root/soal4.sh >/tmp/soal4.log 2>&1 &

# ===== Verifikasi Master =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
ps aux | grep [n]amed
dig @127.0.0.1 k06.com +short
dig @127.0.0.1 prab.k06.com +short
dig @127.0.0.1 tedd.k06.com +short

# ===== Konfigurasi di tedd (Slave) =====
# [PERINTAH/TESTING] >>> dijalankan di: tedd
#!/bin/sh
# /root/soal4.sh - tedd (DNS Slave untuk zona k06.com)

pgrep -x named >/dev/null 2>&1 && exit 0

i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install BIND9
apk update
apk add bind bind-tools

# 2. named.conf (options + zone slave)
cat > /etc/bind/named.conf <<'EOF'
options {
    directory "/var/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

zone "k06.com" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/k06.com.db";
};
EOF

# 3. Direktori slave (writable oleh named untuk salinan zona)
mkdir -p /var/bind/slave
chown -R named:named /var/bind/slave

# 4. Start
named -c /etc/bind/named.conf -u named

# [KONFIGURASI] >>> dijalankan di: tedd
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1
    post-up printf "nameserver 192.214.1.2\nnameserver 192.214.1.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf
    post-up nohup sh /root/soal4.sh >/tmp/soal4.log 2>&1 &

# ===== Verifikasi Slave dan Zone Transfer =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
ps aux | grep [n]amed
ls -la /var/bind/slave/
dig @127.0.0.1 k06.com +short
dig @127.0.0.1 prab.k06.com +short
dig @127.0.0.1 tedd.k06.com +short

# ===== Penataan Ulang Resolver (Semua Host Non-Router) =====
# [KONFIGURASI] >>> dijalankan di: alpha
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1
    post-up printf "nameserver 192.214.1.2\nnameserver 192.214.1.3\nnameserver 192.168.122.1\n" > /etc/resolv.conf

# ===== Verifikasi Akhir dari Klien =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
cat /etc/resolv.conf
dig k06.com +short
dig prab.k06.com +short
dig tedd.k06.com +short
