# ============================================================
# SOAL 1 - Topologi The Mesh
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== rootkit (router) =====
# [KONFIGURASI] >>> dijalankan di: rootkit
auto eth1
iface eth1 inet static
    address 192.214.1.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 192.214.2.1
    netmask 255.255.255.0

auto eth3
iface eth3 inet static
    address 192.214.3.1
    netmask 255.255.255.0

auto eth4
iface eth4 inet static
    address 192.214.4.1
    netmask 255.255.255.0

auto eth5
iface eth5 inet static
    address 192.214.5.1
    netmask 255.255.255.0
    post-up echo 1 > /proc/sys/net/ipv4/ip_forward

# ===== alpha =====
# [KONFIGURASI] >>> dijalankan di: alpha
auto eth0
iface eth0 inet static
    address 192.214.4.2
    netmask 255.255.255.0
    gateway 192.214.4.1

# ===== beta =====
# [KONFIGURASI] >>> dijalankan di: beta
auto eth0
iface eth0 inet static
    address 192.214.4.3
    netmask 255.255.255.0
    gateway 192.214.4.1

# ===== gamma =====
# [KONFIGURASI] >>> dijalankan di: gamma
auto eth0
iface eth0 inet static
    address 192.214.4.4
    netmask 255.255.255.0
    gateway 192.214.4.1

# ===== delta =====
# [KONFIGURASI] >>> dijalankan di: delta
auto eth0
iface eth0 inet static
    address 192.214.5.2
    netmask 255.255.255.0
    gateway 192.214.5.1

# ===== epsilon =====
# [KONFIGURASI] >>> dijalankan di: epsilon
auto eth0
iface eth0 inet static
    address 192.214.5.3
    netmask 255.255.255.0
    gateway 192.214.5.1

# ===== abbey =====
# [KONFIGURASI] >>> dijalankan di: abbey
auto eth0
iface eth0 inet static
    address 192.214.2.2
    netmask 255.255.255.0
    gateway 192.214.2.1

# ===== penny =====
# [KONFIGURASI] >>> dijalankan di: penny
auto eth0
iface eth0 inet static
    address 192.214.3.2
    netmask 255.255.255.0
    gateway 192.214.3.1

# ===== prab =====
# [KONFIGURASI] >>> dijalankan di: prab
auto eth0
iface eth0 inet static
    address 192.214.1.2
    netmask 255.255.255.0
    gateway 192.214.1.1

# ===== tedd =====
# [KONFIGURASI] >>> dijalankan di: tedd
auto eth0
iface eth0 inet static
    address 192.214.1.3
    netmask 255.255.255.0
    gateway 192.214.1.1

# ===== obladi =====
# [KONFIGURASI] >>> dijalankan di: obladi
auto eth0
iface eth0 inet static
    address 192.214.1.11
    netmask 255.255.255.0
    gateway 192.214.1.1

# ===== desmond =====
# [KONFIGURASI] >>> dijalankan di: desmond
auto eth0
iface eth0 inet static
    address 192.214.1.12
    netmask 255.255.255.0
    gateway 192.214.1.1

# ===== oblada =====
# [KONFIGURASI] >>> dijalankan di: oblada
auto eth0
iface eth0 inet static
    address 192.214.1.21
    netmask 255.255.255.0
    gateway 192.214.1.1

# ===== molly =====
# [KONFIGURASI] >>> dijalankan di: molly
auto eth0
iface eth0 inet static
    address 192.214.1.22
    netmask 255.255.255.0
    gateway 192.214.1.1
