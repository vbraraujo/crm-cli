#! /bin/bash

PATH_BASE="$HOME/Dropbox/RA-Compartilhamento/crm-cli"

PATH_CLIENTES_LISTA="${PATH_BASE}/clientes/.lista"
PATH_FUNIS="${PATH_BASE}/modulos"
MENU_INICIAL="Pesquisar cliente\nCadastrar cliente\nRelatórios\nSair"
DATA_HOJE="$(printf '%(%Y-%m-%d)T\n' -1)"
DATA_UMA_SEMANA="$(date --date="1 week" +"%Y-%m-%d")"
LISTA_FUNIL="$(find "${PATH_FUNIS}/" -name "*.funil" -printf "%f\n")"

limpa_numeros(){
    local tmp=${1//./}
    echo ${tmp//-/}
}

cadastrar_cliente(){
    nome="${1}"
    cpf="${2}"
    telefone="${3}"
    email="${4}"
    etiquetas="metro"
    status="Quente"

    # Organiza e cria estrutura para pasta do cliente
    destino="${PATH_BASE}/clientes/${cpf}"
    arquivo_principal="Nome: ${nome}\nCPF: ${cpf}\nTelefone: ${telefone}\nE-mail: ${email}\nStatus: ${status}\nEtiquetas: ${etiquetas}"
    cliente_lista="${nome}|${cpf}|${telefone}|${email}|${etiquetas}|${status}"

    mkdir "${destino}/"
    echo -e "$arquivo_principal" > "${destino}/cadastro"
    echo -e "$cliente_lista" >> "${PATH_BASE}/clientes/.lista"
    cadastrar_historico "$cpf" "Cliente cadastrado" "#manual"

    touch "${destino}/pendencias"
    touch "${destino}/funis"

    mkdir "${destino}/mails"
    mkdir "${destino}/mails/pendentes"
    mkdir "${destino}/mails/enviados"

    echo "$(tput setaf 2)[info] Cliente cadastrado com sucesso.$(tput sgr0)"
}

cadastrar_historico(){
    #Argumentos: 1 CPF, 2 descrição, 3 tags
    if [ "$#" -eq 3 ]
        then
            path_hist="${PATH_BASE}/clientes/${1}/historico"
            linha="$DATA_HOJE: $2 $3"
            echo -e "$linha" >> "$path_hist"

        else
            echo "Não foi possível criar anotação automática. Favor informar os dados a seguir."
            read -p "Descrição: " descricao
            read -p "CPF: " cpf
            read -p "Tags: " tags
            path_hist="${PATH_BASE}/clientes/${cpf}/historico"
            linha="$DATA_HOJE: $descricao $tags"
            echo -e "$linha" >> "$path_hist"
    fi
}

cadastrar_contatos(){
    cat "${1}" | while read line; do
        nome="$(echo -e "$line" | cut -d"," -f 1)"
        cpf="$(echo -e "$line" | cut -d"," -f 2)"
        cpf="$(limpa_numeros $cpf)"
        telefone="$(echo -e "$line" | cut -d"," -f 3)"
        email="$(echo -e "$line" | cut -d"," -f 4)"
        cadastrar_cliente "$nome" "$cpf" "$telefone" "$email"

    done
}

cadastrar_contatos "$1"
