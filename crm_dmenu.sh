#!/usr/bin/env bash
# Script para pesquisa de clientes usando o dmenu

DMENU_OPT="-sb #e60053 -i -l 15"
PATH_BASE="$(dirname $(realpath $0))"

pc_lista="Cadastrar novo cliente\n"
pc_lista+="$(awk -F\| '{ print $1"|"$2"|"$3"|"$7 }' ${PATH_BASE}/clientes/.lista )"
selected="$(printf "$pc_lista" | dmenu $DMENU_OPT -p Cliente: )"
case "$selected" in
    "")
        return
        ;;
    "Cadastrar novo cliente")
        terminator -e "~/bin/crm_cli -c" -T "dropdown_crm" --geometry=480x988
        ;;
    *)
        cpf="$(echo "$selected" | cut -d\| -f2 )"
        terminator -e "~/bin/crm_cli -p $cpf" -T "dropdown_crm" --geometry=480x988
    ;;
esac
