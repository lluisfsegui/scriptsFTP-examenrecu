#!/bin/bash

# -----------------------------------------
# INSTAL·LACIÓ I CREACIÓ D'USUARIS
# -----------------------------------------

apt update
apt install -y vsftpd

# Crear grups
groupadd ftp_engabiats
groupadd ftp_noengabiats
groupadd ftp_permisos   # grup amb permisos de lectura/escriptura

# Crear usuaris i assignar-los als grups
useradd -m -s /bin/bash laracroft   -G ftp_engabiats
useradd -m -s /bin/bash link  -G ftp_engabiats
useradd -m -s /bin/bash ashketchum  -G ftp_noengabiats,ftp_permisos
useradd -m -s /bin/bash ratchel  -G ftp_noengabiats,ftp_permisos

echo "laracroft:12345678" | chpasswd
echo "link:12345678" | chpasswd
echo "ashketchum:12345678" | chpasswd
echo "ratchel:12345678" | chpasswd

# -----------------------------------------
# DIRECTORIS AMB PERMISOS
# -----------------------------------------

mkdir -p /srv/bentley/documents
mkdir -p /srv/bentley/backup

# Usuari anònim només lectura
chown -R ftp:ftp /srv/bentley/documents
chmod -R 755 /srv/bentley/documents

# Usuaris NO engabiats amb lectura i escriptura
chown -R root:ftp_permisos /srv/bentley/backup
chmod -R 775 /srv/bentley/backup

chown -R root:ftp_permisos /srv/bentley/documents
chmod -R 775 /srv/bentley/documents

# -----------------------------------------
# CONFIGURACIÓ VSFTPD
# -----------------------------------------

cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES

# -------------------------
# USUARI ANÒNIM
# -------------------------
anonymous_enable=YES
anon_root=/srv/bentley/documents
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO

# -------------------------
# USUARIS LOCALS
# -------------------------

# Engabiar usuaris locals per defecte
chroot_local_user=YES

# Llista d'usuaris NO engabiats
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

allow_writeable_chroot=YES
pam_service_name=vsftpd
EOF

# -----------------------------------------
# CREAR LLISTA D'USUARIS NO ENGABIATS
# -----------------------------------------

echo "ashketchum"  > /etc/vsftpd.chroot_list
echo "ratchel" >> /etc/vsftpd.chroot_list

# -----------------------------------------
# REINICIAR SERVEI
# -----------------------------------------

systemctl restart vsftpd
