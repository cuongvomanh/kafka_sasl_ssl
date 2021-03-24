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
is_ssl=false ./scripts/run.sh
```
