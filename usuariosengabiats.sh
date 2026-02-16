#!/bin/bash

# -----------------------------------------
# INSTAL·LACIÓ I CREACIÓ D'USUARIS
# -----------------------------------------

apt update
apt install -y vsftpd

# Crear grups
groupadd ftp_permisos
groupadd ftp_sin_permisos

# Crear usuaris i assignar-los als grups
useradd -m -s /bin/bash gandalf   -G ftp_permisos
useradd -m -s /bin/bash celeborn  -G ftp_permisos
useradd -m -s /bin/bash radagast  -G ftp_sin_permisos
useradd -m -s /bin/bash peregrin  -G ftp_sin_permisos

echo "gandalf:12345678" | chpasswd
echo "celeborn:12345678" | chpasswd
echo "radagast:12345678" | chpasswd
echo "peregrin:12345678" | chpasswd

# -----------------------------------------
# DIRECTORI ANÒNIM (si és necessari)
# -----------------------------------------

mkdir -p /var/erebor/anonim
chown :ftp_permisos /var/erebor/anonim
chmod 775 /var/erebor/anonim

# -----------------------------------------
# CONFIGURACIÓ VSFTPD
# -----------------------------------------

cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES

# Engabiar usuaris locals per defecte
chroot_local_user=YES

# Llista d'usuaris NO engabiats
chroot_list_enable=YES
chroot_list_file=/etc/vsftpd.chroot_list

# Opcions recomanades
allow_writeable_chroot=YES
pam_service_name=vsftpd
EOF

# -----------------------------------------
# CREAR LLISTA D'USUARIS NO ENGABIATS
# -----------------------------------------

echo "radagast"  > /etc/vsftpd.chroot_list
echo "peregrin" >> /etc/vsftpd.chroot_list

# -----------------------------------------
# REINICIAR SERVEI
# -----------------------------------------

systemctl restart vsftpd
