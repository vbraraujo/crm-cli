#! /bin/bash
# Script para controle e acompanhamento de relacionamento com cliente

# Variáveis do sistema
PATH_BASE="$HOME/bin/crm-cli"
PATH_CLIENTES_LISTA="${PATH_BASE}/clientes/.lista"
MENU_INICIAL="Pesquisar cliente\nCadastrar cliente\nSair"
DATA_HOJE="$(printf '%(%Y-%m-%d)T\n' -1)"
DATA_UMA_SEMANA="$(date --date="1 week" +"%Y-%m-%d")"

# Funções
divider(){
    printf "%$(tput cols)s\n" | tr ' ' '_'
}

verifica_amb(){
    echo "[info] Verificando ambiente..."
}

menu_inicial(){
    selected="$(echo -e $MENU_INICIAL | fzf --height=30% --layout=default --prompt 'Selecione uma opção: ')"
    case "$selected" in
        "Pesquisar cliente")
            pesquisar_cliente
            ;;
        "Cadastrar cliente")
            cadastrar_cliente
            ;;
        *)
            exit
            ;;
    esac
}

menu_edicao(){
    #Argumentos: 1 CPF
    conteudo_atual="$(egrep "\|${1}\|" "$PATH_CLIENTES_LISTA")"
    me_nome="$(echo "$conteudo_atual" | cut -d\| -f1)"
    me_cpf="$(echo "$conteudo_atual" | cut -d\| -f2)"
    me_telefone="$(echo "$conteudo_atual" | cut -d\| -f3)"
    me_email="$(echo "$conteudo_atual" | cut -d\| -f4)"
    me_etiquetas="$(echo "$conteudo_atual" | cut -d\| -f5)"

    menu_edicao="Editar Nome\nEditar CPF\nEditar Telefone\nEditar E-mail\nIncluir Histórico\nIncluir Negócio\nIncluir Pendência\nConcluir Pendência\nVoltar"

    selected="$(echo -e $menu_edicao | fzf --height=30% --layout=default --prompt 'Selecione uma opção: ')"
    case "$selected" in
        "Editar Nome")
            read -e -p "Informe o novo nome: " -i "${me_nome}" novo_valor
            editar_cliente "${1}" "nome" "${novo_valor}"
            ;;
        "Editar Telefone")
            read -e -p "Informe o novo telefone: " -i "${me_telefone}" novo_valor
            editar_cliente "${1}" "telefone" "${novo_valor}"
            ;;
        "Editar E-mail")
            read -e -p "Informe o novo e-mail: " -i "${me_email}" novo_valor
            editar_cliente "${1}" "email" "${novo_valor}"
            ;;
        "Editar CPF")
            read -e -p "Informe o novo CPF: " -i "${1}" novo_valor
            editar_cliente "${1}" "cpf" "${novo_valor}"
            ;;
        "Editar Etiquetas")
            read -e -p "Informe as novas etiquetas: " -i "${me_etiquetas}" novo_valor
            editar_cliente "${1}" "etiquetas" "${novo_valor}"
            ;;
        "Incluir Histórico")
            read -p "Informe o histórico: " novo_valor
            cadastra_historico "${1}" "${novo_valor}" "#manual"
            ;;
        "Incluir Negócio")
            echo "Negócio"
            ;;
        "Incluir Pendência")
            read -p "Informe a pendência: " novo_valor
            cadastra_pendencia "${1}" "${DATA_UMA_SEMANA}" "manual" "${novo_valor}"
            ;;
        "Concluir Pendência")
            path_pend="${PATH_BASE}/clientes/${1}/pendencias"
            cp_lista="Voltar\n"
            cp_lista+="$(cat "${path_pend}" | cut -d\| -f1,3,6)"
            cp_id="$(echo -e "$cp_lista" | fzf --height=30% --layout=default --prompt 'Selecione pendencia a ser concluída: ' | cut -d\| -f1)"
            [[ $cp_id == "Voltar" ]] && pesquisar_cliente ${1} || concluir_pendencia "${1}" "${cp_id}"
            ;;
        *)
            default
            ;;
    esac
}

