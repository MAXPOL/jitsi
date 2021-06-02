#!/bin/bash

echo "Please eneter your domain name: "
read dns
echo "Plese enter master password: "
read masterpass

apt update -y

apt install certbot nano wget gnupg gnupg1 gnupg2 -y

ufw allow 80/tcp
ufw allow 443/tcp
ufw allow 4443/tcp
ufw allow 10000/udp

cd /
wget https://download.jitsi.org/jitsi-key.gpg.key
apt-key add jitsi-key.gpg.key

echo 'deb https://download.jitsi.org stable/' >> /etc/apt/sources.list.d/jitsi-stable.list

apt update -y
apt install jitsi-meet -y

/usr/share/jitsi-meet/scripts/install-letsencrypt-cert.sh

sed -i 's/authentication = "anonymous"/authentication = "internal_plain"/' /etc/prosody/conf.avail/$dns.cfg.lua

echo "VirtualHost \"guest.$dns\"" >>  /etc/prosody/conf.avail/$dns.cfg.lua
echo "authentication = \"anonymous\"" >>  /etc/prosody/conf.avail/$dns.cfg.lua
echo "c2s_require_encryption = false" >>  /etc/prosody/conf.avail/$dns.cfg.lua

sed -i 's/\/\/ anonymousdomain: 'guest.example.com'/anonymousdomain: 'guest.$dns'/' /etc/jitsi/meet/$dns-config.js

echo "org.jitsi.jicofo.auth.URL=XMPP:$dns" >> /etc/jitsi/jicofo/sip-communicator.properties

prosodyctl register root $dns $masterpass

systemctl restart prosody.service
systemctl restart jicofo.service
systemctl restart jitsi-videobridge2.service

echo "GO in $dsn for create conference login = root and password = $masterpass"