#!/bin/bash

NETWORK=$1
METHOD=$2
debut_script=$(date +%s)

echo "Scan du réseau ${NETWORK} en cours avec la méthode ${METHOD}"
printf "\n"

debut_scan_ip=$(date +%s)
case "$METHOD" in
  "nmap")
    echo "Utilisation de nmap pour scanner le réseau..."
    nmap -sn -T5 -n --min-hostgroup 256 "${NETWORK}" -oG - | grep "Up$" | cut -d" " -f2 > /tmp/liste_ip
    ;;
  "netdiscover")
    echo "Utilisation de netdiscover pour scanner le réseau..."
    sudo netdiscover -r "${NETWORK}" | grep "^[0-9]" | awk '{print $1}' > /tmp/liste_ip
    ;;
  "arp-scan")
    echo "Utilisation de arp-scan pour scanner le réseau..."
    sudo arp-scan --localnet | grep "^[0-9]" | awk '{print $1}' > /tmp/liste_ip
    ;;
  *)
    echo "Méthode non reconnue. Utilisez 'nmap', 'netdiscover' ou 'arp-scan'."
    exit 1
    ;;
esac

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