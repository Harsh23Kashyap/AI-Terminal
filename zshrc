# =============================================================================
# ENHANCED COLORFUL ZSHRC FOR MACOS - HARSH'S CONFIGURATION
# =============================================================================
# Game-changing ZSH behavior
setopt AUTO_CD                    # Just type "Documents" to cd into it
setopt CORRECT                    # Auto-correct typos: "gti status" → "git status"
setopt GLOBDOTS                   # Include hidden files in tab completion
setopt EXTENDED_GLOB              # Advanced pattern matching: **/*.js
setopt AUTO_PUSHD                 # Auto-save directory history
setopt PUSHD_IGNORE_DUPS         # No duplicate dirs in history

# Super useful for navigation
alias d='dirs -v'                 # Show directory stack with numbers
alias 1='cd -1'                   # Jump to recent directories by number
alias 2='cd -2'
alias 3='cd -3'
# -----------------------------------------------------------------------------
# Environment Setup
# -----------------------------------------------------------------------------
export PATH=/Users/{username}/package/perl-5.38.2/:$PATH:.
export LC_CTYPE="en_US.UTF-8"
export PATH=$HOME/.gem/bin:$PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
export PATH=$HOME/development/flutter/bin:$PATH
export OPENAI_API_KEY="***REMOVED***"

# Enable colors
export CLICOLOR=1
export LSCOLORS=ExFxBxegedabagacad

# -----------------------------------------------------------------------------
# AUTO-INSTALL MISSING TOOLS
# -----------------------------------------------------------------------------
# Function to check and install missing tools
check_and_install_tools() {
    local tools_to_check=(
        "bat:bat --version"
        "eza:eza --version" 
        "fd:fd --version"
        "rg:rg --version"
        "tree:tree --version"
        "htop:htop --version"
        "fzf:fzf --version"
        "qrencode:qrencode --version"
    )
    
    local missing_tools=()
    local installed_tools=()
    
    echo "🔍 Checking for enhanced tools..."
    
    for tool_info in "${tools_to_check[@]}"; do
        local tool_name=$(echo "$tool_info" | cut -d: -f1)
        local check_command=$(echo "$tool_info" | cut -d: -f2)
        
        if command -v "$tool_name" &> /dev/null; then
            installed_tools+=("$tool_name")
        else
            missing_tools+=("$tool_name")
        fi
    done
    
    # Show status
    if [ ${#installed_tools[@]} -gt 0 ]; then
        echo "✅ Installed: ${installed_tools[*]}"
    fi
    
    if [ ${#missing_tools[@]} -gt 0 ]; then
        echo "❌ Missing: ${missing_tools[*]}"
        echo ""
        echo "🚀 Would you like to install missing tools? (y/n)"
        read -q "REPLY?Install missing tools? "
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo "📦 Installing missing tools via Homebrew..."
            
            # Check if Homebrew is installed
            if ! command -v brew &> /dev/null; then
                echo "❌ Homebrew not found. Installing Homebrew first..."
                /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
                
                # Add Homebrew to PATH for Apple Silicon Macs
                if [[ $(uname -m) == "arm64" ]]; then
                    echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
                    eval "$(/opt/homebrew/bin/brew shellenv)"
                fi
            fi
            
            # Install missing tools
            for tool in "${missing_tools[@]}"; do
                echo "📦 Installing $tool..."
                case "$tool" in
                    "bat") brew install bat ;;
                    "eza") brew install eza ;;
                    "fd") brew install fd ;;
                    "rg") brew install ripgrep ;;
                    "tree") brew install tree ;;
                    "htop") brew install htop ;;
                    "fzf") brew install fzf ;;
                    "qrencode") brew install qrencode ;;
                esac
            done
            
            echo "✅ Installation complete! Reloading zshrc to enable enhanced features..."
            echo ""
            
            # Enable enhanced aliases after installation
            enable_enhanced_aliases
            
        else
            echo "⏭️  Skipping installation. You can install manually later with:"
            echo "   brew install ${missing_tools[*]}"
        fi
    else
        echo "🎉 All enhanced tools are already installed!"
        enable_enhanced_aliases
    fi
}

# Function to enable enhanced aliases after tools are installed
enable_enhanced_aliases() {
    # Check if tools are available and enable aliases
    if command -v bat &> /dev/null; then
        alias cat='bat --style=numbers,changes --color=always 2>/dev/null || cat'
    fi
    
    if command -v eza &> /dev/null; then
        alias ls='eza --color=always --group-directories-first'
        alias ll='eza -la --color=always --group-directories-first'
        alias exa='eza'
    fi
    
    if command -v fd &> /dev/null; then
        alias find='fd'
    fi
    
    if command -v rg &> /dev/null; then
        alias grep='rg'
    fi
    
    if command -v fzf &> /dev/null; then
        # Initialize fzf if available
        [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh
    fi
}

# Run the check (only on interactive shells)
if [[ $- == *i* ]]; then
    check_and_install_tools
fi

# -----------------------------------------------------------------------------
# ZSH CONFIGURATION & COLORS
# -----------------------------------------------------------------------------
# Enable colors in terminal
autoload -U colors && colors

# History configuration
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_DUPS
setopt HIST_IGNORE_SPACE
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Auto-completion
autoload -U compinit
compinit

# Case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Colored completion menu
zstyle ':completion:*' menu select
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# -----------------------------------------------------------------------------
# CUSTOM COLORFUL PROMPT (NO TIME)
# -----------------------------------------------------------------------------
# Git branch function for prompt
git_branch() {
    git branch 2> /dev/null | sed -e '/^[^*]/d' -e 's/* \(.*\)/(\1)/'
}

# Custom prompt with colors (no time)
setopt PROMPT_SUBST
PROMPT='%{$fg[yellow]%}%n%{$fg[green]%}@%{$fg[blue]%}%m %{$fg[red]%}%~ %{$fg[cyan]%}%% %{$reset_color%}'


# -----------------------------------------------------------------------------
# ORIGINAL ALIASES WITH COLORS
# -----------------------------------------------------------------------------

# Copy file content to clipboard
alias cpcontent='pbcopy <'
alias down="cd /Users/harshkashyap/Downloads"
# Copy absolute path to clipboard
alias cppath='realpath | pbcopy'
alias xcode="xcode-select -p"

# Additional clipboard utilities
alias paste='pbpaste'
alias finder="open ."
alias preview="open -a Preview"

# -----------------------------------------------------------------------------
# ENHANCED NAVIGATION & FILES WITH COLORS
# -----------------------------------------------------------------------------
# Enhanced ls with colors
alias ls='ls -G'
alias ll='ls -alFG'
alias la='ls -AG'
alias l='ls -CFG'
alias lh='ls -lhG'
alias lt='ls -ltG'
alias ltr='ls -ltrG'
alias lsize='ls -lhSG'

# Navigation
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias ~='cd ~'
alias -- -='cd -'

# Custom workspace
alias workspace='cd /Users/{username}/workspace'
alias ws='cd /Users/{username}/workspace'

# Quick directory jumps with colors
alias desktop='cd ~/Desktop && ls -G'
alias documents='cd ~/Documents && ls -G'
alias downloads='cd ~/Downloads && ls -G'

# -----------------------------------------------------------------------------
# ENHANCED GIT ALIASES WITH COLORS
# -----------------------------------------------------------------------------
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gc='git commit -m'
alias gca='git commit --amend'
alias gco='git checkout'
alias gcb='git checkout -b'
alias gs='git status --short --branch'
alias gss='git status'
alias gd='git diff --color=always'
alias gds='git diff --staged --color=always'
alias gl='git log --oneline --graph --color=always'
alias gll='git log --graph --pretty=format:"%C(red)%h%C(reset) -%C(yellow)%d%C(reset) %s %C(green)(%cr) %C(bold blue)<%an>%C(reset)" --abbrev-commit'
alias gp='git push'
alias gpl='git pull'
alias gb='git branch --color=always'
alias gm='git merge'
alias gf='git fetch'
alias gst='git stash'
alias gstp='git stash pop'

# Enhanced git shortcuts
alias gundo='git reset HEAD~1 --mixed'
alias greset='git reset --hard HEAD'
alias gclean='git clean -fd'
alias gtree='git log --graph --pretty=oneline --abbrev-commit --all'

# -----------------------------------------------------------------------------
# ENHANCED VIM & TEXT EDITING
# -----------------------------------------------------------------------------
alias v='vim'
alias vi='vim'
alias nano='nano -c'
alias vimrc='vim ~/.vimrc'
alias zshrc='vim ~/.zshrc'

# Code viewing with syntax highlighting (requires bat: brew install bat)
alias cat='bat --style=numbers,changes --color=always 2>/dev/null || cat'
alias less='less -R' # Enable colors in less

# -----------------------------------------------------------------------------
# ENHANCED FILE OPERATIONS
# -----------------------------------------------------------------------------
alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'
alias mkdir='mkdir -pv'
alias rmdir='rmdir -v'

# File size and disk usage
alias sizes='du -sh * | sort -hr'
alias biggest='find . -type f -exec ls -la {} \; | sort -k 5 -rn | head -10'

# Tree with colors (install with: brew install tree)
alias tree='tree -C'

# -----------------------------------------------------------------------------
# ENHANCED SEARCH & FIND WITH COLORS
# -----------------------------------------------------------------------------
# Colorful grep
alias grep='grep --color=always'
alias fgrep='fgrep --color=always'
alias egrep='egrep --color=always'

alias h='history | grep --color=always'
alias hgrep='history | grep --color=always'
alias psg='ps aux | grep -v grep | grep --color=always'

# Enhanced find functions with colors
findfile() {
    find . -name "*$1*" -type f 2>/dev/null | grep --color=always "$1"
}

findin() {
    grep -r --color=always "$1" . --exclude-dir=.git
}

finddir() {
    find . -name "*$1*" -type d 2>/dev/null | grep --color=always "$1"
}

# -----------------------------------------------------------------------------
# ENHANCED SYSTEM MONITORING WITH COLORS
# -----------------------------------------------------------------------------
alias df='df -h | grep -E "^(/dev/|Filesystem)" | column -t'
alias du='du -h'
alias free='vm_stat | perl -ne "/page size of (\d+)/ and $size=$1; /Pages\s+([^:]+):\s+(\d+)/ and printf(\"%-16s % 16.2f Mi\n\", \"$1:\", $2 * $size / 1048576)"'
alias ports='netstat -tulanp | grep LISTEN'
alias reload='echo "🔄 Reloading zshrc..." && source ~/.zshrc && echo "✅ zshrc reloaded with auto-install check!"'
alias path='echo -e ${PATH//:/\\n} | nl'

# Process monitoring with colors
alias top='top -o cpu'
alias htop='sudo htop'
alias pscpu='ps aux --sort=-%cpu | head -10'
alias psmem='ps aux --sort=-%mem | head -10'

# System information
alias sysinfo='system_profiler SPSoftwareDataType SPHardwareDataType'
alias battery='pmset -g batt'
alias temp='sudo powermetrics --samplers smc -n 1 | grep -i temp'

# -----------------------------------------------------------------------------
# NETWORK & CONNECTIVITY
# -----------------------------------------------------------------------------
alias ping='ping -c 5'
alias myip='curl -s https://ipinfo.io/ip'
alias localip='ipconfig getifaddr en0'
alias wifi='networksetup -getairportnetwork en0'
alias speedtest='curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -'

# -----------------------------------------------------------------------------
# ENHANCED FUNCTIONS WITH COLORS
# -----------------------------------------------------------------------------
# Create directory and cd into it
mkcd() {
    mkdir -p "$1" && cd "$1" && echo "📁 Created and entered: $1"
}

# Extract various archive formats
extract() {
    if [ -f $1 ] ; then
        case $1 in
            *.tar.bz2)   tar xjf $1     ;;
            *.tar.gz)    tar xzf $1     ;;
            *.bz2)       bunzip2 $1     ;;
            *.rar)       unrar e $1     ;;
            *.gz)        gunzip $1      ;;
            *.tar)       tar xf $1      ;;
            *.tbz2)      tar xjf $1     ;;
            *.tgz)       tar xzf $1     ;;
            *.zip)       unzip $1       ;;
            *.Z)         uncompress $1  ;;
            *.7z)        7z x $1        ;;
            *)     echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Weather function
