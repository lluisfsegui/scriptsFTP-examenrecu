#!/bin/bash

apt update
apt install -y vsftpd

# Crear usuarios (4 líneas, fácil de cambiar)
useradd -m -s /bin/bash gandalf
useradd -m -s /bin/bash celeborn
useradd -m -s /bin/bash radagast
useradd -m -s /bin/bash peregrin

echo "gandalf:1234" | chpasswd
echo "celeborn:1234" | chpasswd
echo "radagast:1234" | chpasswd
echo "peregrin:1234" | chpasswd

# Configuración FTP con usuarios ENGABIADOS
cp /etc/vsftpd.conf /etc/vsftpd.conf.bak

cat > /etc/vsftpd.conf << 'EOF'
listen=YES
local_enable=YES
write_enable=YES
anonymous_enable=NO

# Usuarios engabiados
chroot_local_user=YES
allow_writeable_chroot=YES
EOF

systemctl restart vsftpd
systemctl  status vsftpd
