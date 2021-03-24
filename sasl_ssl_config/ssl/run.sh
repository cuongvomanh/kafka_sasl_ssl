#Step 1
echo "Step1 Generate SSL key and certificate for each Kafka broker"
keytool -keystore kafka.server.keystore.jks -alias localhost -validity 365 -genkey
#Step 2
echo "Step2 Creating your own CA"
echo "Generate CA"
openssl req -new -x509 -keyout ca-key -out ca-cert -days 365
echo "Add the generated CA to the clients’ truststore"
keytool -keystore kafka.server.truststore.jks -alias CARoot -import -file ca-cert
echo "Provide a truststore for the Kafka brokers"
keytool -keystore kafka.client.truststore.jks -alias CARoot -import -file ca-cert
#Step 3
echo "Step3 Signing the certificate"
echo "Export the certificate from the keystore"
keytool -keystore kafka.server.keystore.jks -alias localhost -certreq -file cert-file
echo "Sign it with the CA"
openssl x509 -req -CA ca-cert -CAkey ca-key -in cert-file -out cert-signed -days 365 -CAcreateserial -passin pass:123456a@
echo "Import both the certificate of the CA and the signed certificate into the keystore"
keytool -keystore kafka.server.keystore.jks -alias CARoot -import -file ca-cert
keytool -keystore kafka.server.keystore.jks -alias localhost -import -file cert-signed
