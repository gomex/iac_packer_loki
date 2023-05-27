SHELL	 = /bin/bash

cnf ?= .env

DOCKER_IMAGE=mdmansur/packer-ansible:v0.8
PACKER_PLUGIN_PATH=/root/.packer.d/plugins

ifneq ($(shell test -e $(cnf) && echo -n yes),yes)
	ERROR := $(error $(cnf) file not defined in current directory)
endif

include $(cnf)
export $(shell sed 's/=.*//' $(cnf))

ifneq ($(shell test -e $(INCLUDE_MAKEFILE) && echo -n yes),yes)
	ifdef REMOTE_MAKEFILE
		REMOTE_MAKEFILE_RESULT := $(shell curl ${REMOTE_MAKEFILE} -o ${INCLUDE_MAKEFILE})
	else
		ERROR := $(error REMOTE_MAKEFILE not provided, look for your .env file)
	endif
endif

ifdef INCLUDE_MAKEFILE
	include ${INCLUDE_MAKEFILE}
endif

packer-init: ## Executar comando 'packer init'
	docker run \
		--rm \
		-v $(PWD):/root \
		-w /root \
		--env-file $(PWD)/.env \
		-it \
		$(DOCKER_IMAGE) \
		init packer/

packer-fmt: ## Executar comando 'packer fmt'
	docker run \
		--rm \
		-v $(PWD):/root \
		-w /root \
		--env-file $(PWD)/.env \
		-it \
		$(DOCKER_IMAGE) \
		fmt packer/

packer-validate: ## Executar comando 'packer validate'
	docker run \
		--rm \
		-v $(PWD):/root \
		-w /root \
		--env-file $(PWD)/.env \
		-it \
		$(DOCKER_IMAGE) \
		validate packer/

packer-build: ## Executar comando 'packer build'
	docker run \
		--rm \
		-v $(PWD):/root \
		-w /root \
		--env-file $(PWD)/.env \
		--entrypoint=/bin/bash \
		-it \
		$(DOCKER_IMAGE) -c "packer build packer/"

build: packer-init packer-validate packer-build ## build image with packer