unalias weather 2>/dev/null
weather() {
    curl -s "wttr.in/$1?format=3"
}

# QR code generator (requires qrencode: brew install qrencode)
qr() {
    qrencode -t UTF8 "$1"
}

# Quick note taking
note() {
    echo "$(date): $*" >> ~/notes.txt
    echo "📝 Note added to ~/notes.txt"
}

viewnotes() {
    cat ~/notes.txt | tail -20
}

# Quick backup
backup() {
    cp "$1" "$1.backup.$(date +%Y%m%d_%H%M%S)"
    echo "💾 Backup created: $1.backup.$(date +%Y%m%d_%H%M%S)"
}

# -----------------------------------------------------------------------------
# PRODUCTIVITY ENHANCEMENTS
# -----------------------------------------------------------------------------
alias env='env | sort | grep --color=always'
alias aliases='alias | grep --color=always'

# Colorful diff
alias diff='diff --color=always'

# -----------------------------------------------------------------------------
# WELCOME MESSAGE
# -----------------------------------------------------------------------------
echo "📅 $(date)"
echo "💻 Welcome back, $(whoami)!"

# -----------------------------------------------------------------------------
# OPTIONAL ENHANCEMENTS (Install with Homebrew)
# -----------------------------------------------------------------------------
# brew install bat exa fd ripgrep fzf tree htop
# Then uncomment these enhanced versions:

# Enhanced aliases (uncomment when tools are installed)
# alias cat='bat --style=numbers,changes'
# alias ls='exa --color=always --group-directories-first'
# alias ll='exa -la --color=always --group-directories-first'
# alias find='fd'
# alias grep='rg'

# FZF integration (fuzzy finder)
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# -----------------------------------------------------------------------------
# GIT COLOR CONFIGURATION (Run these commands once)
# -----------------------------------------------------------------------------
# git config --global color.ui auto
# git config --global color.branch auto
# git config --global color.diff auto
# git config --global color.status auto
# -----------------------------------------------------------------------------
# ENHANCED PROCESS MANAGEMENT WITH COLORS
# -----------------------------------------------------------------------------

# View all processes with colors and search
processes() {
    if [ -z "$1" ]; then
        echo "🔍 All running processes:"
        ps aux | head -1  # Header
        ps aux | tail -n +2 | sort -k3 -nr | head -20 | grep --color=always ".*"
    else
        echo "🔍 Searching processes for: $1"
        ps aux | grep --color=always -i "$1" | grep -v grep
    fi
}

# Find process by port
port() {
    if [ -z "$1" ]; then
        echo "❌ Usage: port <port_number>"
        echo "📝 Example: port 3000"
        return 1
    fi
    
    echo "🔍 Finding process using port $1:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check different ways a port might be used
    lsof -i :$1 2>/dev/null | grep --color=always ".*" || echo "❌ No process found using port $1"
    
    echo ""
    echo "🌐 Network connections on port $1:"
    netstat -an | grep ":$1 " | grep --color=always ".*" || echo "❌ No network connections on port $1"
}

# Find process by name (supports partial matching)
pname() {
    if [ -z "$1" ]; then
        echo "❌ Usage: pname <process_name>"
        echo "📝 Example: pname chrome"
        return 1
    fi
    
    echo "🔍 Finding processes matching: $1"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Find by process name
    ps aux | grep --color=always -i "$1" | grep -v grep
    
    echo ""
    echo "🔍 Also checking pgrep:"
    pgrep -fl "$1" | grep --color=always ".*" || echo "❌ No processes found with pgrep"
}

# Kill process by PID with confirmation
kpid() {
    if [ -z "$1" ]; then
        echo "❌ Usage: kpid <pid>"
        echo "📝 Example: kpid 1234"
        return 1
    fi
    
    # Check if process exists
    if ! ps -p $1 > /dev/null 2>&1; then
        echo "❌ Process with PID $1 not found"
        return 1
    fi
    
    # Show process info
    echo "🔍 Process details:"
    ps -p $1 -o pid,ppid,user,command | grep --color=always ".*"
    
    echo ""
    read -q "REPLY?⚠️  Kill process $1? (y/n): "
    echo ""
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        kill $1 2>/dev/null && echo "✅ Process $1 killed successfully" || echo "❌ Failed to kill process $1"
    else
        echo "❌ Kill cancelled"
    fi
}

# Kill process by name with selection
kname() {
    if [ -z "$1" ]; then
        echo "❌ Usage: kname <process_name>"
        echo "📝 Example: kname chrome"
        return 1
    fi
    
    echo "🔍 Finding processes matching: $1"
    
    # Get matching processes
    local pids=($(pgrep -f "$1"))
    
    if [ ${#pids[@]} -eq 0 ]; then
        echo "❌ No processes found matching: $1"
        return 1
    fi
    
    echo "📋 Found ${#pids[@]} matching process(es):"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show all matching processes with numbers
    local i=1
    for pid in "${pids[@]}"; do
        echo "[$i] PID: $pid"
        ps -p $pid -o pid,ppid,user,command | tail -n +2 | grep --color=always ".*"
        echo ""
        ((i++))
    done
    
    echo "Options:"
    echo "  a) Kill ALL matching processes"
    echo "  1-${#pids[@]}) Kill specific process"
    echo "  q) Quit without killing"
    echo ""
    
    read "choice?Choose option: "
    
    case $choice in
        a|A)
            read -q "REPLY?⚠️  Kill ALL ${#pids[@]} processes? (y/n): "
            echo ""
            if [[ $REPLY =~ ^[Yy]$ ]]; then
                for pid in "${pids[@]}"; do
                    kill $pid 2>/dev/null && echo "✅ Killed PID: $pid" || echo "❌ Failed to kill PID: $pid"
                done
            else
                echo "❌ Kill cancelled"
            fi
            ;;
        [1-9]*)
            if [ $choice -gt 0 ] && [ $choice -le ${#pids[@]} ]; then
                local selected_pid=${pids[$choice]}
                read -q "REPLY?⚠️  Kill process $selected_pid? (y/n): "
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    kill $selected_pid 2>/dev/null && echo "✅ Process $selected_pid killed successfully" || echo "❌ Failed to kill process $selected_pid"
                else
                    echo "❌ Kill cancelled"
                fi
            else
                echo "❌ Invalid selection"
            fi
            ;;
        q|Q)
            echo "❌ Kill cancelled"
            ;;
        *)
            echo "❌ Invalid option"
            ;;
    esac
}

# Kill process by port
kport() {
    if [ -z "$1" ]; then
        echo "❌ Usage: kport <port_number>"
        echo "📝 Example: kport 3000"
        return 1
    fi
    
    echo "🔍 Finding processes using port $1:"
    
    # Get PIDs using the port
    local pids=($(lsof -ti :$1 2>/dev/null))
    
    if [ ${#pids[@]} -eq 0 ]; then
        echo "❌ No processes found using port $1"
        return 1
    fi
    
    echo "📋 Found ${#pids[@]} process(es) using port $1:"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Show process details
    for pid in "${pids[@]}"; do
        echo "PID: $pid"
        ps -p $pid -o pid,ppid,user,command | tail -n +2 | grep --color=always ".*"
        lsof -p $pid | grep ":$1" | grep --color=always ".*"
        echo ""
    done
    
    if [ ${#pids[@]} -eq 1 ]; then
        read -q "REPLY?⚠️  Kill process using port $1? (y/n): "
        echo ""
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill ${pids[1]} 2>/dev/null && echo "✅ Process killed successfully" || echo "❌ Failed to kill process"
        else
            echo "❌ Kill cancelled"
        fi
    else
        echo "Options:"
        echo "  a) Kill ALL processes using port $1"
        echo "  q) Quit without killing"
        echo ""
        
        read "choice?Choose option: "
        
        case $choice in
            a|A)
                read -q "REPLY?⚠️  Kill ALL ${#pids[@]} processes using port $1? (y/n): "
                echo ""
                if [[ $REPLY =~ ^[Yy]$ ]]; then
                    for pid in "${pids[@]}"; do
                        kill $pid 2>/dev/null && echo "✅ Killed PID: $pid" || echo "❌ Failed to kill PID: $pid"
                    done
                else
                    echo "❌ Kill cancelled"
                fi
                ;;
            q|Q)
                echo "❌ Kill cancelled"
                ;;
            *)
                echo "❌ Invalid option"
                ;;
        esac
    fi
}

# Force kill (SIGKILL) - use with caution
fkill() {
    if [ -z "$1" ]; then
        echo "❌ Usage: fkill <pid_or_name>"
        echo "📝 Example: fkill 1234 or fkill chrome"
        return 1
    fi
    
    # Check if it's a PID (number) or process name
    if [[ $1 =~ ^[0-9]+$ ]]; then
        # It's a PID
        if ! ps -p $1 > /dev/null 2>&1; then
            echo "❌ Process with PID $1 not found"
            return 1
        fi
        
        echo "🔍 Process details:"
        ps -p $1 -o pid,ppid,user,command | grep --color=always ".*"
        echo ""
        read -q "REPLY?⚠️  FORCE KILL process $1? This cannot be undone! (y/n): "
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            kill -9 $1 2>/dev/null && echo "💀 Process $1 force killed" || echo "❌ Failed to force kill process $1"
        else
            echo "❌ Force kill cancelled"
        fi
    else
        # It's a process name
        local pids=($(pgrep -f "$1"))
        
        if [ ${#pids[@]} -eq 0 ]; then
            echo "❌ No processes found matching: $1"
            return 1
        fi
        
        echo "🔍 Found ${#pids[@]} process(es) matching: $1"
        for pid in "${pids[@]}"; do
            ps -p $pid -o pid,ppid,user,command | tail -n +2 | grep --color=always ".*"
        done
        
        echo ""
        read -q "REPLY?⚠️  FORCE KILL ALL ${#pids[@]} processes? This cannot be undone! (y/n): "
        echo ""
        
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            for pid in "${pids[@]}"; do
                kill -9 $pid 2>/dev/null && echo "💀 Force killed PID: $pid" || echo "❌ Failed to force kill PID: $pid"
            done
        else
            echo "❌ Force kill cancelled"
        fi
    fi
}

# Quick process overview
ptop() {
    echo "🖥️  System Process Overview"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "📊 Top CPU consumers:"
    ps aux --sort=-%cpu | head -6 | grep --color=always ".*"
    echo ""
    echo "💾 Top Memory consumers:"
    ps aux --sort=-%mem | head -6 | grep --color=always ".*"
    echo ""
    echo "🔢 Process count: $(ps aux | wc -l) total processes"
    echo "👤 Your processes: $(ps -u $(whoami) | wc -l)"
}

# Enhanced aliases for the new functions
alias ps='processes'          # Override ps with colorful version
alias psg='pname'            # Search processes by name
alias killp='kname'          # Kill by name
alias killport='kport'       # Kill by port
alias fk='fkill'             # Force kill shorthand
# alias exa="eza"  # Uncomment when eza is installed
# Quick shortcuts
alias top10='ps aux --sort=-%cpu | head -11'
alias mem10='ps aux --sort=-%mem | head -11'
alias myps='ps -u $(whoami) -o pid,ppid,pcpu,pmem,command'

export CLICOLOR=1
export LSCOLORS=ExFxBxegedabagacad


# -----------------------------------------------------------------------------
# AUTOMATIC COMMAND HISTORY WITH LOCATION & TIME (10K LINES)
# -----------------------------------------------------------------------------

# History file location
COMMAND_HISTORY_FILE="$HOME/.command_history"

# Auto-log every command with location and timestamp
preexec() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local current_path=$(pwd)
    local command="$1"
    
    # Log to history file
    echo "[$timestamp] [$current_path] $command" >> "$COMMAND_HISTORY_FILE"
}

# View last 100 commands with colors
viewhistory() {
    if [[ -f "$COMMAND_HISTORY_FILE" ]]; then
        echo "📚 Last 100 Commands:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        
        tail -100 "$COMMAND_HISTORY_FILE" | nl -w3 -s': ' | while IFS= read -r line; do
            # Color: timestamp=yellow, path=blue, command=green
            echo "$line" | sed -E "s/(\[[0-9-]+ [0-9:]+\])/${fg[yellow]}\1${reset_color}/g" \
                         | sed -E "s/(\[\/[^\]]+\])/${fg[blue]}\1${reset_color}/g" \
                         | sed -E "s/(\] )(.+)$/\1${fg[green]}\2${reset_color}/g"
        done
    else
        echo "❌ No command history found yet. Start running commands!"
    fi
}

# Enhanced search with multiple options - using awk instead of grep
searchhistory() {
    if [[ ! -f "$COMMAND_HISTORY_FILE" ]]; then
        echo "❌ No command history found."
        return 1
    fi

    case "$1" in
        "-path"|"--path")
            # Search by path using awk
            if [[ -z "$2" ]]; then
                echo "❌ Usage: searchhistory -path <path>"
                echo "📝 Example: searchhistory -path /Users/{username}/workspace"
                echo "📝 Example: searchhistory -path workspace (partial match)"
                return 1
            fi
            
            echo "📁 Searching commands in path containing: $2"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            awk -v pattern="$2" 'tolower($0) ~ tolower(pattern) && $0 ~ /\[\/.*\]/ {print}' "$COMMAND_HISTORY_FILE" | tail -50 | nl -w3 -s': ' | while IFS= read -r line; do
                echo "$line" | sed -E "s/(\[[0-9-]+ [0-9:]+\])/${fg[yellow]}\1${reset_color}/g" \
                             | sed -E "s/(\[\/[^\]]+\])/${fg[blue]}\1${reset_color}/g" \
                             | sed -E "s/(\] )(.+)$/\1${fg[green]}\2${reset_color}/g"
            done
            ;;
            
        "-time"|"--time")
            # Search by time using awk
            if [[ -z "$2" ]]; then
                echo "❌ Usage: searchhistory -time <time>"
                echo "📝 Example: searchhistory -time 14:30"
                echo "📝 Example: searchhistory -time 09: (all commands at 9 AM)"
                return 1
            fi
            
            echo "🕐 Searching commands at time containing: $2"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            awk -v pattern="$2" '$0 ~ pattern {print}' "$COMMAND_HISTORY_FILE" | tail -50 | nl -w3 -s': ' | while IFS= read -r line; do
                echo "$line" | sed -E "s/(\[[0-9-]+ [0-9:]+\])/${fg[yellow]}\1${reset_color}/g" \
                             | sed -E "s/(\[\/[^\]]+\])/${fg[blue]}\1${reset_color}/g" \
                             | sed -E "s/(\] )(.+)$/\1${fg[green]}\2${reset_color}/g"
            done
            ;;
            
        "-date"|"--date")
            # Search by date using awk
            if [[ -z "$2" ]]; then
                echo "❌ Usage: searchhistory -date <date>"
                echo "📝 Example: searchhistory -date 2024-01-15"
                echo "📝 Example: searchhistory -date 2024-01 (all January 2024)"
                echo "📝 Example: searchhistory -date today"
                echo "📝 Example: searchhistory -date yesterday"
                return 1
            fi
            
            local search_date="$2"
            
            # Handle special date keywords
            case "$search_date" in
                "today")
                    search_date=$(date '+%Y-%m-%d')
                    ;;
                "yesterday")
                    search_date=$(date -v-1d '+%Y-%m-%d' 2>/dev/null || date -d 'yesterday' '+%Y-%m-%d' 2>/dev/null)
                    ;;
            esac
            
            echo "📅 Searching commands on date: $search_date"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            awk -v pattern="$search_date" '$0 ~ pattern {print}' "$COMMAND_HISTORY_FILE" | tail -50 | nl -w3 -s': ' | while IFS= read -r line; do
                echo "$line" | sed -E "s/(\[[0-9-]+ [0-9:]+\])/${fg[yellow]}\1${reset_color}/g" \
                             | sed -E "s/(\[\/[^\]]+\])/${fg[blue]}\1${reset_color}/g" \
                             | sed -E "s/(\] )(.+)$/\1${fg[green]}\2${reset_color}/g"
            done
            ;;
            
        "-help"|"--help"|"-h")
            echo "🔍 Search History Options:"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "  searchhistory <term>           - Search commands containing term"
            echo "  searchhistory -path <path>     - Search by directory path"
            echo "  searchhistory -time <time>     - Search by time (HH:MM)"
            echo "  searchhistory -date <date>     - Search by date (YYYY-MM-DD)"
            echo ""
            echo "📝 Examples:"
            echo "  searchhistory git              - Find all git commands"
            echo "  searchhistory -path workspace  - Commands in workspace directory"
            echo "  searchhistory -time 14:30      - Commands at 2:30 PM"
            echo "  searchhistory -date today      - Today's commands"
            echo "  searchhistory -date yesterday  - Yesterday's commands"
            echo "  searchhistory -date 2024-01-15 - Commands on specific date"
            ;;
            
        "")
            echo "❌ Usage: searchhistory <term|option>"
            echo "💡 Use 'searchhistory -help' for all options"
            ;;
            
        *)
            # Default search in command text using awk
            echo "🔍 Searching for: $1"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            
            awk -v pattern="$1" 'tolower($0) ~ tolower(pattern) {print}' "$COMMAND_HISTORY_FILE" | tail -50 | nl -w3 -s': ' | while IFS= read -r line; do
                echo "$line" | sed -E "s/(\[[0-9-]+ [0-9:]+\])/${fg[yellow]}\1${reset_color}/g" \
                             | sed -E "s/(\[\/[^\]]+\])/${fg[blue]}\1${reset_color}/g" \
                             | sed -E "s/(\] )(.+)$/\1${fg[green]}\2${reset_color}/g"
            done
            ;;
    esac
}

