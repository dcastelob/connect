#!/bin/bash
# script para conexão remota com base em catálogo de hosts
 
# variáveis globais
G_ALTURA=80
G_LARGURA=80

G_SITES_PATH="connect_sites.d"
G_HOSTS_PATH="connect_hosts.d"

G_ITENS_MENU=10

USER=""
PASSWD=""
PORT="22"

#HOSTS="hosts.conf"

function get_sites()
{
    for F in $(ls -1 ${G_SITES_PATH}/*.conf); do
        TXT+="${F} $(basename ${F}| sed "s/.conf//g") "
    done
    echo "${TXT}"
}

function get_param()
{
    FILE="$1"
    CHAVE="$2"
    grep "^${CHAVE}" "${FILE}" | sed "s/[ ]*=[ ]*/=/g" |awk -F "=" '{print $2}'
}

function get_site_param()
{
    FILE="$1"     
    export SRC_NAME=$(get_param "${FILE}" "src_name")
    export SRC_ADDRESS=$(get_param "${FILE}" "src_address")
    export SRC_USER=$(get_param "${FILE}" "src_user")
    export SRC_PASSWD=$(get_param "${FILE}" "src_passwd")
    export SRC_HOSTS=$(get_param "${FILE}" "src_hosts")

    export SSH_USER=$(get_param "${FILE}" "ssh_user")
    export SSH_PASSWD=$(get_param "${FILE}" "ssh_passwd")
    export SSH_PORT=$(get_param "${FILE}" "ssh_port")
}

function get_itens_file()
{
    TXT=""    
    for I in $(cat $1); do
        TXT+=$(echo "${I}" | awk -F";" '{print $1" "$2" "}')
    done
    echo "${TXT}" 
}

function menu()
{
    TITULO="$1"
    ENUNCIADO="$2"
    ITENS="$3"
       
    dialog  --title "${TITULO}"\
            --stdout \
            --menu "${ENUNCIADO}" ${G_ALTURA} ${G_LARGURA} ${G_ITENS_MENU} ${ITENS}
}

function connect_ssh
{
    REMOTE_HOST=$(echo $1|tr -d \")
    export SSHPASS="${SSH_PASSWD}"    
    sshpass -e ssh -p ${SSH_PORT} ${SSH_USER}@${REMOTE_HOST}
}



### INICIO ###

SITE_FILE=$(menu "Seleção de site remoto " "Selecione o site remoto" "$(get_sites)")

#SITE=$(get_sites)
#echo "site:$SITE"
get_site_param "${SITE_FILE}"

echo "SRC_HOSTS:${SRC_HOSTS}"
host=$(menu "Titulo" "Selecione uma máquina para acesso" "$(get_itens_file "${G_HOSTS_PATH}/${SRC_HOSTS}")")
echo $host

#connect_ssh "$host"

