.PHONY: docker docker-push website website-push certbot certbot-push

docker-push: docker
	docker push imbstack/jekyll-s3

docker:
	docker build -t imbstack/jekyll-s3 .

website-push: website
	./push.sh

website:
	bundle exec jekyll build --verbose

certbot:
	docker build -t imbstack/certbot-cf ./extra/letsencrypt

certbot-push:
	docker push imbstack/certbot-cf