# Clean old history (keep last 10,000 entries)
cleanhistory() {
    if [[ -f "$COMMAND_HISTORY_FILE" ]]; then
        echo "🧹 Cleaning old history entries..."
        tail -10000 "$COMMAND_HISTORY_FILE" > "${COMMAND_HISTORY_FILE}.tmp"
        mv "${COMMAND_HISTORY_FILE}.tmp" "$COMMAND_HISTORY_FILE"
        echo "✅ Kept last 10,000 entries"
    else
        echo "❌ No command history found."
    fi
}

# Auto-clean when file gets too large (keeps exactly 10,000 lines)
auto_clean_history() {
    if [[ -f "$COMMAND_HISTORY_FILE" ]]; then
        local line_count=$(wc -l < "$COMMAND_HISTORY_FILE")
        if (( line_count > 12000 )); then
            echo "🧹 Auto-cleaning history (${line_count} lines)..."
            tail -10000 "$COMMAND_HISTORY_FILE" > "${COMMAND_HISTORY_FILE}.tmp"
            mv "${COMMAND_HISTORY_FILE}.tmp" "$COMMAND_HISTORY_FILE"
            echo "✅ Auto-cleaned: kept last 10,000 entries"
        fi
    fi
}

# Enhanced preexec with auto-clean
preexec() {
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    local current_path=$(pwd)
    local command="$1"
    
    # Log to history file
    echo "[$timestamp] [$current_path] $command" >> "$COMMAND_HISTORY_FILE"
    
    # Auto-clean every 100 commands (roughly)
    if (( RANDOM % 100 == 0 )); then
        auto_clean_history
    fi
}

# History statistics using awk
historystat() {
    if [[ -f "$COMMAND_HISTORY_FILE" ]]; then
        echo "📊 Command History Statistics:"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "📈 Total entries: $(wc -l < "$COMMAND_HISTORY_FILE")"
        echo "📅 First entry: $(awk 'NR==1 {match($0, /\[[0-9-]+ [0-9:]+\]/); print substr($0, RSTART+1, RLENGTH-2)}' "$COMMAND_HISTORY_FILE")"
        echo "📅 Last entry: $(awk 'END {match($0, /\[[0-9-]+ [0-9:]+\]/); print substr($0, RSTART+1, RLENGTH-2)}' "$COMMAND_HISTORY_FILE")"
        echo "💾 File size: $(du -h "$COMMAND_HISTORY_FILE" | cut -f1)"
        echo ""
        echo "🔥 Top 10 most used commands:"
        awk '{match($0, /\] (.+)$/, arr); if(arr[1]) print arr[1]}' "$COMMAND_HISTORY_FILE" | awk '{print $1}' | sort | uniq -c | sort -nr | head -10 | nl -w3 -s': '
        echo ""
        echo "📁 Top 10 most active directories:"
        awk '{match($0, /\[([^]]+)\]/, arr); if(arr[1] && arr[1] ~ /^\//) print arr[1]}' "$COMMAND_HISTORY_FILE" | sort | uniq -c | sort -nr | head -10 | nl -w3 -s': '
    else
        echo "❌ No command history found."
    fi
}

# Convenient aliases
alias vh='viewhistory'
alias sh='searchhistory'
alias ch='cleanhistory'
alias hs='historystat'


# =============================================================================
# COMPREHENSIVE HELP SYSTEM FOR ALL COMMANDS
# =============================================================================

# Main help function with categories
help() {
    case "$1" in
        "nav"|"navigation")
            help_navigation
            ;;
        "git")
            help_git
            ;;
        "files"|"file")
            help_files
            ;;
        "search"|"find")
            help_search
            ;;
        "proc"|"process")
            help_process
            ;;
        "sys"|"system")
            help_system
            ;;
        "net"|"network")
            help_network
            ;;
        "hist"|"history")
            help_history
            ;;
        "utils"|"utility")
            help_utils
            ;;
        "workspace"|"ws")
            help_workspace
            ;;
        "all")
            help_all_commands
            ;;
        "")
            help_main_menu
            ;;
        "ai"|"artificial")
            help_ai
            ;;
        *)
            help_specific_command "$1"
            ;;
    esac
}

# Main help menu
help_main_menu() {
    echo "🚀 ${fg[cyan]}{username}'S ZSH COMMAND HELP SYSTEM${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}📚 CATEGORIES:${reset_color}"
    echo "  ${fg[green]}help nav${reset_color}        - Navigation & Directory commands"
    echo "  ${fg[green]}help git${reset_color}        - Git version control commands"
    echo "  ${fg[green]}help files${reset_color}      - File operations & management"
    echo "  ${fg[green]}help search${reset_color}     - Search & find commands"
    echo "  ${fg[green]}help proc${reset_color}       - Process management commands"
    echo "  ${fg[green]}help sys${reset_color}        - System monitoring commands"
    echo "  ${fg[green]}help net${reset_color}        - Network & connectivity commands"
    echo "  ${fg[green]}help hist${reset_color}       - Command history management"
    echo "  ${fg[green]}help utils${reset_color}      - Utility functions"
    echo "  ${fg[green]}help workspace${reset_color}  - Workspace setup commands"
    echo ""
    echo "${fg[yellow]}🔍 QUICK ACCESS:${reset_color}"
    echo "  ${fg[green]}help all${reset_color}        - Show ALL commands (long list)"
    echo "  ${fg[green]}help <command>${reset_color}  - Get help for specific command"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  help ls           - Help for 'ls' command"
    echo "  help git          - All git commands"
    echo "  help kport        - Help for kill by port"
    echo "  ${fg[green]}help ai${reset_color}         - AI assistant commands"

}

