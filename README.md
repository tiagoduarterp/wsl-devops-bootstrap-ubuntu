# install-wsl-tips.sh

## 🚀 Script de Configuração de Ambiente de Desenvolvimento para WSL/Linux

Este script automatiza a instalação e configuração de um ambiente de desenvolvimento completo para WSL (Windows Subsystem for Linux) ou distribuições Linux baseadas em Debian/Ubuntu e Fedora. Ideal para desenvolvedores que desejam produtividade máxima desde o primeiro uso!

---

## ⚡️ O que este script faz?

- Instala dependências essenciais do sistema (git, curl, unzip, etc)
- Instala e configura o [asdf](https://asdf-vm.com/) com plugins para:
  - Python
  - Node.js
  - Terraform
- Instala Docker e Docker Compose
- Instala AWS CLI e Azure CLI
- Instala utilitários de produtividade: zoxide, autojump, thefuck, bat, eza, kubens, k9s
- Configura aliases e funções úteis para Terraform, AWS, Kubernetes e produtividade
- Ajusta o prompt do shell para exibir a branch do Git

---

## 🛠️ Como usar

1. **Clone ou baixe este repositório**
2. Dê permissão de execução ao script:
   ```bash
   chmod +x install-wsl-tips.sh
   ```
3. Execute o script:
   ```bash
   ./install-wsl-tips.sh
   ```

> **Dica:** Execute o script com um usuário que tenha permissões de sudo.

---

## 📦 O que será instalado?

- **Dependências do sistema:** git, curl, unzip, build-essential, etc.
- **asdf:** Gerenciador de versões para Python, Node.js, Terraform
- **Docker & Docker Compose**
- **AWS CLI**
- **Azure CLI**
- **Utilitários:** zoxide, autojump, thefuck, bat, eza, kubens, k9s
- **Aliases e funções** para facilitar comandos do dia a dia

---

## 🧩 Aliases e Funções Úteis

- `produtividade` — Mostra dicas rápidas dos utilitários instalados
- Atalhos para Terraform: `tfwdev`, `tfwstg`, `tfwuat`, `tfwprd`, `tfpdev`, `tfadev`, etc.
- Atalhos para AWS: `awssso`, `profaws`, `prof`, `awsl`
- Atalhos para Kubernetes: `kc` (kubectl), `kubens`, `k9s`
- Atalhos de navegação: `z` (zoxide), `j` (autojump), `bat`, `eza`
- Prompt customizado com branch do Git

---

## 💡 Dicas pós-instalação

  ```bash
  source ~/.bashrc  # ou ~/.zshrc, dependendo do seu shell
  ```
  ```bash
  newgrp docker
  ```

---

## 🗂️ Dica extra: Limitando o tamanho do disco do WSL

Para evitar que o disco virtual do WSL cresça indefinidamente, você pode limitar o tamanho máximo do disco criando (ou editando) o arquivo `.wslconfig` no Windows. Siga os passos:

1. No Windows, abra o Bloco de Notas como administrador.
2. Salve o arquivo como `C:\Users\\<seu-usuario>\\.wslconfig` (substitua `<seu-usuario>` pelo seu nome de usuário do Windows).
3. Adicione o conteúdo abaixo para limitar o disco a, por exemplo, 200GB:
  ```ini
  [wsl2]
  # Limite máximo do disco virtual do WSL
  defaultVhdSize = 200GB
  ```
4. Reinicie todas as instâncias do WSL:
  ```powershell
  wsl --shutdown
  ```

> **Observação:** O limite só afeta o crescimento do disco. Se o disco já estiver maior, será necessário compactar manualmente.


## ☁️ Conectando-se a um cluster EKS (AWS) e usando kubens

Veja como conectar rapidamente ao seu cluster EKS e alternar entre namespaces:

### 1. Configure o acesso ao cluster EKS

Certifique-se de ter o AWS CLI e o kubectl configurados. Para obter as credenciais do cluster:

```bash
aws eks --region <regiao> update-kubeconfig --name <nome-do-cluster>
```

Exemplo:
```bash
aws eks --region us-east-1 update-kubeconfig --name meu-cluster-eks
```

### 2. Teste a conexão

```bash
kubectl get nodes
```

### 3. Liste os namespaces disponíveis

```bash
kubectl get ns
```

### 4. Troque de namespace com kubens

```bash
kubens <nome-do-namespace>
```

Exemplo:
```bash
kubens dev
```

> **Dica:** Use `kubens` sem argumentos para listar e selecionar interativamente o namespace.

## 📝 Observações

- O script detecta automaticamente o shell (`bash` ou `zsh`) e configura o arquivo de perfil correto.
- Para sistemas que não usam `apt-get` ou `dnf`, a instalação manual pode ser necessária.
- Algumas ferramentas podem exigir login ou configuração adicional após a instalação (ex: AWS CLI, Azure CLI).

---

## 👨‍💻 Autor

Script criado por Tiago Duarte. Sinta-se à vontade para sugerir melhorias ou abrir issues!

---

## 📄 Licença

MIT
