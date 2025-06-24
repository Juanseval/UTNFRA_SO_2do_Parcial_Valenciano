#!/bin/bash

sudo fdisk /dev/sde << EOF
n
p
1

+512M
t
1
82
n
p
2


t
2
8e
w
EOF
sudo partprobe

sudo fdisk /dev/sdc << EOF
n
p
1

+2G
n
p
2


t
1
8e
t
2
8e
w
EOF
sudo partprobe

sudo fdisk /dev/sdd << EOF
n
p
1


t
1
8e
w
EOF
sudo partprobe


sudo pvcreate /dev/sdc1 /dev/sdc2 /dev/sde2 /dev/sdd1
sudo pvs
sudo vgcreate vg_temp /dev/sdc1
sudo vgcreate vg_datos /dev/sdc2 /dev/sdd1 /dev/sde2
sudo vgs


sudo lvcreate -L +700M vg_datos -n lv_docker
sudo lvcreate -l +100%FREE vg_datos -n lv_multimedia
sudo lvcreate -l +100%FREE vg_temp -n lv_swap


sudo mkfs.ext4 /dev/mapper/vg_datos-lv_docker
sudo mkfs.ext4 /dev/mapper/vg_datos-lv_multimedia
sudo mkswap /dev/sde1             
sudo mkswap /dev/mapper/vg_temp-lv_swap


sudo mkdir -p /Multimedia
sudo mount /dev/mapper/vg_datos-lv_docker /var/lib/docker/
sudo mount /dev/mapper/vg_datos-lv_multimedia /Multimedia
sudo swapon /dev/sde1
sudo swapon /dev/mapper/vg_temp-lv_swap

sudo systemctl restart docker
sudo systemctl status docker

echo "/dev/mapper/vg_datos-lv_docker    /var/lib/docker ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_datos-lv_multimedia /Multimedia     ext4 defaults 0 2" | sudo tee -a /etc/fstab
echo "/dev/mapper/vg_temp-lv_swap        none             swap sw       0 0" | sudo tee -a /etc/fstab
echo "/dev/sde1                          none             swap sw       0 0" | sudo tee -a /etc/fstab

