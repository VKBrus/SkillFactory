sudo apt update
sudo apt upgrade
sudo apt install  -y mc net-tools nano

sudo locale-gen ru_RU.UTF-8
sudo update-locale LANG=ru_RU.UTF-8 LC_TIME="ru_RU.UTF-8"
sudo timedatectl set-timezone Europe/Samara

sudo nano /etc/hosts
sudo hostnamectl set-hostname server1 



# ---- https://blog.sedicomm.com/2016/12/25/fail2ban-ustanovka-i-nastrojka/
# ---- https://blog.sedicomm.com/2019/10/23/kak-ustanovit-fail2ban-dlya-zashhity-ssh-na-centos-rhel-8/

sudo apt-get install fail2ban
#sudo apt-get install sendmail-bin sendmail

cd /etc/fail2ban
sudo cp /etc/fail2ban/jail.conf /etc/fail2ban/jail.local
sudo nano /etc/fail2ban/jail.local

sudo cp /etc/fail2ban/fail2ban.conf /etc/fail2ban/fail2ban.local
sudo nano /etc/fail2ban/fail2ban.local

sudo fail2ban-client status

sudo systemctl start fail2ban
sudo systemctl enable fail2ban

#systemctl start sendmail
#systemctl enable sendmail

# Проверка
sudo iptables -L
