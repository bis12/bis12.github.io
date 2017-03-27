secret_url="taskcluster/secrets/v1/secret/repo:github.com/imbstack/imbstack.github.io"
export AWS_ACCESS_KEY_ID=$(curl ${password_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_ACCESS_KEY_ID"]')
export AWS_SECRET_ACCESS_KEY=$(curl ${password_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_SECRET_ACCESS_KEY"]')
aws s3 sync --delete _site s3://imbstack.com
