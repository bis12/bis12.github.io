export secret_url="taskcluster/secrets/v1/secret/repo:github.com/imbstack/imbstack.com"
export AWS_ACCESS_KEY_ID=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_ACCESS_KEY_ID"]')
export AWS_SECRET_ACCESS_KEY=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_SECRET_ACCESS_KEY"]')
aws s3 sync --delete _site --exclude _site/assets --exclude _site/img --exclude _site/data s3://imbstack.com
# Let's raise the max-age and/or use immutable over time if this is working correctly
aws s3 sync _site/assets --cache-control max-age=604800 s3://imbstack.com/assets
aws s3 sync _site/img --cache-control max-age=7200 s3://imbstack.com/img
aws s3 sync _site/data --cache-control max-age=7200 s3://imbstack.com/data
