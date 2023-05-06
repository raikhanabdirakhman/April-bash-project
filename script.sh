#!/bin/bash

# Please replace worker1,2 and 3 with your IPs and replcae my_name with your name

worker1="157.245.249.254"
worker2="157.245.243.69"
worker3="157.245.134.208"

my_name=adilet

#Step1 - donwload packages

yum install -y httpd tree wget epel-release vim

#Step2 - Dwonload and start docker

sudo yum install -y yum-utils
sudo yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
sudo yum install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin -y
sudo systemctl start docker
sudo systemctl enable docker

#Step3 - Create kaizen user

useradd kaizen

#Step4 - Create passwordless login

mkdir /home/kaizen/.ssh
ssh-keygen -t rsa -b 4096 -f /home/kaizen/.ssh/id_rsa -N ""
chown -R kaizen:kaizen /home/kaizen/.ssh
chmod 700 /home/kaizen/.ssh
chmod 600 /home/kaizen/.ssh/*

for ip in $worker1 $worker2 $worker3
do
   ssh-copy-id -i /home/kaizen/.ssh/id_rsa.pub root@$ip
done

ssh-keygen -t rsa -b 4096 -f .ssh/id_rsa -N ""
for ip in $worker1 $worker2 $worker3
do
   ssh-copy-id root@$ip
done

#Step5 - 

for user in $(awk '{print$1}' students.txt | awk 'NR != 1')
do
useradd $user
usermod -aG kaizen $user
done

useradd $my_name
usermod -aG docker $my_name

#Step6 - make selinux permissive

setenforce 0 
sed -i 's/^SELINUX=.*/SELINUX=permissive/g' /etc/selinux/config

#Step7 - add aliases

echo "alias mk=mkdir" >> ~/.bashrc
echo "alias k=kubectl" >> ~/.bashrc
echo "alias ti='terraform init'" >> ~/.bashrc

#Step8 - 


sort -k2 -r students.txt > sorted_students

grep Harvard students.txt > harvard_students

sed 's/Harvard/H/g;s/Cornell/C/g;s/MIT/M/g' students.txt > replaced_students


#Step9 - Change permission

chmod 765 students.txt

#Step 11 - Set cronjob

echo "0 0 * * 1 yum update -y" |  crontab -

#Step12 - Send puclic IP to /etc/hosts

public_ip=$(curl ifconfig.co)

echo "$public_ip my-domain.com" >> /etc/hosts

#Step 10 - PRint colors basewd on age


while read line; do
  name=$(echo $line | awk '{print $1}')
  age=$(echo $line | awk '{print $2}')
if [[ $name == "Name" ]]; then
        continue
    fi


  if [ $age -ge "20" ] && [ $age -le "25" ]; then
    color="Red"
  elif [ $age -ge "26" ] && [ $age -le "30" ]; then
    color="Yellow"
  elif [ $age -ge "31" ] && [ $age -le "35" ]; then
    color="Blue"
  else
    color="Unknow"
  fi
  echo "$name is $age years old: $color"
done < students.txt

