#! /bin/bash
# Script para inicialização do controle e acompanhamento de relacionamento com cliente

PATH_BASE="$(dirname $(realpath $0))"

source "${PATH_BASE}/config"
source "${PATH_BASE}/bash-ui"
source "${PATH_BASE}/biblioteca_funcoes"

# Execução
default