# Navigation Help
help_navigation() {
    echo "🧭 ${fg[cyan]}NAVIGATION & DIRECTORY COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}📁 BASIC NAVIGATION:${reset_color}"
    echo "  ${fg[green]}..${reset_color}              cd ..                    ${fg[blue]}# Go up one directory${reset_color}"
    echo "  ${fg[green]}...${reset_color}             cd ../..                 ${fg[blue]}# Go up two directories${reset_color}"
    echo "  ${fg[green]}....${reset_color}            cd ../../..              ${fg[blue]}# Go up three directories${reset_color}"
    echo "  ${fg[green]}~${reset_color}               cd ~                     ${fg[blue]}# Go to home directory${reset_color}"
    echo "  ${fg[green]}-${reset_color}               cd -                     ${fg[blue]}# Go to previous directory${reset_color}"
    echo ""
    echo "${fg[yellow]}🏠 QUICK LOCATIONS:${reset_color}"
    echo "  ${fg[green]}workspace${reset_color}       cd ~/workspace && ls     ${fg[blue]}# Go to workspace${reset_color}"
    echo "  ${fg[green]}ws${reset_color}              cd ~/workspace           ${fg[blue]}# Short for workspace${reset_color}"
    echo "  ${fg[green]}desktop${reset_color}         cd ~/Desktop && ls       ${fg[blue]}# Go to Desktop${reset_color}"
    echo "  ${fg[green]}documents${reset_color}       cd ~/Documents && ls     ${fg[blue]}# Go to Documents${reset_color}"
    echo "  ${fg[green]}downloads${reset_color}       cd ~/Downloads && ls     ${fg[blue]}# Go to Downloads${reset_color}"
    echo "  ${fg[green]}down${reset_color}            cd ~/Downloads           ${fg[blue]}# Short for downloads${reset_color}"
    echo ""
    echo "${fg[yellow]}📚 DIRECTORY STACK:${reset_color}"
    echo "  ${fg[green]}d${reset_color}               dirs -v                  ${fg[blue]}# Show directory stack${reset_color}"
    echo "  ${fg[green]}1${reset_color}               cd -1                    ${fg[blue]}# Jump to directory #1${reset_color}"
    echo "  ${fg[green]}2${reset_color}               cd -2                    ${fg[blue]}# Jump to directory #2${reset_color}"
    echo "  ${fg[green]}3${reset_color}               cd -3                    ${fg[blue]}# Jump to directory #3${reset_color}"
    echo ""
    echo "${fg[yellow]}🛠️  DIRECTORY FUNCTIONS:${reset_color}"
    echo "  ${fg[green]}mkcd <dir>${reset_color}      mkdir -p dir && cd dir   ${fg[blue]}# Create and enter directory${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  mkcd project/src/components    ${fg[gray]}# Creates nested dirs and enters${reset_color}"
    echo "  ws                             ${fg[gray]}# Quick jump to workspace${reset_color}"
    echo "  d                              ${fg[gray]}# See recent directories${reset_color}"
    echo "  1                              ${fg[gray]}# Jump to most recent directory${reset_color}"
}

# Git Help
help_git() {
    echo "🔀 ${fg[cyan]}GIT VERSION CONTROL COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}⚡ BASIC GIT:${reset_color}"
    echo "  ${fg[green]}g${reset_color}               git                      ${fg[blue]}# Git shorthand${reset_color}"
    echo "  ${fg[green]}gs${reset_color}              git status --short       ${fg[blue]}# Compact status${reset_color}"
    echo "  ${fg[green]}gss${reset_color}             git status               ${fg[blue]}# Full status${reset_color}"
    echo "  ${fg[green]}ga <files>${reset_color}      git add <files>          ${fg[blue]}# Add specific files${reset_color}"
    echo "  ${fg[green]}gaa${reset_color}             git add --all            ${fg[blue]}# Add all changes${reset_color}"
    echo "  ${fg[green]}gc \"msg\"${reset_color}       git commit -m \"msg\"     ${fg[blue]}# Commit with message${reset_color}"
    echo "  ${fg[green]}gca${reset_color}             git commit --amend       ${fg[blue]}# Amend last commit${reset_color}"
    echo ""
    echo "${fg[yellow]}🌿 BRANCHES:${reset_color}"
    echo "  ${fg[green]}gb${reset_color}              git branch --color       ${fg[blue]}# List branches${reset_color}"
    echo "  ${fg[green]}gco <branch>${reset_color}    git checkout <branch>    ${fg[blue]}# Switch branch${reset_color}"
    echo "  ${fg[green]}gcb <branch>${reset_color}    git checkout -b <branch> ${fg[blue]}# Create new branch${reset_color}"
    echo "  ${fg[green]}gm <branch>${reset_color}     git merge <branch>       ${fg[blue]}# Merge branch${reset_color}"
    echo ""
    echo "${fg[yellow]}📊 VIEWING CHANGES:${reset_color}"
    echo "  ${fg[green]}gd${reset_color}              git diff --color         ${fg[blue]}# Show unstaged changes${reset_color}"
    echo "  ${fg[green]}gds${reset_color}             git diff --staged        ${fg[blue]}# Show staged changes${reset_color}"
    echo "  ${fg[green]}gl${reset_color}              git log --oneline        ${fg[blue]}# Compact log${reset_color}"
    echo "  ${fg[green]}gll${reset_color}             git log --graph --pretty ${fg[blue]}# Beautiful log${reset_color}"
    echo "  ${fg[green]}gtree${reset_color}           git log --graph --all    ${fg[blue]}# Full project tree${reset_color}"
    echo ""
    echo "${fg[yellow]}🔄 SYNC & REMOTE:${reset_color}"
    echo "  ${fg[green]}gf${reset_color}              git fetch                ${fg[blue]}# Fetch remote changes${reset_color}"
    echo "  ${fg[green]}gp${reset_color}              git push                 ${fg[blue]}# Push to remote${reset_color}"
    echo "  ${fg[green]}gpl${reset_color}             git pull                 ${fg[blue]}# Pull from remote${reset_color}"
    echo ""
    echo "${fg[yellow]}💾 STASH & RESET:${reset_color}"
    echo "  ${fg[green]}gst${reset_color}             git stash                ${fg[blue]}# Stash changes${reset_color}"
    echo "  ${fg[green]}gstp${reset_color}            git stash pop            ${fg[blue]}# Apply stash${reset_color}"
    echo "  ${fg[green]}gundo${reset_color}           git reset HEAD~1 --mixed ${fg[blue]}# Undo last commit${reset_color}"
    echo "  ${fg[green]}greset${reset_color}          git reset --hard HEAD    ${fg[blue]}# Reset to HEAD${reset_color}"
    echo "  ${fg[green]}gclean${reset_color}          git clean -fd            ${fg[blue]}# Clean untracked files${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  ga src/main.js                 ${fg[gray]}# Add specific file${reset_color}"
    echo "  gc \"Add new feature\"          ${fg[gray]}# Commit with message${reset_color}"
    echo "  gcb feature/new-login          ${fg[gray]}# Create feature branch${reset_color}"
    echo "  gll                            ${fg[gray]}# See beautiful commit history${reset_color}"
}

# File Operations Help
help_files() {
    echo "📁 ${fg[cyan]}FILE OPERATIONS & MANAGEMENT${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}📋 LISTING FILES:${reset_color}"
    echo "  ${fg[green]}ls${reset_color}              ls -G                    ${fg[blue]}# List files (colorized)${reset_color}"
    echo "  ${fg[green]}ll${reset_color}              ls -alFG                 ${fg[blue]}# Detailed list${reset_color}"
    echo "  ${fg[green]}la${reset_color}              ls -AG                   ${fg[blue]}# List all (including hidden)${reset_color}"
    echo "  ${fg[green]}l${reset_color}               ls -CFG                  ${fg[blue]}# Compact list${reset_color}"
    echo "  ${fg[green]}lh${reset_color}              ls -lhG                  ${fg[blue]}# Human readable sizes${reset_color}"
    echo "  ${fg[green]}lt${reset_color}              ls -ltG                  ${fg[blue]}# Sort by time (newest first)${reset_color}"
    echo "  ${fg[green]}ltr${reset_color}             ls -ltrG                 ${fg[blue]}# Sort by time (oldest first)${reset_color}"
    echo "  ${fg[green]}lsize${reset_color}           ls -lhSG                 ${fg[blue]}# Sort by size${reset_color}"
    echo ""
    echo "${fg[yellow]}🔧 FILE OPERATIONS:${reset_color}"
    echo "  ${fg[green]}cp${reset_color}              cp -i                    ${fg[blue]}# Copy with confirmation${reset_color}"
    echo "  ${fg[green]}mv${reset_color}              mv -i                    ${fg[blue]}# Move with confirmation${reset_color}"
    echo "  ${fg[green]}rm${reset_color}              rm -i                    ${fg[blue]}# Remove with confirmation${reset_color}"
    echo "  ${fg[green]}mkdir${reset_color}           mkdir -pv                ${fg[blue]}# Create directories verbosely${reset_color}"
    echo "  ${fg[green]}rmdir${reset_color}           rmdir -v                 ${fg[blue]}# Remove directories verbosely${reset_color}"
    echo ""
    echo "${fg[yellow]}📏 SIZE & ANALYSIS:${reset_color}"
    echo "  ${fg[green]}sizes${reset_color}           du -sh * | sort -hr      ${fg[blue]}# Directory sizes${reset_color}"
    echo "  ${fg[green]}biggest${reset_color}         find largest files       ${fg[blue]}# Find biggest files${reset_color}"
    echo "  ${fg[green]}tree${reset_color}            tree -C                  ${fg[blue]}# Directory tree (colorized)${reset_color}"
    echo ""
    echo "${fg[yellow]}📝 VIEWING & EDITING:${reset_color}"
    echo "  ${fg[green]}cat${reset_color}             bat --style=numbers      ${fg[blue]}# View file with syntax highlighting${reset_color}"
    echo "  ${fg[green]}v${reset_color}               vim                      ${fg[blue]}# Edit with vim${reset_color}"
    echo "  ${fg[green]}vi${reset_color}              vim                      ${fg[blue]}# Edit with vim${reset_color}"
    echo "  ${fg[green]}nano${reset_color}            nano -c                  ${fg[blue]}# Edit with nano (line numbers)${reset_color}"
    echo "  ${fg[green]}preview${reset_color}         open -a Preview          ${fg[blue]}# Open in Preview app${reset_color}"
    echo ""
    echo "${fg[yellow]}📋 CLIPBOARD:${reset_color}"
    echo "  ${fg[green]}cpcontent <file>${reset_color} pbcopy < file           ${fg[blue]}# Copy file content to clipboard${reset_color}"
    echo "  ${fg[green]}cppath${reset_color}          realpath | pbcopy        ${fg[blue]}# Copy current path to clipboard${reset_color}"
    echo "  ${fg[green]}paste${reset_color}           pbpaste                  ${fg[blue]}# Paste from clipboard${reset_color}"
    echo ""
    echo "${fg[yellow]}🛠️  UTILITY FUNCTIONS:${reset_color}"
    echo "  ${fg[green]}extract <file>${reset_color}  Extract any archive      ${fg[blue]}# Auto-detect format${reset_color}"
    echo "  ${fg[green]}backup <file>${reset_color}   Create timestamped backup ${fg[blue]}# Safe backup${reset_color}"
    echo "  ${fg[green]}finder${reset_color}          open .                   ${fg[blue]}# Open current dir in Finder${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  lsize                          ${fg[gray]}# See files sorted by size${reset_color}"
    echo "  cpcontent config.json          ${fg[gray]}# Copy file content to clipboard${reset_color}"
    echo "  extract project.zip            ${fg[gray]}# Extract any archive type${reset_color}"
    echo "  backup important.txt           ${fg[gray]}# Create timestamped backup${reset_color}"
}

# Search & Find Help
help_search() {
    echo "🔍 ${fg[cyan]}SEARCH & FIND COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}🔎 TEXT SEARCH:${reset_color}"
    echo "  ${fg[green]}grep${reset_color}            grep --color=always      ${fg[blue]}# Search in files (colorized)${reset_color}"
    echo "  ${fg[green]}fgrep${reset_color}           fgrep --color=always     ${fg[blue]}# Fixed string search${reset_color}"
    echo "  ${fg[green]}egrep${reset_color}           egrep --color=always     ${fg[blue]}# Extended regex search${reset_color}"
    echo ""
    echo "${fg[yellow]}📂 FILE FINDING:${reset_color}"
    echo "  ${fg[green]}findfile <name>${reset_color}  find . -name \"name\"      ${fg[blue]}# Find files by name${reset_color}"
    echo "  ${fg[green]}finddir <name>${reset_color}   find . -type d -name     ${fg[blue]}# Find directories by name${reset_color}"
    echo "  ${fg[green]}findin <text>${reset_color}    grep -r \"text\" .        ${fg[blue]}# Find text in files${reset_color}"
    echo ""
    echo "${fg[yellow]}📚 HISTORY SEARCH:${reset_color}"
    echo "  ${fg[green]}h <term>${reset_color}         history | grep term      ${fg[blue]}# Search command history${reset_color}"
    echo "  ${fg[green]}hgrep <term>${reset_color}     history | grep term      ${fg[blue]}# Same as 'h'${reset_color}"
    echo ""
    echo "${fg[yellow]}🖥️  PROCESS SEARCH:${reset_color}"
    echo "  ${fg[green]}psg <name>${reset_color}       ps aux | grep name       ${fg[blue]}# Find running processes${reset_color}"
    echo "  ${fg[green]}pname <name>${reset_color}     Find processes by name   ${fg[blue]}# Enhanced process search${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  findfile \"*.js\"               ${fg[gray]}# Find all JavaScript files${reset_color}"
    echo "  findin \"TODO\"                 ${fg[gray]}# Find TODO comments in code${reset_color}"
    echo "  finddir node_modules           ${fg[gray]}# Find node_modules directories${reset_color}"
    echo "  h git                          ${fg[gray]}# Find all git commands in history${reset_color}"
    echo "  pname chrome                   ${fg[gray]}# Find Chrome processes${reset_color}"
}

