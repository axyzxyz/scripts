#!/bin/bash
DOMAIN=$1
[[ -n $DOMAIN ]] || (echo "请指定第一个参数:域名"&&exit 1)||exit

echo "Create server key..."
echo "user the random password_key"
passwd=`cat /dev/random |tr -dc "0-0a-z"|head -c 6`
openssl genrsa -des3  -passout pass:$passwd -out $DOMAIN.key 1024
echo "Create server certificate signing request..."

SUBJECT="/C=US/ST=Mars/L=iTranswarp/O=iTranswarp/OU=iTranswarp/CN=$DOMAIN"
openssl req -new -subj $SUBJECT -key $DOMAIN.key -passin pass:$passwd -out $DOMAIN.csr	
echo "Remove password..."
mv $DOMAIN.key $DOMAIN.origin.key
openssl rsa -in $DOMAIN.origin.key -passin pass:$passwd -out $DOMAIN.key

echo "Sign SSL certificate..."
openssl x509 -req -days 3650 -in $DOMAIN.csr -signkey $DOMAIN.key  -out $DOMAIN.crt
mkdir -p /etc/nginx/ssl
mv $DOMAIN.* /etc/nginx/ssl
echo "    ssl_certificate     /etc/nginx/ssl/$DOMAIN.crt;"
echo "    ssl_certificate_key /etc/nginx/ssl/$DOMAIN.key;"
