export secret_url="taskcluster/secrets/v1/secret/repo:github.com/imbstack/imbstack.com"
export AWS_ACCESS_KEY_ID=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_ACCESS_KEY_ID"]')
export AWS_SECRET_ACCESS_KEY=$(curl ${secret_url} | python -c 'import json, sys; a = json.load(sys.stdin); print a["secret"]["AWS_SECRET_ACCESS_KEY"]')

echo "Uploading normal files"
aws s3 sync --dryrun --exclude "assets/*"  --exclude "data/*" --exclude "img/*" --delete _site/ s3://bstack-tc-docs

# Let's raise the max-age and/or use immutable over time if this is working correctly
echo "Uploading assets files"
aws s3 sync --cache-control max-age=604800 --delete _site/assets s3://imbstack.com/assets
echo "Uploading img files"
aws s3 sync --cache-control max-age=7200  --delete _site/img s3://imbstack.com/img
echo "Uploading data files"
aws s3 sync --cache-control max-age=7200 --delete _site/data s3://imbstack.com/data
