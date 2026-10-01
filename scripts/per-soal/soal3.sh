# ============================================================
# SOAL 3 - Konfigurasi Routing Internal dan DNS Server
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# [KONFIGURASI] >>> dijalankan di: alpha
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1
    echo "nameserver 192.168.122.1" > /etc/resolv.conf
