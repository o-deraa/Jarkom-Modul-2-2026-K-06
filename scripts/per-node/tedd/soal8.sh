#!/bin/sh
# /root/soal8.sh - tedd (reverse zone slave)
# Menambahkan tiga reverse zone slave yang menarik dari prab (192.214.1.2).

CONF=/etc/bind/named.conf

i=0
while [ $i -lt 120 ]; do
    pgrep -x named >/dev/null 2>&1 && [ -f "$CONF" ] && break
    i=$((i+1))
    sleep 1
done

grep -q 'in-addr.arpa' "$CONF" && exit 0

cat >> "$CONF" <<'EOF'

zone "1.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.1";
};

zone "2.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.2";
};

zone "3.214.192.in-addr.arpa" {
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/db.192.214.3";
};
EOF

rndc reload 2>/dev/null || { pkill named; named -c /etc/bind/named.conf -u named; }
