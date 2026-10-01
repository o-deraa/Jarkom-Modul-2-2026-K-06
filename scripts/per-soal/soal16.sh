# ============================================================
# SOAL 16 - Stress Test Gerbang dengan ApacheBench
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== Command yang Dieksekusi =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
apk add apache2-utils

# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -V

# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://www.k06.com/

# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://static.k06.com/

# ===== Hasil Benchmark `www.k06.com` =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://www.k06.com/

# ===== Hasil Benchmark `static.k06.com` =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://static.k06.com/

# ===== Evidence 1 — www.k06.com =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://www.k06.com/

# ===== Evidence 2 — static.k06.com =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
ab -n 250 -c 10 http://static.k06.com/
