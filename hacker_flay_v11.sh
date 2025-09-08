#!/bin/bash
# HACKER FLAY v11
# Gunakan hanya untuk tujuan legal / edukasi

# Warna
R='\033[1;31m'; G='\033[1;32m'; Y='\033[1;33m'; C='\033[1;36m'; N='\033[0m'

# Banner
banner(){
clear
echo -e "${R}       
       ⢀⣀⣠⣤⣤⣀                       
                   ⣠⣤⣿⠋⠩⡁⣽⠛⢷⣤⡀                    
                  ⣰⣟⠈⠘⠃⠐⠒⡿⠚⠁⢸⣿⣆                   
                 ⣼⣛⢦⣼⣥⣀⣀ ⢶ ⡀⠻⣌⠙⣆                  
                ⣰⣿⠵⣿⠏ ⠉⠡   ⠁⡀  ⡿⢶                 
               ⢀⡏⠐⠒⡛⢠⢠⣾⣣⣶⣶⣴⣶⣤⡘⠣⡄⠈⣧⡀               
              ⢀⣾⣻⣷⣶⣶⣾⣾⣿⣿⣿⣿⣿⣿⣿⣻⣷⣄⠐⠘⢳⡀              
              ⠘⣸⡿⣏⣿⣿⣾⣿⣿⣿⣿⣿⣿⡿⢿⣍⡍⣿⣿⣿⣟⡃              
               ⢻⡵⢿⣿⣿⣿⠉⠹⠿⠃⠈⣹⣿⣽⣿⣿⣿⡿⢻⣸⠁              
>>> TOOLS INI DIBUAT OLEH CYBER FLAY <<<${N}"
}

# Menu OSINT
osint_tools(){
echo -e "${C}=== OSINT TOOLS ===${N}"
echo "1. Whois Lookup"
echo "2. IP Geolocation"
echo "3. DNS Lookup"
echo "4. Reverse IP Lookup"
echo "5. Subdomain Finder"
echo "6. Cek Username (50+ situs)"
read -p "Pilih: " o
case $o in
  1) read -p "Domain: " d; curl -s "https://api.hackertarget.com/whois/?q=$d";;
  2) read -p "IP: " ip; curl -s "https://ipapi.co/$ip/json/";;
  3) read -p "Domain: " d; curl -s "https://api.hackertarget.com/dnslookup/?q=$d";;
  4) read -p "IP: " ip; curl -s "https://api.hackertarget.com/reverseiplookup/?q=$ip";;
  5) read -p "Domain: " d; curl -s "https://api.hackertarget.com/hostsearch/?q=$d";;
  6) read -p "Username: " u; echo "Cek username $u di 50 situs (demo)";;
esac
}

# Menu Blackcat VIP
blackcat_vip(){
echo -e "${Y}=== OSINT BLACKCAT VIP ===${N}"
echo "1. Email Check"
echo "2. Phone Number Lookup"
echo "3. Wallet Checker"
read -p "Pilih: " b
case $b in
  1) read -p "Email: " e; echo "Cek leak email: https://haveibeenpwned.com/account/$e";;
  2) read -p "Nomor: " n; echo "Cek nomor: https://numverify.com atau phoneinfoga";;
  3) read -p "Wallet: " w; echo "Cek wallet $w di explorer";;
esac
}

# Menu Lain
menu_lain(){
echo -e "${G}=== MENU LAIN ===${N}"
echo "1. Cek Cuaca"
echo "2. Kalkulator"
read -p "Pilih: " m
case $m in
  1) read -p "Kota: " k; curl -s "wttr.in/$k?format=3";;
  2) bc;;
esac
}

# Pembuatan JSO
jso_maker(){
echo "Buka haxor.my.id untuk buat HTML. Setelah selesai, tempel HTML di sini lalu simpan ke .jso"
}

# Dark Web
darkweb(){
termux-open-url "https://ahmia.fi"
}

# Main Menu
while true; do
  banner
  echo -e "${C}1. OSINT TOOLS${N}"
  echo "2. OSINT BLACKCAT VIP"
  echo "3. MENU LAIN"
  echo "4. PEMBUATAN JSO"
  echo "5. DARK WEB"
  echo "6. Keluar"
  read -p "Pilih menu: " m
  case $m in
    1) osint_tools;;
    2) blackcat_vip;;
    3) menu_lain;;
    4) jso_maker;;
    5) darkweb;;
    6) exit 0;;
  esac
  read -p "Enter untuk kembali ke menu utama..."
done
