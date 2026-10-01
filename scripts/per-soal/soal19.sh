# ============================================================
# SOAL 19 - CNAME outbound.k06.com ke http.badssl.com
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== Command yang Dieksekusi =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
vi /etc/bind/zones/k06.com.db

# [PERINTAH/TESTING] >>> dijalankan di: prab
named-checkzone k06.com /etc/bind/zones/k06.com.db

# [PERINTAH/TESTING] >>> dijalankan di: prab
rndc reload k06.com

# ===== Hasil Validasi CNAME =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
dig @127.0.0.1 outbound.k06.com CNAME +noall +answer

# ===== Evidence Utama Soal 19 =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
curl http://outbound.k06.com

# ===== Verifikasi terhadap Domain Eksternal =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
curl -v http://http.badssl.com

# ===== Verifikasi CNAME terhadap HTTP Host =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
curl http://outbound.k06.com

# [PERINTAH/TESTING] >>> dijalankan di: prab
curl http://outbound.k06.com -H "Host: http.badssl.com"

# ===== Analisis =====
# [PERINTAH/TESTING] >>> dijalankan di: prab
curl http://outbound.k06.com

# [PERINTAH/TESTING] >>> dijalankan di: prab
curl http://outbound.k06.com -H "Host: http.badssl.com"
