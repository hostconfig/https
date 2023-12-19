#!/usr/bin/env bash

echo ""
echo "Generating your TLS certificate."
echo ""

echo ""
echo "Originally published by Lewel Murithi"
echo "https://www.section.io/engineering-education/how-to-get-ssl-https-for-localhost/"
echo ""

rm -rf ./.certs

mkdir ./.certs && cd ./.certs
mkdir ./CA && cd ./CA

echo ""
echo "First step: will be to generate a root CA certificate."
echo ""
echo "This will generate a private key and request a simple passphrase for the key."
echo ""
echo "The user will enter the passphrase and re-enter it again for confirmation."
echo ""

openssl genrsa -out CA.key -des3 2048

echo ""
echo "Next, we will generate a root CA certificate using the key generated, that will be valid for ten years in our case."
echo ""
echo "The passphrase for the key and certificate info will be requested."
echo ""
echo "The user can input the desired certificate info or leave it as default."
echo ""

openssl req -x509 -sha256 -new -nodes -days 3650 -key CA.key -out CA.pem

mkdir ./localhost && cd ./localhost
touch localhost.ext

echo "authorityKeyIdentifier = keyid,issuer" >> ./localhost.ext
echo "basicConstraints = CA:FALSE" >> ./localhost.ext
echo "keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment" >> ./localhost.ext
echo "subjectAltName = @alt_names" >> ./localhost.ext
echo " " >> ./localhost.ext
echo "[alt_names]" >> ./localhost.ext
echo "DNS.1 = localhost" >> ./localhost.ext
echo "IP.1 = 127.0.0.1" >> ./localhost.ext

echo ""
echo "Next will be to generate a key and use the key to generate a CSR (Certificate Signing Request)."
echo ""
echo "The command will generate the localhost private key, and the passphrase will be requested for the key, and the user will be asked to confirm it again."
echo ""

openssl genrsa -out localhost.key -des3 2048

echo ""
echo "Next will be to generate CSR using the key, and then the passphrase create above will be requested."
echo ""
echo "Any other details requested can be left as default or keyed in as appropriate."
echo ""
echo "Note the challenge password requested; one can enter anything."
echo ""

openssl req -new -key localhost.key -out localhost.csr

echo ""
echo "Now with this CSR, we can request the CA to sign a certificate."
echo ""

openssl x509 -req -in localhost.csr -CA ../CA.pem -CAkey ../CA.key -CAcreateserial -days 3650 -sha256 -extfile localhost.ext -out localhost.crt

echo ""
echo "We will need to decrypt the localhost.key and store that file too."
echo ""

openssl rsa -in localhost.key -out localhost.decrypted.key

echo ""
echo "Passing cert to Mozilla store (if exists)."
echo ""

certutil -d sql:$HOME/.pki/nssdb -A -t "C,," -n localhost -i ./.certs/CA/localhost/localhost.crt

echo ""
echo "Done."
echo ""

echo ""
echo "This script was adapted from https://www.section.io/engineering-education/how-to-get-ssl-https-for-localhost/"
echo ""
