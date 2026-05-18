build:
	docker build -t actions-runner .
	docker run -it actions-runner bash

lint:
	docker run --rm -i -v "$(shell pwd):/tmp/utility" --workdir="/tmp/utility" hadolint/hadolint hadolint Dockerfile --ignore DL3008 --verbose