cadastra_historico(){
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

cadastra_pendencia(){
    #Argumentos: 1 CPF, 2 limite, 3 origem, 4 descrição
    if [ "$#" -eq 4 ]
        then
            path_pend="${PATH_BASE}/clientes/${1}/pendencias"
            cp_id="$(awk '{id=$1+1}END{print id}' ${path_pend})"
            [[ ${cp_id} == "" ]] && ${cp_id}=1
            #Linha: data | limite | origem | cpf | descrição
            linha="${cp_id}|${DATA_HOJE}|${2}|${3}|${1}|${4}"
            echo -e "$linha" >> "$path_pend"
            cadastra_historico "${1}" "Criada pendência [${4}]" "#auto"
            pesquisar_cliente ${1}

        else
            echo "Não foi possível criar pendência automática. Favor informar os dados a seguir."
            read -p "Descrição: " descricao
            read -p "CPF: " cpf
            path_pend="${PATH_BASE}/clientes/${cpf}/pendencias"
            cp_id="$(awk '{id=$1+1}END{print id}' ${path_pend})"
            [[ ${cp_id} == "" ]] && ${cp_id}=1
            linha="${cp_id}|${DATA_HOJE}|${DATA_UMA_SEMANA}|manual|${cpf}|${descricao}"
            echo -e "$linha" >> "$path_pend"
            cadastra_historico "${1}" "Criada pendência [${descricao}]" "#manual"
            pesquisar_cliente ${1}
    fi
}

concluir_pendencia(){
    #Argumentos: 1 CPF, 2 Id da pendência
    if [ "$#" -eq 2 ]
        then
            path_pend="${PATH_BASE}/clientes/${1}/pendencias"
            cp_descricao="$(egrep "^${2}\|" ${path_pend} | cut -d\| -f 6)"
            sed -i -E "/^${2}\|/d" "${path_pend}"
            cadastra_historico "${1}" "Concluída pendência [${cp_descricao}]" "#auto"
            pesquisar_cliente ${1}
    fi

}

pesquisar_cliente(){
    if [ "$#" -eq 1 ]
    then
        cpf="${1}"
    else
        cpf="$(cat ${PATH_BASE}/clientes/.lista | cut -d\| -f 1-3 | fzf --prompt 'Pesquisar: ' | cut -d\| -f2)"
    fi

    path_cliente="${PATH_BASE}/clientes/${cpf}/"
    clear
    echo "DADOS DO CLIENTE"
    cat "${path_cliente}cadastro"
    divider
    echo "PENDÊNCIAS"
    cat "${path_cliente}pendencias" | cut -d\| -f 3,6 | sed "s/|/: /g"
    divider
    echo "NEGÓCIOS"
    divider
    echo "HISTÓRICO"
    tail -n15 "${path_cliente}historico"
    divider
    menu_edicao "${cpf}"
}

cadastrar_cliente(){
    echo Cadastrar cliente
    read -p "Nome: " nome
    unset cpf
    while [[ -z ${cpf} ]]; do
        read -p "CPF: " cpf && [ -z "$cpf" ]
    done
    read -p "Telefone: " telefone
    read -p "E-mail: " email
    read -p "Etiquetas: " etiquetas

    # Organiza e cria estrutura para pasta do cliente
    destino="${PATH_BASE}/clientes/${cpf}"
    arquivo_principal="Nome: ${nome}\nCPF: ${cpf}\nTelefone: ${telefone}\nE-mail: ${email}\nEtiquetas: ${etiquetas}"
    cliente_lista="${nome}|${cpf}|${telefone}|${email}|${etiquetas}"

    mkdir "${destino}/"
    echo -e "$arquivo_principal" > "${destino}/cadastro"
    echo -e "$cliente_lista" >> "${PATH_BASE}/clientes/.lista"
    cadastra_historico "$cpf" "Cliente cadastrado" "#auto"

    touch "${destino}/pendencias"
    touch "${destino}/negocios"

    echo "$(tput setaf 2)[info] Cliente cadastrado com sucesso.$(tput sgr0)"
    #sleep 3
    menu_inicial
}

editar_cliente(){
    #Argumentos: 1 cpf, 2 campo a ser editado, 3 novo valor
    path_cliente="${PATH_BASE}/clientes/${1}/cadastro"
    conteudo_atual="$(egrep "\|${1}\|" "$PATH_CLIENTES_LISTA")"
    ec_nome="$(echo "$conteudo_atual" | cut -d\| -f1)"
    ec_cpf="$(echo "$conteudo_atual" | cut -d\| -f2)"
    ec_telefone="$(echo "$conteudo_atual" | cut -d\| -f3)"
    ec_email="$(echo "$conteudo_atual" | cut -d\| -f4)"
    ec_etiquetas="$(echo "$conteudo_atual" | cut -d\| -f5)"

    case "$2" in
        "nome")
            conteudo_novo="${3}|${ec_cpf}|${ec_telefone}|${ec_email}|${ec_etiquetas}"
            sed -i "/${ec_cpf}/c\\${conteudo_novo}" "${PATH_CLIENTES_LISTA}"
            sed -i -E "/^Nome: /c\\Nome: ${3}" "${path_cliente}"
            cadastra_historico "${ec_cpf}" "Nome alterado de [${ec_nome}] para [${3}]" "#auto"
            pesquisar_cliente "${ec_cpf}"
            ;;
        "cpf")
            conteudo_novo="${ec_nome}|${3}|${ec_telefone}|${ec_email}|${ec_etiquetas}"
            sed -i "/${ec_cpf}/c\\${conteudo_novo}" "${PATH_CLIENTES_LISTA}"
            sed -i -e "/^CPF: /c\\CPF: ${3}" "${path_cliente}"
            mv "${PATH_BASE}/clientes/${1}" "${PATH_BASE}/clientes/${3}"
            cadastra_historico "${3}" "CPF alterado de [${ec_cpf}] para [${3}]" "#auto"
            pesquisar_cliente "${3}"
            ;;
        "telefone")
            conteudo_novo="${ec_nome}|${ec_cpf}|${3}|${ec_email}|${ec_etiquetas}"
            sed -i "/${ec_cpf}/c\\${conteudo_novo}" "${PATH_CLIENTES_LISTA}"
            sed -i -E "/^Telefone: /c\\Telefone: ${3}" "${path_cliente}"
            cadastra_historico "${ec_cpf}" "Telefone alterado de [${ec_telefone}] para [${3}]" "#auto"
            pesquisar_cliente "${ec_cpf}"
            ;;
        "email")
            conteudo_novo="${ec_nome}|${ec_cpf}|${ec_telefone}|${3}|${ec_etiquetas}"
            sed -i "/${ec_cpf}/c\\${conteudo_novo}" "${PATH_CLIENTES_LISTA}"
            sed -i -E "/^E-mail: /c\\E-mail: ${3}" "${path_cliente}"
            cadastra_historico "${ec_cpf}" "E-mail alterado de [${ec_email}] para [${3}]" "#auto"
            pesquisar_cliente "${ec_cpf}"
            ;;
        "etiquetas")
            conteudo_novo="${ec_nome}|${ec_cpf}|${ec_telefone}|${ec_email}|${3}"
            sed -i "/${ec_cpf}/c\\${conteudo_novo}" "${PATH_CLIENTES_LISTA}"
            sed -i -E "/^Etiquetas: /c\\Etiquetas: ${3}" "${path_cliente}"
            cadastra_historico "${ec_cpf}" "Etiquetas alteradas de [${ec_etiquetas}] para [${3}]" "#auto"
            pesquisar_cliente "${ec_cpf}"
            ;;

    esac

}
default () {
    while true
    do
        clear
        echo "$(tput setaf 2)CRM - Seja bem vindo.$(tput sgr0)"
        divider
        echo "PENDÊNCIAS"
        cat ${PATH_BASE}/*/*/pendencias | cut -d\| -f 3,5,6 | sed "s/|/: /g"
        divider
        menu_inicial
        read -n1
    done
}

# Execução
default

echo "---"
echo "$(tput setaf 2)[info] Concluído com sucesso. Até logo.$(tput sgr0)"