# Process Management Help
help_process() {
    echo "⚙️ ${fg[cyan]}PROCESS MANAGEMENT COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}👀 VIEWING PROCESSES:${reset_color}"
    echo "  ${fg[green]}processes${reset_color}       ps aux (enhanced)        ${fg[blue]}# List all processes${reset_color}"
    echo "  ${fg[green]}processes <term>${reset_color} Search processes         ${fg[blue]}# Find specific processes${reset_color}"
    echo "  ${fg[green]}ptop${reset_color}            Process overview         ${fg[blue]}# Top CPU/Memory consumers${reset_color}"
    echo "  ${fg[green]}pname <name>${reset_color}     Find by process name     ${fg[blue]}# Enhanced process search${reset_color}"
    echo "  ${fg[green]}port <number>${reset_color}    Find process using port  ${fg[blue]}# What's using this port?${reset_color}"
    echo ""
    echo "${fg[yellow]}💀 KILLING PROCESSES:${reset_color}"
    echo "  ${fg[green]}kpid <pid>${reset_color}       kill <pid>               ${fg[blue]}# Kill by process ID${reset_color}"
    echo "  ${fg[green]}kname <name>${reset_color}     Kill by process name     ${fg[blue]}# Interactive kill by name${reset_color}"
    echo "  ${fg[green]}kport <port>${reset_color}     Kill process using port  ${fg[blue]}# Kill by port number${reset_color}"
    echo "  ${fg[green]}fkill <pid|name>${reset_color} Force kill (SIGKILL)     ${fg[blue]}# ⚠️  Force kill (dangerous)${reset_color}"
    echo ""
    echo "${fg[yellow]}📊 MONITORING:${reset_color}"
    echo "  ${fg[green]}top${reset_color}             top -o cpu               ${fg[blue]}# System monitor (CPU sorted)${reset_color}"
    echo "  ${fg[green]}htop${reset_color}            sudo htop                ${fg[blue]}# Enhanced system monitor${reset_color}"
    echo "  ${fg[green]}pscpu${reset_color}           Top CPU processes        ${fg[blue]}# Top 10 CPU consumers${reset_color}"
    echo "  ${fg[green]}psmem${reset_color}           Top memory processes     ${fg[blue]}# Top 10 memory consumers${reset_color}"
    echo "  ${fg[green]}myps${reset_color}            Your processes only      ${fg[blue]}# Only your processes${reset_color}"
    echo ""
    echo "${fg[yellow]}⚡ QUICK SHORTCUTS:${reset_color}"
    echo "  ${fg[green]}top10${reset_color}           ps aux --sort=-%cpu      ${fg[blue]}# Top 10 CPU processes${reset_color}"
    echo "  ${fg[green]}mem10${reset_color}           ps aux --sort=-%mem      ${fg[blue]}# Top 10 memory processes${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  processes node                 ${fg[gray]}# Find all Node.js processes${reset_color}"
    echo "  port 3000                      ${fg[gray]}# What's running on port 3000?${reset_color}"
    echo "  kname chrome                   ${fg[gray]}# Kill Chrome (with confirmation)${reset_color}"
    echo "  kport 8080                     ${fg[gray]}# Kill process on port 8080${reset_color}"
    echo "  ptop                           ${fg[gray]}# Quick system overview${reset_color}"
    echo ""
    echo "${fg[red]}⚠️  WARNING:${reset_color} ${fg[yellow]}fkill uses SIGKILL and cannot be undone!${reset_color}"
}

# System Monitoring Help
help_system() {
    echo "🖥️ ${fg[cyan]}SYSTEM MONITORING COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}💾 DISK & STORAGE:${reset_color}"
    echo "  ${fg[green]}df${reset_color}              df -h (formatted)        ${fg[blue]}# Disk usage${reset_color}"
    echo "  ${fg[green]}du${reset_color}              du -h                    ${fg[blue]}# Directory usage${reset_color}"
    echo "  ${fg[green]}sizes${reset_color}           du -sh * | sort -hr      ${fg[blue]}# Directory sizes sorted${reset_color}"
    echo "  ${fg[green]}biggest${reset_color}         Find largest files       ${fg[blue]}# Top 10 biggest files${reset_color}"
    echo ""
    echo "${fg[yellow]}🔌 SYSTEM INFO:${reset_color}"
    echo "  ${fg[green]}sysinfo${reset_color}         system_profiler          ${fg[blue]}# System information${reset_color}"
    echo "  ${fg[green]}battery${reset_color}         pmset -g batt            ${fg[blue]}# Battery status${reset_color}"
    echo "  ${fg[green]}temp${reset_color}            System temperature       ${fg[blue]}# CPU temperature${reset_color}"
    echo ""
    echo "${fg[yellow]}🔄 ENVIRONMENT:${reset_color}"
    echo "  ${fg[green]}env${reset_color}             env | sort | grep        ${fg[blue]}# Environment variables${reset_color}"
    echo "  ${fg[green]}path${reset_color}            echo PATH (formatted)    ${fg[blue]}# Show PATH variable${reset_color}"
    echo "  ${fg[green]}aliases${reset_color}         alias | grep             ${fg[blue]}# Show all aliases${reset_color}"
    echo "  ${fg[green]}reload${reset_color}          source ~/.zshrc          ${fg[blue]}# Reload zsh configuration${reset_color}"
    echo ""
    echo "${fg[yellow]}🌐 NETWORK MONITORING:${reset_color}"
    echo "  ${fg[green]}ports${reset_color}           netstat listening ports  ${fg[blue]}# Show listening ports${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  df                             ${fg[gray]}# Check disk space${reset_color}"
    echo "  sizes                          ${fg[gray]}# See which directories are largest${reset_color}"
    echo "  battery                        ${fg[gray]}# Check battery percentage${reset_color}"
    echo "  reload                         ${fg[gray]}# Reload your zsh config${reset_color}"
}

# Network Help
help_network() {
    echo "🌐 ${fg[cyan]}NETWORK & CONNECTIVITY COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}🔍 IP & CONNECTIVITY:${reset_color}"
    echo "  ${fg[green]}myip${reset_color}            curl ipinfo.io/ip        ${fg[blue]}# Your public IP address${reset_color}"
    echo "  ${fg[green]}localip${reset_color}         ipconfig getifaddr en0   ${fg[blue]}# Your local IP address${reset_color}"
    echo "  ${fg[green]}ping${reset_color}            ping -c 5                ${fg[blue]}# Ping (5 packets)${reset_color}"
    echo ""
    echo "${fg[yellow]}📡 WIFI & NETWORK:${reset_color}"
    echo "  ${fg[green]}wifi${reset_color}            networksetup wifi info   ${fg[blue]}# Current WiFi network${reset_color}"
    echo "  ${fg[green]}ports${reset_color}           netstat listening        ${fg[blue]}# Show listening ports${reset_color}"
    echo ""
    echo "${fg[yellow]}⚡ SPEED & TESTING:${reset_color}"
    echo "  ${fg[green]}speedtest${reset_color}       Internet speed test      ${fg[blue]}# Test connection speed${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  myip                           ${fg[gray]}# What's my public IP?${reset_color}"
    echo "  ping google.com                ${fg[gray]}# Test connection to Google${reset_color}"
    echo "  wifi                           ${fg[gray]}# Which WiFi network am I on?${reset_color}"
    echo "  speedtest                      ${fg[gray]}# Test internet speed${reset_color}"
}

# History Management Help
help_history() {
    echo "📚 ${fg[cyan]}COMMAND HISTORY MANAGEMENT${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}👀 VIEWING HISTORY:${reset_color}"
    echo "  ${fg[green]}vh${reset_color}              viewhistory              ${fg[blue]}# View last 100 commands${reset_color}"
    echo "  ${fg[green]}viewhistory${reset_color}     View with timestamps     ${fg[blue]}# Full command history${reset_color}"
    echo "  ${fg[green]}hs${reset_color}              historystat              ${fg[blue]}# History statistics${reset_color}"
    echo "  ${fg[green]}historystat${reset_color}     Detailed history stats   ${fg[blue]}# Usage patterns${reset_color}"
    echo ""
    echo "${fg[yellow]}🔍 SEARCHING HISTORY:${reset_color}"
    echo "  ${fg[green]}sh <term>${reset_color}       searchhistory term       ${fg[blue]}# Search for commands${reset_color}"
    echo "  ${fg[green]}sh -path <path>${reset_color}  Search by directory      ${fg[blue]}# Commands in specific path${reset_color}"
    echo "  ${fg[green]}sh -time <time>${reset_color}  Search by time           ${fg[blue]}# Commands at specific time${reset_color}"
    echo "  ${fg[green]}sh -date <date>${reset_color}  Search by date           ${fg[blue]}# Commands on specific date${reset_color}"
    echo "  ${fg[green]}sh -help${reset_color}        Search help              ${fg[blue]}# All search options${reset_color}"
    echo ""
    echo "${fg[yellow]}🧹 MAINTENANCE:${reset_color}"
    echo "  ${fg[green]}ch${reset_color}              cleanhistory             ${fg[blue]}# Clean old entries${reset_color}"
    echo "  ${fg[green]}cleanhistory${reset_color}    Keep last 10,000        ${fg[blue]}# Automatic cleanup${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  sh git                         ${fg[gray]}# Find all git commands${reset_color}"
    echo "  sh -path workspace             ${fg[gray]}# Commands run in workspace${reset_color}"
    echo "  sh -time 14:30                 ${fg[gray]}# Commands at 2:30 PM${reset_color}"
    echo "  sh -date today                 ${fg[gray]}# Today's commands${reset_color}"
    echo "  sh -date yesterday             ${fg[gray]}# Yesterday's commands${reset_color}"
    echo "  sh -date 2024-01-15            ${fg[gray]}# Commands on specific date${reset_color}"
    echo "  hs                             ${fg[gray]}# See usage statistics${reset_color}"
    echo ""
    echo "${fg[green]}📝 Special Features:${reset_color}"
    echo "  • Auto-logs every command with timestamp and location"
    echo "  • Keeps last 10,000 commands automatically"
    echo "  • Color-coded output for easy reading"
    echo "  • Smart date parsing (today, yesterday, etc.)"
}

