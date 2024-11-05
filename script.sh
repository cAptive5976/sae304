#!/bin/bash

NETWORK=$1
debut_script=$(date +%s)

echo "Scan du réseau ${NETWORK} en cours"
printf "\n"

debut_scan_ip=$(date +%s)
nmap -sn -T5 -n --min-hostgroup 256 "${NETWORK}" -oG - | grep "Up$" | cut -d" " -f2 > /tmp/liste_ip
fin_scan_ip=$(date +%s)

echo "Temps de scan du réseau : $((fin_scan_ip - debut_scan_ip))s"
printf "\n"
echo "Liste des hotes disponibles du réseau : "
echo $(cat /tmp/liste_ip)
printf "\n"

debut_scan_port=$(date +%s)
cat /dev/null > /tmp/liste_ports
for ligne in $(cat "/tmp/liste_ip")
do
    nmap -T5 -p- --host-timeout 5s -oG - "${ligne}" | grep "/open/" >> /tmp/liste_ports
done
fin_scan_port=$(date +%s)
echo "Temps de scan des ports : $((fin_scan_port - debut_scan_port))s"

printf "\n"
echo "Liste des hotes avec leurs ports ouverts : "
echo $(cat /tmp/liste_ports)

fin_script=$(date +%s)

printf "\n"
echo "Temps total d'execution du script : $((fin_script- debut_script))s"