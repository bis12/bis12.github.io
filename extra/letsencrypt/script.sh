export AWS_ACCESS_KEY_ID=$(curl ${SECRET_URL} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_ACCESS_KEY_ID"]')
export AWS_SECRET_ACCESS_KEY=$(curl ${SECRET_URL} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_SECRET_ACCESS_KEY"]')
export CF_DISTRIBUTION_ID=$(curl ${SECRET_URL} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["CF_DISTRIBUTION_ID"]')
export CF_DOMAIN=$(curl ${SECRET_URL} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["DOMAIN"]')
export CERT_EMAIL=$(curl ${SECRET_URL} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["CERT_EMAIL"]')
certbot --agree-tos --email $CERT_EMAIL -na certbot-s3front:auth --keep-until-expiring --text \
  --certbot-s3front:auth-s3-bucket $CF_DOMAIN \
  -i certbot-s3front:installer \
  --certbot-s3front:installer-cf-distribution-id $CF_DISTRIBUTION_ID \
  -d $CF_DOMAIN
