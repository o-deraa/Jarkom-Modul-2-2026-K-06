# ============================================================
# SOAL 17 - TXT Record untuk Client (Alpha-Epsilon)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== Apa itu TXT record? =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 alpha.k06.com TXT

# ===== Command yang Dieksekusi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
vi /etc/bind/zones/k06.com.db

# [PERINTAH/TESTING] >>> dijalankan di: prab
/usr/bin/named-checkzone k06.com /etc/bind/zones/k06.com.db

# ===== Evidence Utama Soal 17 =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 alpha.k06.com TXT

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 beta.k06.com TXT

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 gamma.k06.com TXT

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 delta.k06.com TXT

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 epsilon.k06.com TXT
