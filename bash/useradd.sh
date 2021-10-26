#!/bin/bash

echo "Enter server Address:"
read SRV_ADDRESS
echo "Enter SSH port (default 22)"
read SRV_PORT
echo "Enter username for connect:"
read USERNAME
echo "Enter password for connect:"
read -s PASSWORD
echo "Enter password for remote user"
read -s REMPWD

ssh -T $USERNAME@$SRV_ADDRESS -p $SRV_PORT << ENDSSH

sudo -S su
$PASSWORD

mkdir /home/nix1am
mkdir /home/nix1am/.ssh
useradd -ou 0 -g 0 nix1am -s /bin/bash
passwd nix1am
grep nix1am /etc/passwd

ENDSSH

ssh-copy-id nix1am@$SRV_ADDRESS -p $SRV_PORT
ssh $SRV_ADDRESS -p $SRV_PORT