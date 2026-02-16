#!/bin/bash

apt update
apt install -y vsftpd db-util

# -------------------------------
# PRIMERA PART: USUARIS VIRTUALS
# -------------------------------

# Crear fitxer de text amb usuaris i contrasenyes
cat > /etc/vsftpd_virtual_users.txt << EOF
gandalf
12345678
celeborn
12345678
radagast
12345678
peregrin
12345678
EOF

# Crear base de dades Berkeley
db_load -T -t hash -f /etc/vsftpd_virtual_users.txt /etc/vsftpd_virtual_users.db

# Permisos
chmod 600 /etc/vsftpd_virtual_users.db

# Crear directori per a cada usuari virtual
mkdir -p /var/ftp_virtual/gandalf
mkdir -p /var/ftp_virtual/celeborn
mkdir -p /var/ftp_virtual/radagast
mkdir -p /var/ftp_virtual/peregrin

chmod -R 755 /var/ftp_virtual

# -------------------------------
# SEGONA PART: DIRECTORI ANÒNIM
# -------------------------------

mkdir -p /var/erebor/anonim
chmod 755 /var/erebor/anonim

# -------------------------------
# TERCERA PART: CONFIGURACIÓ VSFTPD
# -------------------------------

cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES

# Usuaris virtuals
pam_service_name=vsftpd_virtual
guest_enable=YES
guest_username=ftp
virtual_use_local_privs=YES

# Directori base dels usuaris virtuals
user_sub_token=$USER
local_root=/var/ftp_virtual/$USER

# Engabiament
chroot_local_user=YES

# FTP anònim
anonymous_enable=YES
anon_root=/var/erebor/anonim
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
EOF

# -------------------------------
# PAM CONFIG
# -------------------------------

cat > /etc/pam.d/vsftpd_virtual << 'EOF'
auth required pam_userdb.so db=/etc/vsftpd_virtual_users
account required pam_userdb.so db=/etc/vsftpd_virtual_users
EOF

systemctl restart vsftpd
