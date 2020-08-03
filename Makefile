default: list_tasks

run_in_bundle := docker run --rm -t \
	-v `pwd`:/source \
	-v /home:/home \
	-v /etc/passwd:/etc/passwd:ro \
	-v /etc/group:/etc/group:ro \
	--user $(shell id -u):$(shell id -g) \
	markmims/pubdev:latest bundle exec

list_tasks:
	@echo "--- $@ ---"
	@$(run_in_bundle) rake -T

generate:
	@echo "--- $@ ---"
	@$(run_in_bundle) rake generate

publish: deploy

deploy:
	@echo "--- $@ ---"
	@$(run_in_bundle) rake deploy

.PHONY: preview
preview:
	@echo "--- $@ ---"
	@$(run_in_bundle) jekyll --server
