# ============================================================
# SOAL 6 - Verifikasi Zone Transfer
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== 1 - Cek Serial SOA di prab (Master) =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 k06.com SOA +short

# ===== 2 - Cek Serial SOA di tedd (Slave) =====
# [PERINTAH/TESTING] >>> dijalankan di: tedd
dig @127.0.0.1 k06.com SOA +short

# ===== 3 - Bukti Salinan Zona di tedd =====
# [PERINTAH/TESTING] >>> dijalankan di: tedd
ls -la /var/bind/slave/

# ===== 4 - Verifikasi Konsistensi Record =====
# [PERINTAH/TESTING] >>> dijalankan di: prab dan tedd
# dari prab
dig @192.214.1.2 alpha.k06.com +short
dig @192.214.1.2 molly.k06.com +short

# dari tedd
dig @192.214.1.3 alpha.k06.com +short
dig @192.214.1.3 molly.k06.com +short
