#!/bin/bash
rm -rf easy-rsa
git clone https://github.com/OpenVPN/easy-rsa.git
cd easy-rsa/easyrsa3
./easyrsa init-pki
./easyrsa build-ca nopass
./easyrsa --san=DNS:4development.net build-server-full server nopass
./easyrsa build-client-full client nopass

mkdir -p ../../certs
rm -rf ../../certs/*
cp pki/ca.crt ../../certs/ca.crt
cp pki/issued/server.crt ../../certs/server.crt 
cp pki/private/server.key ../../certs/server.key
cp pki/issued/client.crt ../../certs/client.crt
cp pki/private/client.key ../../certs/client.key
cd ../../
rm -rf easy-rsa
