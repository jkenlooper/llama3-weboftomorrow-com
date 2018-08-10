#!/usr/bin/env bash
set -eu -o pipefail

# Run as root to set up a new ubuntu 16.04 server
# https://www.digitalocean.com/community/tutorials/initial-server-setup-with-ubuntu-16-04

apt-get --yes update
apt-get --yes upgrade

apt-get --yes install ssh

ufw allow ssh

# Limit multiple ssh connection attempts
ufw limit ssh/tcp

ufw allow 80/tcp
ufw allow 443/tcp
ufw show added
ufw enable


## Create the dev user
adduser dev

# Set the user to have sudo privileges by placing in the sudo group
usermod -aG sudo dev

# Add your public key (id_rsa.pub)
su --command "mkdir ~/.ssh && chmod 700 ~/.ssh" dev
su --command "read -p \"Paste in your .ssh/id_rsa.pub key: \" PUBLICKEY && echo \$PUBLICKEY > ~/.ssh/authorized_keys" dev
su --command "chmod 600 ~/.ssh/authorized_keys" dev

# Disable password authentication for ssh and only use public keys
sed --in-place "s/^PasswordAuthentication yes$/PasswordAuthentication no/" /etc/ssh/sshd_config
systemctl reload sshd

# Update /etc/hosts with web, api, stats
#echo "127.0.1.1  web" >> /etc/hosts
#echo "127.0.1.1  api" >> /etc/hosts
#echo "127.0.1.1  chill" >> /etc/hosts


# Create file hierarchies
mkdir -p /usr/local/src/llama3-weboftomorrow-com/
chown -R dev:dev /usr/local/src/llama3-weboftomorrow-com/

mkdir -p /var/lib/llama3-weboftomorrow-com/sqlite3/
chown -R dev:dev /var/lib/llama3-weboftomorrow-com/sqlite3/

mkdir -p /srv/llama3-weboftomorrow-com/root
chown -R dev:dev /srv/llama3-weboftomorrow-com/root

mkdir -p /var/log/nginx/llama3-weboftomorrow-com

mkdir -p /var/log/awstats


rm -f /etc/nginx/sites-enabled/default

touch /etc/nginx/sites-available/llama3-weboftomorrow-com.conf
chown dev:dev /etc/nginx/sites-available/llama3-weboftomorrow-com.conf
ln -s /etc/nginx/sites-available/llama3-weboftomorrow-com.conf /etc/nginx/sites-enabled/llama3-weboftomorrow-com.conf
chown -R dev:dev /etc/nginx/sites-available

mkdir -p /etc/nginx/snippets/
chown -R dev:dev /etc/nginx/snippets

mkdir -p /etc/nginx/ssl/
chown -R dev:dev /etc/nginx/ssl