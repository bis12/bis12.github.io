export secret_url="taskcluster/secrets/v1/secret/repo:github.com/imbstack/imbstack.github.io"
export AWS_ACCESS_KEY_ID=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_ACCESS_KEY_ID"]')
export AWS_SECRET_ACCESS_KEY=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_SECRET_ACCESS_KEY"]')
export CF_DISTRIBUTION_ID=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["CF_DISTRIBUTION_ID"]')
certbot --agree-tos -a certbot-s3front:auth --renew-by-default --text \
  --certbot-s3front:auth-s3-bucket imbstack.com \
  -i certbot-s3front:installer \
  --certbot-s3front:installer-cf-distribution-id $CF_DISTRIBUTION_ID \
  -d imbstack.com
