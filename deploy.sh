#!/bin/bash

PROJECT_NAME="wordpress-docker"

: '
1) Subir os containeres do docker-compose
'
WP_INSTANCES=2
DB_INSTANCES=1

echo "Rodando docker-compose..."

docker-compose up -d --scale wordpress=$WP_INSTANCES --scale mysql=$DB_INSTANCES;


: '
2) Descobrir os IPs dos containeres e alterar o arquivo nginx.conf
'
echo "Descobrindo IPs..."

servers=()

for i in $(seq 1 $WP_INSTANCES)
do
  servers+="server "
  servers+=$(docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}' ${PROJECT_NAME}_wordpress_$i)
  servers+=":9000;\n"
done

echo "Configurando o NGINX..."

rm -f nginx/nginx.conf

cp nginx/nginx.conf.example nginx/nginx.conf 

sed -i "s/_servers_/$(echo $servers)/" nginx/nginx.conf


: '
3) Restartar o NGINX para aplicar as novas configurações
'

docker container restart ${PROJECT_NAME}_nginx_1