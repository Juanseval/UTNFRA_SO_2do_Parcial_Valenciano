#!/bin/bash

if [ -z "$1" ]; then
    echo "Uso: $0 <UTN-FRA_SO_Examenes/202408/bash_script/Lista_URL.txt>"
    exit 1
fi


URL_LIST="$1"
BASE_DIR="/tmp/head-check"
LOG="/var/log/status_URL.log"


mkdir -p "$BASE_DIR"/{Error/{cliente,servidor},ok}


while IFS= read -r LINE; do
    
    [[ "$LINE" =~ ^# ]] && continue
    
    [ -z "$LINE" ] && continue

    
    DOMINIO=$(echo "$LINE" | cut -d';' -f1)
    URL=$(echo "$LINE" | cut -d';' -f2)

    
    [ -z "$URL" ] && continue

    
    STATUS=$(curl -LI -o /dev/null -w '%{http_code}' -s "$URL")
    FECHA=$(date +"%Y%m%d_%H%M%S")

    
    echo "${FECHA} - Code:${STATUS} - URL:${URL}" >> "$LOG"

    
    if [[ "$STATUS" == "200" ]]; then
        echo "$URL" >> "$BASE_DIR/ok/${DOMINIO}.log"
    elif [[ "$STATUS" -ge 400 && "$STATUS" -lt 500 ]]; then
        echo "$URL" >> "$BASE_DIR/Error/cliente/${DOMINIO}.log"
    elif [[ "$STATUS" -ge 500 && "$STATUS" -lt 600 ]]; then
        echo "$URL" >> "$BASE_DIR/Error/servidor/${DOMINIO}.log"
    else
        echo "$URL" >> "$BASE_DIR/Error/${DOMINIO}.log"
    fi
done < "$URL_LIST"

