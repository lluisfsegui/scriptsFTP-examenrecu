#!/bin/bash

###############################################
# PART 1 — INSTAL·LACIÓ DE VSFTPD I FREERADIUS
###############################################

apt update -y
apt install -y vsftpd freeradius libpam-radius-auth

systemctl enable vsftpd
systemctl enable freeradius

###############################################
# PART 2 — CONFIGURACIÓ DEL CLIENT RADIUS
###############################################

cat > /etc/freeradius/3.0/clients.conf << EOF
client localhost {
    ipaddr = 127.0.0.1
    secret = quartapart
}
EOF

###############################################
# PART 3 — CREACIÓ D’USUARIS RADIUS
###############################################

cat > /etc/freeradius/3.0/users << EOF
# --- Usuaris només lectura ---
user_lectura1 Cleartext-Password := "password1"
user_lectura2 Cleartext-Password := "password2"
user_lectura3 Cleartext-Password := "password3"

# --- Usuaris lectura i escriptura ---
user_escriptura1 Cleartext-Password := "password4"
user_escriptura2 Cleartext-Password := "password5"
user_escriptura3 Cleartext-Password := "password6"
EOF

systemctl restart freeradius

###############################################
# PART 4 — CONFIGURACIÓ PAM PER VSFTPD
###############################################

cat > /etc/pam_radius_auth.conf << EOF
127.0.0.1    quartapart    5
EOF

chmod 600 /etc/pam_radius_auth.conf

cat > /etc/pam.d/vsftpd << EOF
auth    required    pam_radius_auth.so
account required    pam_radius_auth.so
EOF

###############################################
# PART 5 — DIRECTORIS PER ALS USUARIS RADIUS
###############################################

mkdir -p /home/ftpvirtual

# Usuaris només lectura
mkdir -p /home/ftpvirtual/user_lectura1/files
mkdir -p /home/ftpvirtual/user_lectura2/files
mkdir -p /home/ftpvirtual/user_lectura3/files

# Usuaris lectura + escriptura
mkdir -p /home/ftpvirtual/user_escriptura1/files
mkdir -p /home/ftpvirtual/user_escriptura2/files
mkdir -p /home/ftpvirtual/user_escriptura3/files

chmod -R 755 /home/ftpvirtual

###############################################
# PART 6 — CONFIGURACIÓ INDIVIDUAL D’USUARIS
###############################################

mkdir -p /etc/vsftpd/users_config

# Usuaris només lectura
cat > /etc/vsftpd/users_config/user_lectura1 << EOF
local_root=/home/ftpvirtual/user_lectura1/files
anon_upload_enable=NO
write_enable=NO
EOF

cat > /etc/vsftpd/users_config/user_lectura2 << EOF
local_root=/home/ftpvirtual/user_lectura2/files
anon_upload_enable=NO
write_enable=NO
EOF

cat > /etc/vsftpd/users_config/user_lectura3 << EOF
local_root=/home/ftpvirtual/user_lectura3/files
anon_upload_enable=NO
write_enable=NO
EOF

# Usuaris lectura + escriptura
cat > /etc/vsftpd/users_config/user_escriptura1 << EOF
local_root=/home/ftpvirtual/user_escriptura1/files
write_enable=YES
virtual_use_local_privs=YES
EOF

cat > /etc/vsftpd/users_config/user_escriptura2 << EOF
local_root=/home/ftpvirtual/user_escriptura2/files
write_enable=YES
virtual_use_local_privs=YES
EOF

cat > /etc/vsftpd/users_config/user_escriptura3 << EOF
local_root=/home/ftpvirtual/user_escriptura3/files
write_enable=YES
virtual_use_local_privs=YES
EOF

###############################################
# PART 7 — CONFIGURACIÓ VSFTPD
###############################################

cat > /etc/vsftpd.conf << EOF
listen=YES
listen_ipv6=NO

anonymous_enable=NO
local_enable=YES
write_enable=YES

pam_service_name=vsftpd

guest_enable=YES
guest_username=ftp
user_config_dir=/etc/vsftpd/users_config

allow_writeable_chroot=YES
secure_chroot_dir=/var/run/vsftpd/empty
EOF

###############################################
# PART 8 — REINICIAR SERVEIS
###############################################

systemctl restart freeradius
systemctl restart vsftpd

echo "FTP amb usuaris RADIUS configurat correctament."
