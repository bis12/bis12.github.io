.PHONY: docker docker-push website website-push

docker-push: docker
	docker push imbstack/jekyll-s3

docker:
	docker build -t imbstack/jekyll-s3 .

website-push: website
	./push.sh

website:
	bundle exec jekyll build --verbose

