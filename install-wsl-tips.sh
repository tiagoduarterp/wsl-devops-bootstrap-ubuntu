#!/bin/bash

# ====================================================================================
# Script para Configuração de Ambiente de Desenvolvimento
#
# Ferramentas:
# - Dependências do sistema (git, curl, git-crypt, unzip, etc)
# - asdf (com plugins para Python, Node.js, Terraform, AWS CLI)
# - Azure CLI
# - Docker e Docker Compose
# - Configuração de aliases e funções de shell para Terraform, AWS, etc.
# ====================================================================================

# --- Cores para uma saída mais legível ---
COLOR_GREEN='\033[0;32m'
COLOR_YELLOW='\033[0;33m'
COLOR_BLUE='\033[0;34m'
COLOR_NC='\033[0m'

# --- Determina o arquivo de configuração do shell ---
if [ -n "$ZSH_VERSION" ]; then
    SHELL_PROFILE="$HOME/.zshrc"
else
    SHELL_PROFILE="$HOME/.bashrc"
fi

# ====================================================================================
# FUNÇÃO: Instalar dependências do sistema
# ====================================================================================
install_system_dependencies() {
    echo -e "${COLOR_BLUE}Verificando e instalando dependências do sistema...${COLOR_NC}"
    if command -v apt-get &>/dev/null; then
        sudo apt-get update
        sudo apt-get install -y git curl wget gpg gnupg unzip ca-certificates lsb-release build-essential libssl-dev zlib1g-dev libbz2-dev \
        libreadline-dev libsqlite3-dev llvm libncurses-dev xz-utils tk-dev libxml2-dev fzf libxmlsec1-dev libffi-dev liblzma-dev git-crypt \
        zoxide autojump thefuck bat eza

        if ! command -v kubens &>/dev/null; then
            echo -e "${COLOR_BLUE}Instalando kubens...${COLOR_NC}"
            sudo git clone https://github.com/ahmetb/kubectx /opt/kubectx || true
            sudo ln -sf /opt/kubectx/kubens /usr/local/bin/kubens
            sudo ln -sf /opt/kubectx/kubectx /usr/local/bin/kubectx
        fi

        if ! command -v k9s &>/dev/null; then
            echo -e "${COLOR_BLUE}Instalando k9s...${COLOR_NC}"
            curl -sS https://webi.sh/k9s | sh
            if [ -f "$HOME/.local/bin/k9s" ] && [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
                echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$SHELL_PROFILE"
                source "$SHELL_PROFILE"
            fi
        fi

    elif command -v dnf &>/dev/null; then
        sudo dnf check-update
        sudo dnf install -y git curl wget gpg gnupg unzip ca-certificates "Development Tools" openssl-devel zlib-devel bzip2-devel \
        readline-devel sqlite-devel ncurses-devel xz-devel tk-devel libxml2-devel libxmlsec1-devel libffi-devel xz-devel git-crypt \
        zoxide autojump thefuck bat eza
    else
        echo -e "${COLOR_YELLOW}Gerenciador de pacotes não suportado. Por favor, instale as dependências manualmente.${COLOR_NC}"
        exit 1
    fi
    echo -e "${COLOR_GREEN}Dependências do sistema instaladas com sucesso.${COLOR_NC}\n"
    echo -e "${COLOR_YELLOW}Dicas de uso dos utilitários instalados:${COLOR_NC}"
    echo -e "- zoxide (z): navegue rapidamente entre diretórios com 'z <nome-parcial-do-diretório>'"
    echo -e "- autojump: use 'j <nome-parcial-do-diretório>' para pular para diretórios usados frequentemente"
    echo -e "- thefuck: corrija comandos digitados errado digitando 'fuck' após um erro"
    echo -e "- bat: visualize arquivos com syntax highlight usando 'bat <arquivo>' (substitui 'cat')"
    echo -e "- eza: liste arquivos de forma aprimorada com 'eza' (substitui 'ls')"
    echo -e "- kubens: troque rapidamente de namespace com 'kubens <namespace>'"
    echo -e "- k9s: interface interativa para Kubernetes, execute 'k9s'"
    echo -e ""
}
# ====================================================================================
# FUNÇÃO: Instalar asdf e seus plugins
# ====================================================================================
install_asdf() {
    if [ -d "$HOME/.asdf" ]; then
        echo -e "${COLOR_YELLOW}Pasta do asdf já existe. Pulando a clonagem.${COLOR_NC}\n"
    else
        echo -e "${COLOR_BLUE}Instalando asdf...${COLOR_NC}"
        git clone https://github.com/asdf-vm/asdf.git ~/.asdf --branch v0.14.0
        
        echo -e '\n. $HOME/.asdf/asdf.sh' >> "$SHELL_PROFILE"
        echo -e '. $HOME/.asdf/completions/asdf.bash' >> "$SHELL_PROFILE"
        echo -e "${COLOR_GREEN}asdf instalado com sucesso.${COLOR_NC}\n"
    fi

    if [ -f "$HOME/.asdf/asdf.sh" ]; then
        source "$HOME/.asdf/asdf.sh"
        source "$HOME/.asdf/completions/asdf.bash"
    else
        echo -e "${COLOR_YELLOW}ERRO: Não foi possível encontrar o script asdf.sh para carregar.${COLOR_NC}"
        return 1
    fi

    echo -e "${COLOR_BLUE}Instalando plugins do asdf (python, nodejs, terraform, awscli)...${COLOR_NC}"
    asdf plugin-add nodejs https://github.com/asdf-vm/asdf-nodejs.git || true
    asdf plugin-add python || true
    asdf plugin-add terraform https://github.com/asdf-community/asdf-hashicorp.git || true

    echo -e "${COLOR_BLUE}Instalando as últimas versões estáveis...${COLOR_NC}"
    asdf install python latest
    asdf install nodejs latest
    asdf install terraform latest

    echo -e "${COLOR_BLUE}Definindo as versões globais...${COLOR_NC}"
    asdf global python latest
    asdf global nodejs latest
    asdf global terraform latest

    echo -e "${COLOR_GREEN}asdf e plugins configurados com sucesso.${COLOR_NC}\n"
}

# ====================================================================================
# FUNÇÃO: Instalar Docker e Docker Compose
# ====================================================================================
install_docker() {
    if command -v docker &>/dev/null; then
        echo -e "${COLOR_YELLOW}Docker já está instalado. Pulando.${COLOR_NC}\n"
    else
        echo -e "${COLOR_BLUE}Instalando Docker e Docker Compose...${COLOR_NC}"

        sudo install -m 0755 -d /etc/apt/keyrings
        curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
        sudo chmod a+r /etc/apt/keyrings/docker.gpg
        echo \
          "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu \
          $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
          sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
        sudo apt-get update

        sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
        echo -e "${COLOR_GREEN}Docker e Docker Compose instalados com sucesso.${COLOR_NC}\n"
    fi
    
    if ! getent group docker | grep -q "\b$USER\b"; then
        echo -e "${COLOR_BLUE}Adicionando usuário '$USER' ao grupo 'docker'...${COLOR_NC}"
        sudo usermod -aG docker $USER
        echo -e "${COLOR_YELLOW}Você precisa reiniciar seu terminal ou executar 'newgrp docker' para que as permissões do Docker tenham efeito.${COLOR_NC}\n"
    else
        echo -e "${COLOR_YELLOW}Usuário já pertence ao grupo docker.${COLOR_NC}\n"
    fi
}

# ====================================================================================
# FUNÇÃO: Instala AWS CLI
# ====================================================================================
install_aws() {
    if command -v aws &>/dev/null; then
        echo -e "${COLOR_YELLOW}AWS CLI já está instalado. Versão: $(aws --version)${COLOR_NC}\n"
        return 0
    fi

    echo -e "${COLOR_BLUE}Instalando AWS CLI...${COLOR_NC}"

    local temp_dir
    temp_dir=$(mktemp -d)
    
    trap 'rm -rf "$temp_dir"' RETURN

    (
        cd "$temp_dir" && \
        curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
        unzip -q awscliv2.zip && \
        sudo ./aws/install
    )

    if [ $? -eq 0 ]; then
        echo -e "${COLOR_GREEN}AWS CLI instalado com sucesso. Versão: $(aws --version)${COLOR_NC}\n"
    else
        echo -e "\033[0;31mFalha na instalação do AWS CLI.${COLOR_NC}\n"
        return 1
    fi
}

# ====================================================================================
# FUNÇÃO: Instalar Kubectl
# ====================================================================================
install_kubectl() {
    if command -v kubectl &>/dev/null; then
        echo -e "${COLOR_YELLOW}kubectl já está instalado. Versão: $(kubectl version --client --short)${COLOR_NC}\n"
        return 0
    fi

    echo -e "${COLOR_BLUE}Instalando kubectl...${COLOR_NC}"

    if curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"; then
        
        curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl.sha256"
        
        if echo "$(cat kubectl.sha256) kubectl" | sha256sum --check --strict; then
            
            sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl
            
            if command -v kubectl &>/dev/null; then
                echo -e "${COLOR_GREEN}kubectl instalado com sucesso. Versão: $(kubectl version --client --short)${COLOR_NC}\n"
                rm kubectl kubectl.sha256
            else
                echo -e "\033[0;31mERRO: Falha ao mover o kubectl para /usr/local/bin/.${COLOR_NC}\n"
                rm kubectl kubectl.sha256
                return 1
            fi
        else
            echo -e "\033[0;31mERRO: Checksum do kubectl inválido! O arquivo pode estar corrompido ou ter sido adulterado. Abortando.${COLOR_NC}\n"
            rm kubectl kubectl.sha256
            return 1
        fi
    else
        echo -e "\033[0;31mERRO: Falha no download do kubectl.${COLOR_NC}\n"
        return 1
    fi
}

# ====================================================================================
# FUNÇÃO: Instalar Azure CLI
# ====================================================================================
install_azure_cli() {
    if command -v az &>/dev/null; then
        echo -e "${COLOR_YELLOW}Azure CLI (az) já está instalado. Pulando.${COLOR_NC}\n"
    else
        echo -e "${COLOR_BLUE}Instalando Azure CLI...${COLOR_NC}"
        if command -v apt-get &>/dev/null; then
            curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
            echo -e "${COLOR_GREEN}Azure CLI instalado com sucesso.${COLOR_NC}\n"
        else
            echo -e "${COLOR_YELLOW}A instalação automática do Azure CLI é suportada apenas para sistemas baseados em Debian/Ubuntu. Por favor, instale manualmente.${COLOR_NC}"
        fi
    fi
}


# ====================================================================================
# FUNÇÃO: Configurar aliases e funções
# ====================================================================================
setup_aliases() {
    echo -e "${COLOR_BLUE}Configurando aliases e funções no $SHELL_PROFILE...${COLOR_NC}"
    
    ALIAS_MARKER="# DEV_ALIASES_CONFIGURED_BY_SCRIPT"

    if grep -q "$ALIAS_MARKER" "$SHELL_PROFILE"; then
        echo -e "${COLOR_YELLOW}Aliases já parecem estar configurados. Pulando.${COLOR_NC}\n"
    else
    
    cat << 'EOF' >> "$SHELL_PROFILE"

# DEV_ALIASES_CONFIGURED_BY_SCRIPT
# ==========================================================
# Atalhos para Terraform, AWS, e outros utilitários

# --- PRODUTIVIDADE ---
alias produtividade='echo "\
zoxide (z): navegue rapidamente entre diretórios com \"z <nome-parcial-do-diretório>\"\n\
autojump: use \"j <nome-parcial-do-diretório>\" para pular para diretórios usados frequentemente\n\
thefuck: corrija comandos digitados errado digitando \"fuck\" após um erro\n\
bat: visualize arquivos com syntax highlight usando \"bat <arquivo>\" (substitui \"cat\")\n\
exa: liste arquivos de forma aprimorada com \"exa\" (substitui \"ls\")\n\
kubens: troque rapidamente de namespace com \"kubens <namespace>\"\n\
k9s: interface interativa para Kubernetes, execute \"k9s\"\n\
"'

# --- TERRAFORM ---
alias tfwdev="terraform workspace select dev"
alias tfwstg="terraform workspace select stg"
alias tfwuat="terraform workspace select uat"
alias tfwprd="terraform workspace select prd"

alias tfwl="terraform workspace list"

alias tfidev="terraform init -backend-config=dev-backend.hcl"
alias tfistg="terraform init -backend-config=stg-backend.hcl"
alias tfiuat="terraform init -backend-config=uat-backend.hcl"
alias tfiprd="terraform init -backend-config=prd-backend.hcl"

alias tfpdev="terraform plan -var-file=environments/dev.tfvars"
alias tfpstg="terraform plan -var-file=environments/stg.tfvars"
alias tfpuat="terraform plan -var-file=environments/uat.tfvars"
alias tfpprd="terraform plan -var-file=environments/prd.tfvars"

alias tfadev="terraform apply -var-file=environments/dev.tfvars"
alias tfastg="terraform apply -var-file=environments/stg.tfvars"
alias tfauat="terraform apply -var-file=environments/uat.tfvars"
alias tfaprd="terraform apply -var-file=environments/prd.tfvars"

# ntpdate é obsoleto, mas mantido conforme solicitado.
# Em sistemas modernos, considere usar 'sudo chronyc -a makestep' ou 'sudo timedatectl set-ntp true'
alias dateu="sudo ntpdate pool.ntp.org"

alias cd-iz='cd ~/development/izio'
alias cd-ya='cd ~/development/yandev'
alias cd-hi='cd ~/development/hindiana-yhub'
alias tf='terraform'
alias awsl='cat ~/.aws/config | grep profile'

# --- AWS ---
alias prof="echo \$AWS_PROFILE"
alias awssso="aws sso login --profile"

profaws() {
    export AWS_PROFILE="$1"
    echo "Perfil AWS_PROFILE AWS definido como: $AWS_PROFILE"
}

# --- KUBECTL ---
alias kc="kubectl"

# --- HELP ---
alias alh='echo "
awssso      - Faz login no AWS SSO com o perfil (ex: awssso my-profile).
profaws     - Seta o profile na variável de ambiente AWS_PROFILE (ex: profaws my-profile).
prof        - Mostra o profile AWS atualmente setado.

tfwdev      - Seleciona o workspace Terraform para dev.
tfwstg      - Seleciona o workspace Terraform para stg.
tfwuat      - Seleciona o workspace Terraform para uat.
tfwprd      - Seleciona o workspace Terraform para prd.
tfwl        - Lista os workspaces Terraform disponíveis.

tfidev      - Inicializa o backend Terraform para dev.
tfistg      - Inicializa o backend Terraform para stg.
tfiuat      - Inicializa o backend Terraform para uat.
tfiprd      - Inicializa o backend Terraform para prd.

tfpdev      - Executa terraform plan usando dev.tfvars.
tfpstg      - Executa terraform plan usando stg.tfvars.
tfpuat      - Executa terraform plan usando uat.tfvars.
tfpprd      - Executa terraform plan usando prd.tfvars.

tfadev      - Aplica o terraform usando dev.tfvars.
tfastg      - Aplica o terraform usando stg.tfvars.
tfauat      - Aplica o terraform usando uat.tfvars.
tfaprd      - Aplica o terraform usando prd.tfvars.

kc          - Atalho para kubectl.
dateu       - Sincroniza a data e hora do sistema (pode exigir sudo).
"'
# ==========================================================

# --- Função para mostrar a branch do Git no prompt ---
# Primeiro, cria uma função que busca o nome da branch
parse_git_branch() {
    # Busca o nome da branch e formata a saída
    git branch --show-current 2>/dev/null | sed 's#^# (#' | sed 's#$#)#'
}

# --- Define a aparência do prompt (PS1) ---
# Adiciona cores e chama a função parse_git_branch
# \u = usuário, \h = nome da máquina, \w = diretório atual
export PS1='\[\033[01;32m\]\u@\h\[\033[00m\]:\[\033[01;34m\]\W\[\033[00m\]\[\033[33m\]$(parse_git_branch)\[\033[00m\]$ '

EOF
        echo -e "${COLOR_GREEN}Aliases e funções configurados com sucesso.${COLOR_NC}\n"
    fi
}


# ====================================================================================
# FUNÇÃO PRINCIPAL
# ====================================================================================
main() {
    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}"
    echo -e "${COLOR_GREEN}  Iniciando a Configuração do Ambiente de Dev       ${COLOR_NC}"
    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}\n"

    install_system_dependencies
    install_asdf
    install_docker
    install_azure_cli
    setup_aliases
    install_aws
    install_kubectl

    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}"
    echo -e "${COLOR_GREEN}      Configuração Concluída com Sucesso!            ${COLOR_NC}"
    echo -e "${COLOR_GREEN}=====================================================${COLOR_NC}\n"
    echo -e "${COLOR_YELLOW}AÇÃO NECESSÁRIA:${COLOR_NC}"
    echo -e "Para que todas as alterações tenham efeito, por favor, feche e reabra seu terminal,"
    echo -e "ou execute o seguinte comando:"
    echo -e "${COLOR_BLUE}source $SHELL_PROFILE${COLOR_NC}\n"
    echo -e "Para as permissões do Docker, pode ser necessário reiniciar a sessão (logout/login) ou rodar:"
    echo -e "${COLOR_BLUE}newgrp docker${COLOR_NC}\n"
}


main