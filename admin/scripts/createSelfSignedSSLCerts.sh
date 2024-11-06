#!/bin/bash

openssl req -x509 -sha256 -nodes -days 365 -newkey rsa:2048 -keyout privateKey.key -out appgwcert.crt
openssl pkcs12 -export -out appgwcert.pfx -inkey privateKey.key -in appgwcert.crt

