#! /bin/bash
#

# Variáveis do sistema
MENU_INICIAL="01. Pesquisar cliente\n02. Cadastrar cliente\n03. Sair"
DATA_HOJE="$(printf '%(%Y-%m-%d)T\n' -1)"

# Funções
divider(){
    printf "%$(tput cols)s\n" | tr ' ' '_'
}

verifica_amb(){
    echo "[info] Verificando ambiente..."
}

menu_inicial(){
    selected="$(echo -e $MENU_INICIAL | fzf --prompt 'Selecione uma opção: ')"
    case "$selected" in
        "01. Pesquisar cliente")
            pesquisar_cliente
            ;;
        "02. Cadastrar cliente")
            cadastrar_cliente
            ;;
        *)
            exit
            ;;
    esac
}

pesquisar_cliente(){
    cpf="$(cat clientes/.lista | cut -d\| -f 1-3 | fzf --prompt 'Pesquisar: ' | cut -d\| -f2)"
    clear
    echo "DADOS DO CLIENTE"
    cat "clientes/${cpf}/cadastro"
    divider
    echo "PENDÊNCIAS"
    divider
    echo "NEGÓCIOS"
    divider
    echo "HISTÓRICO"
    divider
}

cadastrar_cliente(){
    echo Cadastrar cliente
    read -p "Nome: " nome
    read -p "CPF: " cpf
    read -p "Telefone: " telefone
    read -p "E-mail: " email

    # Organiza e cria estrutura para pasta do cliente
    destino="clientes/${cpf}/"
    arquivo_principal="Nome: ${nome}\nCPF: ${cpf}\nTelefone: ${telefone}\nE-mail: ${email}"
    arquivo_historico="${DATA_HOJE}: Cliente cadastrado"
    cliente_lista="${nome}|${cpf}|${telefone}|${email}"

    mkdir "$destino"
    echo -e "$arquivo_principal" > "${destino}cadastro"
    echo -e "$arquivo_historico" > "${destino}histórico"
    echo -e "$cliente_lista" >> clientes/.lista

    echo "$(tput setaf 2)[info] Cliente cadastrado com sucesso.$(tput sgr0)"
}

default () {
    while true
    do
        menu_inicial
        read -n1
    done
}

# Execução
default

echo "---"
echo "$(tput setaf 2)[info] Concluído com sucesso. Até logo.$(tput sgr0)"
