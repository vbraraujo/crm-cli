#! /bin/bash

#PATH_BASE="/mnt/Arquivos/Downloads/fichas"
PATH_BASE="/mnt/Arquivos/Downloads/teste"

PATH_CLIENTES_LISTA="${PATH_BASE}/clientes/.lista"
DATA_HOJE="$(printf '%(%Y-%m-%d)T\n' -1)"

limpa_numeros(){
    local tmp=${1//./}
    echo ${tmp//-/}
}

criar_ficha_cadastro(){

    while read line; do
        cadastro_content="$(echo "$line" | awk -F"';'" '{ if ( $11 == "DESLIGADO" ) { tag = "ex-metro" }
        else { tag = "metro" }
            print "Nome: "$2"\nCPF: "$27"\nTelefone: "$21"\nE-mail: \nStatus: Neutro\nEtiquetas: "tag"\nEstado civil: "$29"\nProfissão: metroviário(a)\nRG: "$23"\nEndereço: "$16, $17, $18, $19 "\nCEP: "$20"\nMatrícula: "$1"\nCargo: "$3"\nFunção gratificada: "$4"\nSituação funcional: "$5"\nHoras base mensal: "$6"\nHoras base semanal: "$7"\nHoras base acordo: "$8"\nPericulosidade: "$9"\nInsalubridade: "$10"\nSituação: "$11"\nData de exon/dem/falecimento: "$13"\nData de nascimento: "$14"\nData de admissão: "$15"\nEscolaridade: "$22"\nTitulo eleitoral: "$24"\nNaturalidade: "$25"\nSexo: "$26"\nPIS/PASEP: "$27"\nConjuge: "$30"\nPai: "$31"\nMãe: "$32"\nDados bancários: "$33 
        }')"
        cpf="$( awk -F"';'" '{ print $27 }' <<< "$line" )"
        destino="$HOME/Downloads/fichas/clientes/${cpf}"
        echo "$destino"
        [[ -d $destino ]] && echo -e "$cadastro_content" > "${destino}/cadastro"
    done < "${1}"
}

completar_cadastro () {
    for folder in ./* ; do
        echo -e "Matrícula: \nCargo: \nFunção gratificada: \nSituação funcional: \nHoras base mensal: \nHoras base semanal: \nHoras base acordo: \nPericulosidade: \nInsalubridade: \nSituação: \nData de exon/dem/falecimento: \nData de nascimento: \nData de admissão: \nEscolaridade: \nTitulo eleitoral: \nNaturalidade: \nSexo: \nPIS/PASEP: \nConjuge: \nPai: \nMãe: \nDados bancários: " >> "${folder}/cadastro"
    done 
}

completar_cadastro
echo "$(tput setaf 2)[info] Cliente cadastrado com sucesso.$(tput sgr0)"