# Utility Functions Help
help_utils() {
    echo "🛠️ ${fg[cyan]}UTILITY FUNCTIONS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}🗂️ ARCHIVE & COMPRESSION:${reset_color}"
    echo "  ${fg[green]}extract <file>${reset_color}  Auto-extract archives    ${fg[blue]}# Supports: zip,tar,gz,bz2,7z,rar${reset_color}"
    echo ""
    echo "${fg[yellow]}🌤️  WEATHER & INFO:${reset_color}"
    echo "  ${fg[green]}weather <city>${reset_color}   curl wttr.in/city        ${fg[blue]}# Get weather for city${reset_color}"
    echo "  ${fg[green]}qr <text>${reset_color}        Generate QR code         ${fg[blue]}# Text to QR code${reset_color}"
    echo ""
    echo "${fg[yellow]}📝 NOTES & BACKUP:${reset_color}"
    echo "  ${fg[green]}note <text>${reset_color}      Quick note taking        ${fg[blue]}# Append to ~/notes.txt${reset_color}"
    echo "  ${fg[green]}viewnotes${reset_color}        View recent notes        ${fg[blue]}# Last 20 notes${reset_color}"
    echo "  ${fg[green]}backup <file>${reset_color}    Timestamped backup       ${fg[blue]}# Safe file backup${reset_color}"
    echo ""
    echo "${fg[yellow]}🎨 CONFIGURATION:${reset_color}"
    echo "  ${fg[green]}vimrc${reset_color}            vim ~/.vimrc             ${fg[blue]}# Edit vim config${reset_color}"
    echo "  ${fg[green]}zshrc${reset_color}            vim ~/.zshrc             ${fg[blue]}# Edit zsh config${reset_color}"
    echo "  ${fg[green]}xcode${reset_color}            xcode-select -p          ${fg[blue]}# Show Xcode path${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  extract project.zip            ${fg[gray]}# Auto-extract any archive${reset_color}"
    echo "  weather london                 ${fg[gray]}# London weather${reset_color}"
    echo "  weather                        ${fg[gray]}# Local weather${reset_color}"
    echo "  note \"Remember to call John\"   ${fg[gray]}# Quick note${reset_color}"
    echo "  qr \"https://github.com\"        ${fg[gray]}# Generate QR code${reset_color}"
    echo "  backup config.json             ${fg[gray]}# Safe backup with timestamp${reset_color}"
}

# Workspace Help
help_workspace() {
    echo "🚀 ${fg[cyan]}WORKSPACE SETUP COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}⚡ MAIN COMMAND:${reset_color}"
    echo "  ${fg[green]}sss${reset_color}             Setup workspace          ${fg[blue]}# Complete workspace setup${reset_color}"
    echo ""
    echo "${fg[yellow]}📁 WORKSPACE NAVIGATION (after sss):${reset_color}"
    echo "  ${fg[green]}gobase${reset_color}          cd \$WORKSPACE_PATH       ${fg[blue]}# Go to base workspace${reset_color}"
    echo "  ${fg[green]}gomodem${reset_color}         cd modem directory       ${fg[blue]}# Go to modem${reset_color}"
    echo "  ${fg[green]}gocn${reset_color}            cd cellular_netsims      ${fg[blue]}# Go to cellular netsims${reset_color}"
    echo "  ${fg[green]}gocps${reset_color}           cd cellular_protocol     ${fg[blue]}# Go to protocol stack${reset_color}"
    echo "  ${fg[green]}gocpt${reset_color}           cd cellular_tools        ${fg[blue]}# Go to protocol tools${reset_color}"
    echo "  ${fg[green]}gocsb${reset_color}           cd system-build          ${fg[blue]}# Go to system build${reset_color}"
    echo "  ${fg[green]}gobuild${reset_color}         cd build tools           ${fg[blue]}# Go to build directory${reset_color}"
    echo "  ${fg[green]}gologs${reset_color}          cd logs directory        ${fg[blue]}# Go to logs${reset_color}"
    echo "  ${fg[green]}gorun${reset_color}           cd run directory         ${fg[blue]}# Go to run${reset_color}"
    echo "  ${fg[green]}golibs${reset_color}          cd libraries             ${fg[blue]}# Go to libraries${reset_color}"
    echo "  ${fg[green]}gol1c${reset_color}           cd l1c firmware          ${fg[blue]}# Go to L1C${reset_color}"
    echo "  ${fg[green]}goout${reset_color}           cd output directory      ${fg[blue]}# Go to output${reset_color}"
    echo "  ${fg[green]}goasc${reset_color}           cd ASC scripts           ${fg[blue]}# Go to ASC scripts${reset_color}"
    echo "  ${fg[green]}gottcn${reset_color}          cd TTCN3 testcases       ${fg[blue]}# Go to TTCN3${reset_color}"
    echo ""
    echo "${fg[yellow]}🔧 PHAROS LOGIN:${reset_color}"
    echo "  ${fg[green]}gopharos${reset_color}        Run pharos login script  ${fg[blue]}# Login to Pharos${reset_color}"
    echo ""
    echo "${fg[blue]}💡 Usage:${reset_color}"
    echo "  1. Run ${fg[green]}sss${reset_color} in your workspace directory"
    echo "  2. Use ${fg[green]}go*${reset_color} commands to navigate quickly"
    echo "  3. Environment variables are automatically set"
    echo ""
    echo "${fg[green]}📝 What sss does:${reset_color}"
    echo "  • Sets up WORKSPACE_PATH, OC6_WORKSPACE_ROOT, WORKSPACE"
    echo "  • Configures JAVA_HOME automatically"
    echo "  • Sets up library paths (DYLD_LIBRARY_PATH, LD_LIBRARY_PATH)"
    echo "  • Creates all navigation aliases"
    echo "  • Runs install_name_tool for library linking"
}

# Show all commands (comprehensive list)
help_all_commands() {
    echo "📖 ${fg[cyan]}ALL AVAILABLE COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}Use 'help <category>' for detailed help:${reset_color}"
    echo ""
    
    # Navigation
    echo "${fg[cyan]}🧭 NAVIGATION:${reset_color} .. ... .... ~ - workspace ws desktop documents downloads down d 1 2 3 mkcd"
    
    # Git  
    echo "${fg[cyan]}🔀 GIT:${reset_color} g ga gaa gc gca gco gcb gs gss gd gds gl gll gp gpl gb gm gf gst gstp gundo greset gclean gtree"
    
    # Files
    echo "${fg[cyan]}📁 FILES:${reset_color} ls ll la l lh lt ltr lsize cp mv rm mkdir rmdir sizes biggest tree cat v vi nano preview cpcontent cppath paste finder extract backup"
    
    # Search
    echo "${fg[cyan]}🔍 SEARCH:${reset_color} grep fgrep egrep findfile finddir findin h hgrep psg"
    
    # Process
    echo "${fg[cyan]}⚙️ PROCESS:${reset_color} processes pname port kpid kname kport fkill ptop top htop pscpu psmem myps top10 mem10"
    
    # System
    echo "${fg[cyan]}🖥️ SYSTEM:${reset_color} df du sizes biggest sysinfo battery temp env path aliases reload ports"
    
    # Network
    echo "${fg[cyan]}🌐 NETWORK:${reset_color} ping myip localip wifi speedtest"
    
    # History
    echo "${fg[cyan]}📚 HISTORY:${reset_color} vh viewhistory sh searchhistory ch cleanhistory hs historystat"
    
    # Utils
    echo "${fg[cyan]}🛠️ UTILS:${reset_color} extract weather qr note viewnotes backup vimrc zshrc xcode"
    
    # Workspace
    echo "${fg[cyan]}🚀 WORKSPACE:${reset_color} sss gobase gomodem gocn gocps gocpt gocsb gobuild gologs gorun golibs gol1c goout goasc gottcn gopharos"
    
    echo ""
    echo "${fg[blue]}💡 Pro tip: Use 'help <command>' for specific help on any command!${reset_color}"
}

# Help for specific commands
help_specific_command() {
    local cmd="$1"
    
    # Define help for specific commands
    case "$cmd" in
        "ls"|"ll"|"la"|"l"|"lh"|"lt"|"ltr"|"lsize")
            echo "${fg[cyan]}📋 LIST FILES: $cmd${reset_color}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            case "$cmd" in
                "ls") echo "Basic file listing with colors" ;;
                "ll") echo "Detailed list: permissions, size, date, owner" ;;
                "la") echo "List all files including hidden (starting with .)" ;;
                "l") echo "Compact columnar listing" ;;
                "lh") echo "Human readable file sizes (KB, MB, GB)" ;;
                "lt") echo "Sort by modification time (newest first)" ;;
                "ltr") echo "Sort by modification time (oldest first)" ;;
                "lsize") echo "Sort by file size (largest first)" ;;
            esac
            echo ""
            echo "${fg[blue]}💡 Examples:${reset_color}"
            echo "  $cmd                    ${fg[gray]}# List current directory${reset_color}"
            echo "  $cmd ~/Downloads        ${fg[gray]}# List specific directory${reset_color}"
            echo "  $cmd *.js              ${fg[gray]}# List only JavaScript files${reset_color}"
            ;;
            
        "kport"|"kname"|"kpid"|"fkill")
            echo "${fg[cyan]}💀 KILL PROCESS: $cmd${reset_color}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            case "$cmd" in
                "kport") 
                    echo "Kill process using specific port number"
                    echo "${fg[blue]}Usage:${reset_color} kport <port_number>"
                    echo "${fg[blue]}Example:${reset_color} kport 3000    ${fg[gray]}# Kill process on port 3000${reset_color}"
                    ;;
                "kname") 
                    echo "Kill process by name (interactive selection)"
                    echo "${fg[blue]}Usage:${reset_color} kname <process_name>"
                    echo "${fg[blue]}Example:${reset_color} kname chrome   ${fg[gray]}# Kill Chrome processes${reset_color}"
                    ;;
                "kpid") 
                    echo "Kill process by Process ID"
                    echo "${fg[blue]}Usage:${reset_color} kpid <process_id>"
                    echo "${fg[blue]}Example:${reset_color} kpid 1234     ${fg[gray]}# Kill process with PID 1234${reset_color}"
                    ;;
                "fkill") 
                    echo "${fg[red]}⚠️  FORCE KILL (SIGKILL) - Cannot be undone!${reset_color}"
                    echo "${fg[blue]}Usage:${reset_color} fkill <pid_or_name>"
                    echo "${fg[blue]}Example:${reset_color} fkill 1234    ${fg[gray]}# Force kill PID 1234${reset_color}"
                    echo "${fg[blue]}Example:${reset_color} fkill chrome  ${fg[gray]}# Force kill Chrome${reset_color}"
                    ;;
            esac
            ;;
            
        "searchhistory"|"sh")
            echo "${fg[cyan]}🔍 SEARCH COMMAND HISTORY${reset_color}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "${fg[blue]}Basic Usage:${reset_color}"
            echo "  sh <term>              Search for commands containing term"
            echo ""
            echo "${fg[blue]}Advanced Options:${reset_color}"
            echo "  sh -path <path>        Search commands run in specific directory"
            echo "  sh -time <time>        Search commands run at specific time"
            echo "  sh -date <date>        Search commands run on specific date"
            echo "  sh -help               Show all search options"
            echo ""
            echo "${fg[blue]}Examples:${reset_color}"
            echo "  sh git                 ${fg[gray]}# Find all git commands${reset_color}"
            echo "  sh -path workspace     ${fg[gray]}# Commands in workspace${reset_color}"
            echo "  sh -time 14:30         ${fg[gray]}# Commands at 2:30 PM${reset_color}"
            echo "  sh -date today         ${fg[gray]}# Today's commands${reset_color}"
            echo "  sh -date 2024-01-15    ${fg[gray]}# Specific date${reset_color}"
            ;;
            
        "sss")
            echo "${fg[cyan]}🚀 WORKSPACE SETUP${reset_color}"
            echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
            echo "Complete workspace environment setup for modem development"
            echo ""
            echo "${fg[blue]}What it does:${reset_color}"
            echo "  • Sets WORKSPACE_PATH, OC6_WORKSPACE_ROOT, WORKSPACE variables"
            echo "  • Configures JAVA_HOME automatically"  
            echo "  • Sets up library paths (DYLD_LIBRARY_PATH, LD_LIBRARY_PATH)"
            echo "  • Creates navigation aliases (gobase, gomodem, gocn, etc.)"
            echo "  • Runs install_name_tool for proper library linking"
            echo "  • Changes to build tools directory"
            echo ""
            echo "${fg[blue]}Usage:${reset_color}"
            echo "  1. Navigate to your workspace directory"
            echo "  2. Run: sss"
            echo "  3. Use go* commands for quick navigation"
            echo ""
            echo "${fg[blue]}Available after sss:${reset_color}"
            echo "  gobase, gomodem, gocn, gocps, gocpt, gocsb, gobuild, gologs, gorun, golibs, gol1c, goout, goasc, gottcn"
            ;;
            
        *)
            echo "${fg[red]}❌ No specific help found for: $cmd${reset_color}"
            echo ""
            echo "${fg[blue]}💡 Try:${reset_color}"
            echo "  help                   ${fg[gray]}# Main help menu${reset_color}"
            echo "  help all               ${fg[gray]}# List all commands${reset_color}"
            echo "  help <category>        ${fg[gray]}# Help for category (nav, git, files, etc.)${reset_color}"
            ;;
    esac
}

