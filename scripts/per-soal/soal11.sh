# ============================================================
# SOAL 11 - Reverse Proxy (Penny → Vault, Abbey → Core)
# Dokumentasi langkah (BUKAN untuk dieksekusi langsung).
# Tiap blok menandai node tempat perintah dijalankan.
# ============================================================

# ===== A. Penny sebagai Reverse Proxy ke Vault (Apache) =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
apk update
apk add apache2 apache2-proxy

# ===== 2. Konfigurasi Reverse Proxy =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
cat > /etc/apache2/conf.d/proxy-vault.conf <<'EOF'
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
LoadModule headers_module modules/mod_headers.so

<VirtualHost *:80>
    ServerName www.k06.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    <Proxy "balancer://vault">
        BalancerMember "http://192.214.1.11"
        BalancerMember "http://192.214.1.12"
    </Proxy>

    ProxyPass        "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"
</VirtualHost>
EOF

# ===== 3. Jalankan Apache =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
httpd -t
httpd

# ===== 1. Install Nginx =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
apk update
apk add nginx

# ===== 2. Konfigurasi Reverse Proxy =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
rm -f /etc/nginx/http.d/default.conf

cat > /etc/nginx/http.d/proxy-core.conf <<'EOF'
upstream core {
    server 192.214.1.21;
    server 192.214.1.22;
}

server {
    listen 80;
    server_name static.k06.com;

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
EOF

# ===== 3. Jalankan Nginx =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
nginx -t
nginx

# ===== C. Verifikasi =====
# [PERINTAH/TESTING] >>> dijalankan di: alpha
# Penny → vault (obladi/desmond)
curl http://www.k06.com/
curl http://www.k06.com/

# Abbey → core (oblada/molly)
curl http://static.k06.com/
curl http://static.k06.com/
curl http://static.k06.com/
curl http://static.k06.com/

# [PERINTAH/TESTING] >>> dijalankan di: oblada
tail -f /var/log/nginx/access.log

# ===== Script penny =====
# [PERINTAH/TESTING] >>> dijalankan di: penny
#!/bin/sh
# /root/soal11.sh - penny (Apache reverse proxy -> vault)

pgrep -x httpd >/dev/null 2>&1 && exit 0

i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

apk update
apk add apache2 apache2-proxy

cat > /etc/apache2/conf.d/proxy-vault.conf <<'CONF'
LoadModule proxy_module modules/mod_proxy.so
LoadModule proxy_http_module modules/mod_proxy_http.so
LoadModule proxy_balancer_module modules/mod_proxy_balancer.so
LoadModule lbmethod_byrequests_module modules/mod_lbmethod_byrequests.so
LoadModule headers_module modules/mod_headers.so

<VirtualHost *:80>
    ServerName www.k06.com

    ProxyPreserveHost On
    RequestHeader set X-Real-IP expr=%{REMOTE_ADDR}

    <Proxy "balancer://vault">
        BalancerMember "http://192.214.1.11"
        BalancerMember "http://192.214.1.12"
    </Proxy>

    ProxyPass        "/" "balancer://vault/"
    ProxyPassReverse "/" "balancer://vault/"
</VirtualHost>
CONF

httpd

# ===== Script abbey =====
# [PERINTAH/TESTING] >>> dijalankan di: abbey
#!/bin/sh
# /root/soal11.sh - abbey (Nginx reverse proxy -> core)

pgrep -x nginx >/dev/null 2>&1 && exit 0

i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

apk update
apk add nginx

rm -f /etc/nginx/http.d/default.conf
cat > /etc/nginx/http.d/proxy-core.conf <<'CONF'
upstream core {
    server 192.214.1.21;
    server 192.214.1.22;
}

server {
    listen 80;
    server_name static.k06.com;

    location / {
        proxy_pass http://core;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
CONF

nginx

# [KONFIGURASI] >>> dijalankan di: abbey
post-up sh /root/soal11.sh
