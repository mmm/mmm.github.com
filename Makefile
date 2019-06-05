default: list_tasks

run_rake := docker run --rm -t \
	-v `pwd`:/source \
	-v ~/.gitconfig:/source/.gitconfig \
	--user $(shell id -u):$(shell id -g) \
	markmims/pubdev:0.0.1 bundle exec rake

list_tasks:
	@echo "--- $@ ---"
	@$(run_rake) -T

generate:
	@echo "--- $@ ---"
	@$(run_rake) generate

publish: deploy

deploy:
	@echo "--- $@ ---"
	@$(run_rake) deploy