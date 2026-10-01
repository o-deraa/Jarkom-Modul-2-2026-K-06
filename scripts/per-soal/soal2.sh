# ============================================================
# SOAL 2 - Jalur NAT The Mesh
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# [KONFIGURASI] >>> dijalankan di: rootkit
auto eth0
iface eth0 inet dhcp

# [PERINTAH/TESTING] >>> dijalankan di: rootkit
echo 1 > /proc/sys/net/ipv4/ip_forward

# [PERINTAH/TESTING] >>> dijalankan di: rootkit
iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE

# [PERINTAH/TESTING] >>> dijalankan di: rootkit
#!/bin/sh
echo 1 > /proc/sys/net/ipv4/ip_forward
iptables -t nat -C POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE 2>/dev/null || \
iptables -t nat -A POSTROUTING -o eth0 -s 192.214.0.0/16 -j MASQUERADE
