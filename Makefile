default: list_tasks

run_rake := docker run --rm -t \
	-v `pwd`:/source \
	-v /home:/home \
	-v /etc/passwd:/etc/passwd:ro \
	-v /etc/group:/etc/group:ro \
	--user $(shell id -u):$(shell id -g) \
	markmims/pubdev:latest bundle exec rake

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

preview:
	@echo "--- $@ ---"
	@$(run_rake) preview
