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

# 2. named.conf (options + zone slave)
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
    type slave;
    masters { 192.214.1.2; };
    file "/var/bind/slave/k06.com.db";
};
EOF

# 3. Direktori slave (writable oleh named untuk salinan zona)
mkdir -p /var/bind/slave
chown -R named:named /var/bind/slave

# 4. Start
named -c /etc/bind/named.conf -u named
