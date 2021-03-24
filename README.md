# kafka_sasl_ssl
## Download kafka and extract

```
bash ./init.sh
```

## Start sasl_ssl kafka standalone

```$
./scripts/run.sh
```

## Start sasl kafka standalone

```
is_ssl=false ./scripts/run.sh
```

## Start sasl_ssl with exist cert,key store, trust store folder (can created by run ./sasl_ssl_config/ssl/run.sh) kafka standalone

Copy cert,key store, trust store file to sasl_ssl_config/ssl/ and run

```
is_create_cert=false ./scripts/run.sh
```

## Start sasl_ssl with docker-compose

### Build image
```
docker build . -t kafka_sasl_ssl:0.1
```

### Copy cert,key store, trust store file to sasl_ssl_config/ssl/ and run

### Run
```
docker-compose up -d
```
