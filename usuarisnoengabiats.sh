#!/bin/bash

apt update
apt install -y vsftpd

# Crear grupos
groupadd ftp_permisos
groupadd ftp_sin_permisos

# Crear usuarios y asignarlos a grupos
useradd -m -s /bin/bash gandalf   -G ftp_permisos
useradd -m -s /bin/bash celeborn  -G ftp_permisos
useradd -m -s /bin/bash radagast  -G ftp_sin_permisos
useradd -m -s /bin/bash peregrin  -G ftp_sin_permisos

echo "gandalf:12345678" | chpasswd
echo "celeborn:12345678" | chpasswd
echo "radagast:12345678" | chpasswd
echo "peregrin:12345678" | chpasswd

# -------------------------------
# SEGUNDA PARTE DEL EJERCICIO
# -------------------------------

# Crear el directorio /var/erebor/anonim
mkdir -p /var/erebor/anonim

# Asignar el grupo con permisos (gandalf y celeborn)
chown :ftp_permisos /var/erebor/anonim

# Dar permisos de lectura y escritura al grupo
chmod 770 /var/erebor/anonim

# -------------------------------
# TERCERA PARTE DEL EJERCICIO
# -------------------------------

# Habilitar usuarios anónimos y asignarles el directorio
cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES

# Usuarios NO engabiados
chroot_local_user=NO

# Habilitar usuarios anónimos
anonymous_enable=YES
anon_root=/var/erebor/anonim

# Seguridad básica para anónimos
anon_upload_enable=NO
anon_mkdir_write_enable=NO
anon_other_write_enable=NO
EOF

systemctl restart vsftpd
