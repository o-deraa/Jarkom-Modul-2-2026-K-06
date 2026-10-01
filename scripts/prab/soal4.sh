#!/bin/sh

pgrep -x named >/dev/null 2>&1 && exit 0

i=0
while [ $i -lt 30 ]; do
    ping -c1 -W1 192.168.122.1 >/dev/null 2>&1 && break
    i=$((i+1))
    sleep 1
done

# 1. Install BIND9
apk update
apk add bind bind-tools

# 2. named.conf (options + zone master)
cat > /etc/bind/named.conf <<'EOF'
options {
    directory "/var/bind";

    forwarders {
        192.168.122.1;
    };

    allow-query { any; };
    auth-nxdomain no;
    listen-on { any; };
    listen-on-v6 { any; };
};

zone "k06.com" {
    type master;
    file "/etc/bind/zones/k06.com.db";
    notify yes;
    allow-transfer { 192.214.1.3; };
};
EOF

# 3. File zone
mkdir -p /etc/bind/zones
cat > /etc/bind/zones/k06.com.db <<'EOF'
$TTL    604800
@       IN      SOA     prab.k06.com. root.k06.com. (
                        2026100401 ; Serial
                        604800     ; Refresh
                        86400      ; Retry
                        2419200    ; Expire
                        604800 )   ; Negative Cache TTL

@               IN      NS      prab.k06.com.
@               IN      NS      tedd.k06.com.

prab            IN      A       192.214.1.2
tedd            IN      A       192.214.1.3

@               IN      A       192.214.3.2
EOF

# 4. Kepemilikan + start
chown -R named:named /etc/bind/zones
named -c /etc/bind/named.conf -u named
