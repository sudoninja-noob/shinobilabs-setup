#!/bin/bash

echo "🔥 Setting up ShinobiLabs: Hidden Leaf Exploit VM 🔥"
echo "⚔️  Inspired by Naruto - A Vulnerable CTF Machine ⚔️"
sleep 2

# Update System
sudo apt update && sudo apt upgrade -y

# Install Required Services
echo "📌 Installing Services..."
sudo apt install -y vsftpd apache2 mysql-server samba tomcat9 nfs-kernel-server openssh-server telnetd postfix bind9 rpcbind rsh-server postgresql vnc4server x11-xserver-utils unrealircd

# Configure vsftpd (FTP Backdoor)
echo "🔓 Configuring FTP..."
echo "allow_anon = YES" | sudo tee -a /etc/vsftpd.conf
sudo systemctl restart vsftpd

# Configure SSH with Weak Credentials
echo "🔓 Setting Weak SSH Password..."
echo -e "ramen123\nramen123" | sudo passwd naruto

# Configure Samba Share
echo "📌 Setting up a Misconfigured Samba Share..."
sudo mkdir -p /srv/shinobi
echo "Secret Scrolls of Shinobi are here!" | sudo tee /srv/shinobi/hidden_scrolls.txt
sudo chmod 777 /srv/shinobi
sudo tee -a /etc/samba/smb.conf <<EOF
[ShinobiVillage]
path = /srv/shinobi
read only = No
guest ok = Yes
EOF
sudo systemctl restart smbd

# Setup Weak MySQL Credentials
echo "📌 Creating MySQL Database..."
sudo mysql -e "CREATE DATABASE academy;"
sudo mysql -e "CREATE USER 'sasuke'@'localhost' IDENTIFIED BY 'revenge';"
sudo mysql -e "GRANT ALL PRIVILEGES ON academy.* TO 'sasuke'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Apache Webserver + Vulnerable Login Page
echo "📌 Setting up Vulnerable Web Server..."
sudo mkdir -p /var/www/html/academy
sudo tee /var/www/html/academy/login.php <<EOF
<?php
\$conn = new mysqli('localhost', 'sasuke', 'revenge', 'academy');
if (\$_GET['user']) {
    \$query = "SELECT * FROM students WHERE name = '" . \$_GET['user'] . "'";
    \$result = \$conn->query(\$query);
}
?>
EOF
sudo systemctl restart apache2

# Vulnerable Tomcat Uploads
echo "📌 Setting up Apache Tomcat with RCE Vulnerability..."
sudo chmod 777 /var/lib/tomcat9/webapps
echo "<% out.println('Naruto Webshell Activated!'); %>" | sudo tee /var/lib/tomcat9/webapps/shell.jsp
sudo systemctl restart tomcat9

# Unreal IRC Backdoor
echo "📌 Enabling Hidden IRC Backdoor..."
sudo wget -qO /etc/unrealircd.conf https://raw.githubusercontent.com/yourgithubrepo/shinobilabs-setup/main/unrealircd.conf
sudo systemctl restart unrealircd

# Create a Flag for the Final Challenge
echo "🏆 Setting Up The Final Flag..."
echo "VulnHub{Hokage_Hacked}" | sudo tee /root/flag.txt
sudo chmod 600 /root/flag.txt

echo "🔥 ShinobiLabs is Ready! Reboot & Start Hacking! 🔥"