# Add help aliases
alias h='help'
alias helpme='help'
alias commands='help all'


# =============================================================================
# AI TERMINAL ASSISTANT INTEGRATION
# =============================================================================

# Check if AI helper script exists
AI_HELPER_SCRIPT="$HOME/.ai_helper.py"

# Function to check AI helper availability
_check_ai_helper() {
    if [[ ! -f "$AI_HELPER_SCRIPT" ]]; then
        echo "❌ AI helper script not found at $AI_HELPER_SCRIPT"
        echo "💡 Please ensure the AI helper script is installed"
        return 1
    fi
    
    # Check if python3 is available
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 not found. Please install Python3 to use AI features"
        return 1
    fi
    
    return 0
}

# AI Ask - General questions
aiask() {
    if [[ -z "$1" ]]; then
        echo "🤖 ${fg[cyan]}AI ASSISTANT - ASK MODE${reset_color}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "${fg[yellow]}Usage:${reset_color} aiask <your question>"
        echo ""
        echo "${fg[blue]}Examples:${reset_color}"
        echo "  aiask how do I find large files in my system"
        echo "  aiask what is the difference between chmod 755 and 644"
        echo "  aiask how to set up a git repository"
        echo "  aiask best practices for shell scripting"
        echo "  aiask how to monitor system performance on macOS"
        return 1
    fi
    
    if ! _check_ai_helper; then
        return 1
    fi
    
    echo "🤖 ${fg[cyan]}Asking AI: $*${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    python3 "$AI_HELPER_SCRIPT" ask "$@"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# AI Debug - Debug terminal errors
aidebug() {
    if [[ -z "$1" ]]; then
        echo "🔧 ${fg[cyan]}AI ASSISTANT - DEBUG MODE${reset_color}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "${fg[yellow]}Usage:${reset_color} aidebug <error message or issue description>"
        echo ""
        echo "${fg[blue]}Examples:${reset_color}"
        echo "  aidebug \"permission denied when trying to write to /usr/local\""
        echo "  aidebug \"command not found: npm\""
        echo "  aidebug \"git push failed with authentication error\""
        echo "  aidebug \"cannot connect to docker daemon\""
        echo ""
        echo "${fg[green]}💡 Pro tip:${reset_color} Copy and paste the exact error message for best results"
        return 1
    fi
    
    if ! _check_ai_helper; then
        return 1
    fi
    
    echo "🔧 ${fg[cyan]}Debugging issue: $*${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    python3 "$AI_HELPER_SCRIPT" debug "$@"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# AI Help - Execute command and analyze with AI
aihelp() {
    if [[ -z "$1" ]]; then
        echo "📚 ${fg[cyan]}AI ASSISTANT - HELP MODE${reset_color}"
        echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
        echo "${fg[yellow]}Usage:${reset_color} aihelp <command>"
        echo ""
        echo "${fg[blue]}What it does:${reset_color}"
        echo "  1. Executes the command and shows output"
        echo "  2. AI analyzes the execution results"
        echo "  3. Provides verdict (success/failure) and analysis"
        echo "  4. Gives recommendations and explanations"
        echo ""
        echo "${fg[blue]}Examples:${reset_color}"
        echo "  aihelp ls"
        echo "  aihelp git status"
        echo "  aihelp docker ps"
        echo "  aihelp chmod +x script.sh"
        echo "  aihelp find . -name '*.txt'"
        return 1
    fi
    
    if ! _check_ai_helper; then
        return 1
    fi
    
    local full_command="$*"
    
    echo "📚 ${fg[cyan]}AI Help for command: $full_command${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    # Use the new help mode that executes and analyzes
    python3 "$AI_HELPER_SCRIPT" help "$full_command"
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# AI Status - Check if AI helper is working
aistatus() {
    echo "🤖 ${fg[cyan]}AI ASSISTANT STATUS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check script existence
    if [[ -f "$AI_HELPER_SCRIPT" ]]; then
        echo "✅ AI helper script found: $AI_HELPER_SCRIPT"
    else
        echo "❌ AI helper script not found: $AI_HELPER_SCRIPT"
        return 1
    fi
    
    # Check Python
    if command -v python3 &> /dev/null; then
        echo "✅ Python3 available: $(which python3)"
        echo "   Version: $(python3 --version)"
    else
        echo "❌ Python3 not found"
        return 1
    fi
    
    # Check google-genai and rich modules
    echo ""
    echo "🔍 Testing AI connection..."
    python3 -c "
try:
    from google import genai
    print('✅ google.genai module imported successfully')
except ImportError as e:
    print(f'❌ Failed to import google.genai: {e}')
    exit(1)
except Exception as e:
    print(f'❌ Error with google.genai: {e}')
    exit(1)

try:
    import rich
    print('✅ Rich module imported successfully')
except ImportError as e:
    print(f'❌ Failed to import rich: {e}')
    exit(1)
except Exception as e:
    print(f'❌ Error with rich: {e}')
    exit(1)
"
    
    if [[ $? -eq 0 ]]; then
        echo "✅ AI assistant is ready to use!"
        echo ""
        echo "${fg[blue]}Available commands:${reset_color}"
        echo "  aiask <question>     - Ask AI any question"
        echo "  aidebug <error>      - Debug terminal errors"  
        echo "  aihelp <command>     - Get help and test commands"
        echo "  aistatus             - Check AI system status"
    else
        echo "❌ AI assistant is not properly configured"
        echo ""
        echo "${fg[yellow]}Setup instructions:${reset_color}"
        echo "1. Install the google-genai package: pip3 install google-genai"
        echo "2. Make sure the AI helper script is at: $AI_HELPER_SCRIPT"
        echo "3. Run 'aistatus' again to verify"
    fi
}

# Function to install AI helper
install_ai_helper() {
    echo "🤖 ${fg[cyan]}Installing AI Terminal Assistant${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    
    # Check if Python3 is available
    if ! command -v python3 &> /dev/null; then
        echo "❌ Python3 is required but not found"
        echo "💡 Install Python3 first: brew install python3"
        return 1
    fi
    
    # Install google-genai and rich if not present
    echo "📦 Checking required packages..."
    python3 -c "from google import genai" 2>/dev/null || {
        echo "📦 Installing google-genai package..."
        pip3 install google-genai
    }
    python3 -c "import rich" 2>/dev/null || {
        echo "📦 Installing rich package..."
        pip3 install rich
    }
    
    # Create the AI helper script
    echo "📝 Creating AI helper script..."
    cat > "$HOME/.ai_helper.py" << 'EOF'
#!/usr/bin/env python3
"""
AI Helper Script for Terminal Commands (Gemini version)
Provides intelligent assistance for shell operations using Google Gemini
"""

import sys
import subprocess
import os
import time
import threading
import concurrent.futures
from google import genai
try:
    from openai import OpenAI  # v1 client
except Exception:
    OpenAI = None
try:
    from rich.console import Console
    from rich.markdown import Markdown
    _RICH_AVAILABLE = True
except Exception:
    _RICH_AVAILABLE = False

GEMINI_MODEL = "gemini-2.5-flash"
client = genai.Client(api_key="***REMOVED***")
OPENAI_DEFAULT_KEY = os.environ.get(
    "OPENAI_API_KEY",
    "***REMOVED***",
)

class TerminalAI:
    def __init__(self):
        self.context = self._get_system_context()
        try:
            self.client = client
        except Exception:
            self.client = None
        # Initialize OpenAI v1 client using provided or env key
        try:
            if OpenAI is not None:
                api_key = os.environ.get("OPENAI_API_KEY", OPENAI_DEFAULT_KEY)
                if not api_key:
                    self.openai_client = None
                else:
                    self.openai_client = OpenAI(api_key=api_key)
            else:
                self.openai_client = None
        except Exception:
            self.openai_client = None
        self.last_status = None  # track which provider answered / why

    def _start_spinner(self, phases=("Thinking", "Analysing"), interval=0.5):
        stop_event = threading.Event()

        def _spin():
            i = 0
            dots = [".", "..", "..."]
            while not stop_event.is_set():
                phase = phases[(i // 3) % len(phases)]
                msg = f"{phase} {dots[i % 3]}"
                try:
                    sys.stdout.write("\r" + msg + " " * 10)
                    sys.stdout.flush()
                except Exception:
                    pass
                time.sleep(interval)
                i += 1
            # clear the line when done
            try:
                sys.stdout.write("\r" + " " * 80 + "\r")
                sys.stdout.flush()
            except Exception:
                pass

        thread = threading.Thread(target=_spin, daemon=True)
        thread.start()
        return stop_event
    
    def _get_system_context(self):
        """Get current system context for better AI responses"""
        try:
            # Get current directory
            cwd = os.getcwd()
            
            # Get shell type
            shell = os.environ.get('SHELL', 'unknown')
            
            # Get OS info
            os_info = subprocess.run(['uname', '-a'], capture_output=True, text=True).stdout.strip()
            
            # Get current user
            user = os.environ.get('USER', 'unknown')
            
            return {
                'cwd': cwd,
                'shell': shell,
                'os': os_info,
                'user': user
            }
        except:
            return {}

    def ask_question(self, question):
        """Handle general AI questions about terminal/development"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        prompt = f"""You are an expert terminal and development assistant. The user is asking: "{question}"

Current context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Please respond using clean Markdown with concise headings (##/###), bullet lists, and fenced bash code blocks for commands (```bash). Keep it skimmable and practical with executable steps for macOS."""

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def debug_issue(self, error_output):
        """Debug terminal errors and provide solutions"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        prompt = f"""You are an expert system administrator and debugger. The user encountered this terminal error or issue:

ERROR/ISSUE:
{error_output}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Please analyze this error and provide:

1. DIAGNOSIS: What is causing this error
2. IMMEDIATE SOLUTION: The exact command(s) to fix this issue
3. EXPLANATION: Why this error occurred
4. PREVENTION: How to avoid this in the future
5. ALTERNATIVES: Other ways to accomplish what the user was trying to do

Use clean Markdown and fenced bash code blocks for commands that are executable on macOS."""

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def execute_and_analyze(self, command):
        """Execute a command and analyze its output with AI"""
        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        # Get current shell prompt info
        user = os.environ.get('USER', 'user')
        hostname = os.environ.get('HOSTNAME', 'MacBook-Pro')
        cwd = os.path.basename(os.getcwd())
        venv = os.environ.get('VIRTUAL_ENV', '')
        venv_name = os.path.basename(venv) if venv else ''
        
        # Display command as it would appear in terminal
        if venv_name:
            print(f"({venv_name}) {user}@{hostname} {cwd} % {command}")
        else:
            print(f"{user}@{hostname} {cwd} % {command}")
        
        # Execute the command FIRST - show output immediately
        try:
            result = subprocess.run(
                command,
                shell=True,
                capture_output=True,
                text=True,
                timeout=30,  # 30 second timeout
                cwd=self.context.get('cwd', os.getcwd())
            )
            
            # Capture execution details
            return_code = result.returncode
            stdout = result.stdout
            stderr = result.stderr
            
            # Display the output exactly as it would appear in terminal
            if stdout:
                print(stdout, end='')  # end='' to avoid extra newline
            if stderr:
                print(stderr, end='')  # end='' to avoid extra newline
            
            print()  # Add a newline after command output
            print("-" * 50)
            
            # Force flush output to ensure it shows immediately
            sys.stdout.flush()
            
            # Determine success based on return code (0 = success, non-zero = failure)
            success = return_code == 0
            status = "SUCCESS" if success else "FAILED"
            
            # NOW analyze with AI (after showing command output)
            prompt = f"""You are an expert system administrator and command analyst. A command was just executed and you need to analyze the results.

COMMAND EXECUTED: {command}
EXECUTION STATUS: {status}
RETURN CODE: {return_code}

STDOUT:
{stdout if stdout else '(no output)'}

STDERR:
{stderr if stderr else '(no errors)'}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

CRITICAL: The verdict must be based on the return code:
- Return code 0 = SUCCESS (command completed successfully)
- Return code non-zero = FAILED (command failed, regardless of output content)

Commands like 'git main' fail with return code 1 and show error messages in stdout, not stderr. This is still a FAILURE.

Please provide a comprehensive analysis in the following format:

## EXECUTION VERDICT
**Status:** {status}
**Command:** `{command}`
**Return Code:** {return_code}

## ANALYSIS
- **What happened:** Brief explanation of what the command did
- **Success/Failure reason:** Why it succeeded or failed (MUST consider return code)
- **Output interpretation:** What the output means

## RECOMMENDATIONS
- **What could be done differently:** Suggestions for improvement
- **Alternative approaches:** Other ways to achieve the same goal
- **Next steps:** What to do next

## COMMAND BREAKDOWN
- **Purpose:** What this command is designed to do
- **Key components:** Important parts of the command
- **Safety notes:** Any potential risks or considerations

CRITICAL: At the very end of your response, add a verdict line in this exact format:
- If return code is 0: VERDICT: SUCCESS
- If return code is non-zero: VERDICT: FAILED

The verdict MUST match the return code, not the content of the output.

Use clean Markdown formatting with fenced bash code blocks for commands. Ensure macOS compatibility."""

            try:
                analysis = self._generate_with_fallback(prompt)
                return analysis
            except Exception as e:
                return f"Error generating AI analysis: {str(e)}"
                
        except subprocess.TimeoutExpired:
            error_msg = f"Command timed out after 30 seconds: {command}"
            print(error_msg)
            if _RICH_AVAILABLE:
                console = Console()
                console.print(f"⏰ [bold yellow]Command timed out![/bold yellow]")
            else:
                print("⏰ Command timed out!")
            return f"## EXECUTION VERDICT\n**Status:** TIMEOUT\n**Command:** `{command}`\n\n## ANALYSIS\n- **What happened:** The command exceeded the 30-second timeout limit\n- **Recommendation:** Consider breaking down the command or using a different approach for long-running operations"
            
        except Exception as e:
            error_msg = f"Error executing command: {str(e)}"
            print(error_msg)
            if _RICH_AVAILABLE:
                console = Console()
                console.print(f"💥 [bold red]Execution error![/bold red]")
            else:
                print("💥 Execution error!")
            return f"## EXECUTION VERDICT\n**Status:** ERROR\n**Command:** `{command}`\n\n## ANALYSIS\n- **What happened:** An error occurred while trying to execute the command\n- **Error details:** {str(e)}\n- **Recommendation:** Check command syntax and system permissions"

    def help_command(self, command, error_output=None):
        """Get help with a specific command and optionally debug its error"""
        if error_output:
            # Command failed, debug it
            prompt = f"""You are an expert terminal command specialist. The user tried to run this command but it failed:

COMMAND ATTEMPTED: {command}
ERROR OUTPUT: {error_output}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}
- User: {self.context.get('user', 'unknown')}

Provide:

1. ERROR ANALYSIS: What went wrong with this specific command
2. CORRECTED COMMAND: The exact fixed version of the command
3. EXPLANATION: Why the original command failed
4. COMMAND BREAKDOWN: Explain each part of the corrected command
5. USAGE EXAMPLES: 3-5 practical examples of how to use this command correctly
6. COMMON MISTAKES: Other common errors with this command and how to avoid them
7. RELATED COMMANDS: Similar or complementary commands that might be useful

Respond in clean Markdown. Use fenced bash code blocks for commands (```bash). Ensure macOS compatibility."""
        else:
            # Just explain the command
            prompt = f"""You are an expert terminal command instructor. The user wants to learn about this command: {command}

Current system context:
- Working directory: {self.context.get('cwd', 'unknown')}
- Shell: {self.context.get('shell', 'unknown')}
- OS: {self.context.get('os', 'unknown')}

Provide a concise Markdown guide including:

1. COMMAND PURPOSE
2. BASIC SYNTAX with real examples
3. COMMON OPTIONS
4. 5-7 PRACTICAL EXAMPLES
5. ADVANCED USAGE
6. SAFETY NOTES
7. RELATED COMMANDS
8. TROUBLESHOOTING

Use fenced bash blocks for commands. Ensure macOS compatibility."""

        if self.client is None and self.openai_client is None:
            return "Error: No AI client is initialized. Please ensure the client is set."

        try:
            return self._generate_with_fallback(prompt)
        except Exception as e:
            return f"Error generating response: {str(e)}"

    def _generate_with_fallback(self, prompt: str) -> str:
        # Try Gemini with a strict timeout; otherwise fallback to OpenAI
        if self.client is not None:
            start = time.monotonic()
            spinner_stop = self._start_spinner(("Thinking", "Analysing"), interval=0.5)
            with concurrent.futures.ThreadPoolExecutor(max_workers=1) as pool:
                fut = pool.submit(self.client.models.generate_content, model=GEMINI_MODEL, contents=prompt)
                try:
                    resp = fut.result(timeout=7.0)
                    spinner_stop.set()
                    duration_ms = int((time.monotonic() - start) * 1000)
                    self.last_status = {"provider": "gemini", "reason": "ok", "duration_ms": duration_ms}
                    return getattr(resp, "text", str(resp))
                except concurrent.futures.TimeoutError:
                    spinner_stop.set()
                    # Gemini took too long: skip to OpenAI
                    self.last_status = {"provider": "openai", "reason": "timeout"}
                except Exception as e:
                    spinner_stop.set()
                    # Any 4xx/5xx or other errors: fallback to OpenAI
                    self.last_status = {"provider": "openai", "reason": "error", "error": str(e)}
        # OpenAI fallback with simple retry/backoff
        if self.openai_client is None:
            raise RuntimeError("OpenAI client is not initialized.")
        delay = 0.5
        last_exc = None
        start_openai = time.monotonic()
        spinner_stop = self._start_spinner(("Thinking", "Analysing"), interval=0.5)
        for _ in range(3):
            try:
                resp = self.openai_client.chat.completions.create(
                    model="gpt-5",
                    messages=[
                        {"role": "system", "content": "You are a helpful assistant."},
                        {"role": "user", "content": prompt},
                    ],
                    # temperature=1,
                    # max_completion_tokens=800,
                )
                text = resp.choices[0].message.content
                duration_ms = int((time.monotonic() - start_openai) * 1000)
                spinner_stop.set()
                if not self.last_status:
                    self.last_status = {"provider": "openai", "reason": "ok", "duration_ms": duration_ms}
                else:
                    self.last_status["duration_ms"] = duration_ms
                return text
            except Exception as exc:
                last_exc = exc
                time.sleep(delay)
                delay *= 2
        spinner_stop.set()
        raise last_exc if last_exc else RuntimeError("OpenAI fallback failed")

def main():
    if len(sys.argv) < 2:
        print("Usage: python3 ~/.ai_helper.py <mode> <input>")
        print("Modes: ask, debug, help, execute")
        sys.exit(1)
    
    mode = sys.argv[1]
    ai = TerminalAI()
    console = Console() if _RICH_AVAILABLE else None
    
    if mode == "ask":
        if len(sys.argv) < 3:
            print("Usage: aiask <question>")
            sys.exit(1)
        question = " ".join(sys.argv[2:])
        response = ai.ask_question(question)
        if console and ai.last_status and ai.last_status.get("provider") == "openai":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Skipping to another model: OpenAI (" + reason + ")[/bold magenta]")
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    elif mode == "debug":
        if len(sys.argv) < 3:
            print("Usage: aidebug <error_output>")
            sys.exit(1)
        error = " ".join(sys.argv[2:])
        response = ai.debug_issue(error)
        if console and ai.last_status and ai.last_status.get("provider") == "openai":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Skipping to another model: OpenAI (" + reason + ")[/bold magenta]")
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    elif mode == "help":
        if len(sys.argv) < 3:
            print("Usage: aihelp <command>")
            sys.exit(1)
        command = sys.argv[2]
        error_output = " ".join(sys.argv[3:]) if len(sys.argv) > 3 else None
        response = ai.help_command(command, error_output)
        if console and ai.last_status and ai.last_status.get("provider") == "openai":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Skipping to another model: OpenAI (" + reason + ")[/bold magenta]")
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    elif mode == "execute":
        if len(sys.argv) < 3:
            print("Usage: aiexecute <command>")
            sys.exit(1)
        command = " ".join(sys.argv[2:])
        response = ai.execute_and_analyze(command)
        if console and ai.last_status and ai.last_status.get("provider") == "openai":
            reason = ai.last_status.get("reason", "")
            console.print("[bold magenta]⏩ Skipping to another model: OpenAI (" + reason + ")[/bold magenta]")
        
        # Parse verdict from AI response and display it
        if isinstance(response, str) and not response.startswith("Error generating response:"):
            # Look for VERDICT: in the response
            if "VERDICT: SUCCESS" in response:
                if console:
                    console.print("✅ [bold green]Command executed successfully![/bold green]")
                else:
                    print("✅ Command executed successfully!")
            elif "VERDICT: FAILED" in response:
                if console:
                    console.print("❌ [bold red]Command failed![/bold red]")
                else:
                    print("❌ Command failed!")
            
            # Remove the VERDICT line from the response before displaying
            response = response.replace("VERDICT: SUCCESS", "").replace("VERDICT: FAILED", "").strip()
        
        if console:
            if isinstance(response, str) and response.startswith("Error generating response:"):
                console.print("[bold red]" + response + "[/bold red]")
            else:
                console.print(Markdown(response), style="default")
        else:
            print(response)
    
    else:
        print(f"Unknown mode: {mode}")
        print("Available modes: ask, debug, help, execute")
        sys.exit(1)

if __name__ == "__main__":
    main()
EOF
    
    chmod +x "$HOME/.ai_helper.py"
    
    echo "✅ AI Terminal Assistant installed successfully!"
    echo ""
    echo "🚀 Try these commands:"
    echo "  aistatus                    # Check installation"
    echo "  aiask how do I use git      # Ask a question"
    echo "  aihelp ls                   # Get help with ls command"
    
    # Test the installation
    aistatus
}

# Enhanced help system integration
help_ai() {
    echo "🤖 ${fg[cyan]}AI ASSISTANT COMMANDS${reset_color}"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    echo "${fg[yellow]}🗣️  ASK MODE:${reset_color}"
    echo "  ${fg[green]}aiask <question>${reset_color}      Ask AI any terminal/development question"
    echo ""
    echo "${fg[yellow]}🔧 DEBUG MODE:${reset_color}"
    echo "  ${fg[green]}aidebug <error>${reset_color}       Debug terminal errors and get solutions"
    echo ""
    echo "${fg[yellow]}📚 HELP MODE:${reset_color}"
    echo "  ${fg[green]}aihelp <command>${reset_color}      Execute command and get AI analysis"
    echo ""
    echo "${fg[yellow]}⚙️  SYSTEM:${reset_color}"
    echo "  ${fg[green]}aistatus${reset_color}              Check AI system status and configuration"
    echo "  ${fg[green]}install_ai_helper${reset_color}     Install/reinstall AI helper system"
    echo ""
    echo "${fg[blue]}💡 Examples:${reset_color}"
    echo "  aiask how to find files larger than 100MB"
    echo "  aidebug \"permission denied: /usr/local/bin\""
    echo "  aihelp find . -name '*.log'"
    echo "  aihelp git push origin main"
    echo ""
    echo "${fg[green]}🚀 Features:${reset_color}"
    echo "  • Context-aware responses based on your current directory and system"
    echo "  • Plain text output optimized for terminal use"
    echo "  • Command execution with immediate output display"
    echo "  • AI analysis with success/failure verdict"
    echo "  • Integration with your existing shell environment"
    echo "  • Comprehensive explanations with practical examples"
}

# -----------------------------------------------------------------------------
# CUSTOM PROJECT ALIASES (User requested)
# -----------------------------------------------------------------------------

# --- Env Activation ---
alias activate='source "/Users/{username}/Projects/Dennis Labs/Custom Nerd/customnerd/customnerd-backend/venv/bin/activate"'

# --- Project Shortcuts ---
alias dl='cd "/Users/{username}/Projects/Labs"'
alias proj='cd "/Users/{username}/Projects"'

## Terminal Activate
activate
