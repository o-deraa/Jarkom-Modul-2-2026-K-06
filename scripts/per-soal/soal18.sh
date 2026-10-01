# ============================================================
# SOAL 18 - Perubahan A Record abbey dengan TTL 15 Detik
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== Apa itu A record? =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 abbey.k06.com A

# ===== Command yang Dieksekusi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
vi /etc/bind/zones/k06.com.db

# [PERINTAH/TESTING] >>> dijalankan di: prab
/usr/bin/named-checkzone k06.com /etc/bind/zones/k06.com.db

# [PERINTAH/TESTING] >>> dijalankan di: prab
rndc reload k06.com

# ===== Fase 2 — Selama TTL Belum Expired =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 -p 5353 abbey.k06.com A +noall +answer

# ===== Fase 3 — Setelah TTL Expired =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
sleep 16

# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 -p 5353 abbey.k06.com A +noall +answer

# ===== Verifikasi Sinkronisasi TEDD =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @192.214.1.3 abbey.k06.com A +noall +answer
