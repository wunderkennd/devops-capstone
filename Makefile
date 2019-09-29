.PHONY: clean data lint requirements sync_data_to_s3 sync_data_from_s3 docker-init docker-build docker-push

#################################################################################
# GLOBALS																	   #
#################################################################################

PROJECT_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))

ifeq (,$(shell which conda))
HAS_CONDA=False
else
HAS_CONDA=True
endif

#################################################################################
# CREDENTIAL CONFIGURATION													    #
#################################################################################

# TODO: Add in Dockerfile configuration
# TODO: Add in aws cli configuration 
# TODO: Add in github configuration

#################################################################################
# DEV COMMANDS																  #
#################################################################################

## Install Python Dependencies
requirements: test_environment
	$(PYTHON_INTERPRETER) -m pip install -U pip setuptools wheel
	$(PYTHON_INTERPRETER) -m pip install -r requirements.txt

## Make Dataset
data: requirements
	$(PYTHON_INTERPRETER) src/data/make_dataset.py

## Delete all compiled Python files
clean:
	find . -type f -name "*.py[co]" -delete
	find . -type d -name "__pycache__" -delete

## Lint using flake8
# lint:
# 	flake8 src

## Upload Data to S3
sync_data_to_s3:
ifeq (default,$(PROFILE))
	aws s3 sync data/ s3://$(BUCKET)/data/
else
	aws s3 sync data/ s3://$(BUCKET)/data/ --profile $(PROFILE)
endif

## Download Data from S3
sync_data_from_s3:
ifeq (default,$(PROFILE))
	aws s3 sync s3://$(BUCKET)/data/ data/
else
	aws s3 sync s3://$(BUCKET)/data/ data/ --profile $(PROFILE)
endif

## Set up python interpreter environment
create_environment:
ifeq (True,$(HAS_CONDA))
		@echo ">>> Detected conda, creating conda environment."
ifeq (3,$(findstring 3,$(PYTHON_INTERPRETER)))
	conda create --name $(PROJECT_NAME) python=3
else
	conda create --name $(PROJECT_NAME) python=2.7
endif
		@echo ">>> New conda env created. Activate with:\nsource activate $(PROJECT_NAME)"
else
	$(PYTHON_INTERPRETER) -m pip install -q virtualenv virtualenvwrapper
	@echo ">>> Installing virtualenvwrapper if not already intalled.\nMake sure the following lines are in shell startup file\n\
	export WORKON_HOME=$$HOME/.virtualenvs\nexport PROJECT_HOME=$$HOME/Devel\nsource /usr/local/bin/virtualenvwrapper.sh\n"
	@bash -c "source `which virtualenvwrapper.sh`;mkvirtualenv $(PROJECT_NAME) --python=$(PYTHON_INTERPRETER)"
	@echo ">>> New virtualenv created. Activate with:\nworkon $(PROJECT_NAME)"
endif

create_conda_from_yaml:
	# To create the conda environment
	conda env create -f $(PROJECT_NAME).yaml

	# To update the conda environment:
	conda env update -f $(PROJECT_NAME).yaml

	# To register the conda environment in Jupyter:
	conda activate $(PROJECT_NAME)
	python -m ipykernel install --user --name $(PROJECT_NAME) --display-name "Python ($(PROJECT_NAME))"

## Add conda environment to jupyter kernel
add_conda_to_jupyter:
	conda activate $(PROJECT_NAME)
	python -m ipykernel install --user --name $(PROJECT_NAME) --display-name "Python ($(PROJECT_NAME))"

## Test python environment is setup correctly
test_environment:
	$(PYTHON_INTERPRETER) test_environment.py

#################################################################################
# TESTING COMMANDS															  #
#################################################################################

setup:
	# Create python virtualenv & source it
	# source ~/.devops/bin/activate
	alias pip3 pip
	# python3 -m pipenv ~/.devops

## Install all of the base packages
update:
	# This should be run from inside a virtualenv
	# TODO: Refactor all of this to work for Conda
	pip install --upgrade pip
	conda env update -f environment.yml -y
	#			 pip install pipenv
	# 	pipenv install -r requirements.txt

## Initialize the environment
init:
	# set default pipenv python to 3.7
	export PIPENV_DEFAULT_PYTHON_VERSION=3.7
	#  echo "conda create -n $(PROJECT_NAME)"
	# set alias for pip
	alias pip=pip3
	# install pipenv
	pip install --upgrade pip && pip install pipenv
	# instantiate the pipenv environment (if in miniconda environment)
	pipenv --python=$(conda run which python) --site-packages
	# alternative would be pipenv --python 3.7

	conda config --set ssl_verify False
	# install dev packages
	pipenv install --pre black --dev
	pipenv install pytlint mypy pre-commit flak8 autodoc isort sphinx --dev
	# install local packages
	pipenv install -e .
	# For evaluation of computer vision models
# 	pipenv install flashtorch --dev
    # installing general utility packages for
	pipenv install loguru click
	# for async postgresql operations 
	# pipenv install databases[postgresql]
	conda install -f environment.yml
	# go in to the env shell
#	 pipenv shell
	# todo: figure out what this means
#	 pipenv lock -r

init-dev:
	docker run -it -v $PWD:/mnt/ -v $HOME/.aws:$HOME/.aws -p 8081:80 $(BASE_CONTAINER) bash
	pip install pipenv
	pipenv install --dev



deploy_init:

document_config:
	pipenv install sphinx --dev
	sphinx quick-start

test:
	# Additional, optional, tests could go here
	# TODO: Configure Voyager Lambda Testing
	# TODO: Configure Airflow ETL Testing
	# TODO: Configure Atlas Search endpoint testing
	# python -m pytest -vv --cov=myrepolib tests/*.py
	# python -m pytest --nbval notebook.ipynb
# 	pipenv run pytest tests

## Tests a function from a given file path within a lambda environment.
## See for more information https://github.com/lambci/docker-lambda
local-test:


lambda-test:
	docker run -it -v $(PWD):/var/task -v $(HOME)/.aws:/root/.aws -p 8081:80 lambci/lambda:build-python3.7 python $(path)
	# docker run [--rm] -v <code_dir>:/var/task [-v <layer_dir>:/opt] lambci/lambda:<runtime> [<handler>] [<event>]
    # For large events you can pipe them into stdin if you set DOCKER_LAMBDA_USE_STDIN (on any runtime)
    # echo '{"some": "event"}' | docker run --rm -v "$PWD":/var/task -i -e DOCKER_LAMBDA_USE_STDIN=1 lambci/lambda:nodejs8.10
    # If using a function other than index.handler, with a custom event
    # docker run --rm -v "$PWD":/var/task lambci/lambda:nodejs10.x index.myHandler '{"some": "event"}'

format:
	# TODO: Configure black tests
	black -t py37

# TODO: Figure out best way to install hadolint & jupyter notebook linting
## Lint python scripts with pylint, docker with hadolint, and jupyter notebooks with 
lint:
	conda create -n jlflake8 anaconda
	conda install -c conda-forge jupyterlab flake8
	jupyter labextension install jupyterlab-flake8
	
	# See local hadolint install instructions:   https://github.com/hadolint/hadolint
	# This is linter for a Dockerfile
	hadolint Dockerfile
	# This is a linter for Python source code linter: https://www.pylint.org/
	# This should be run from inside a virtualenv
	pylint --disable=R,C,W1203 app.py

all-test: install lint test

#################################################################################
# EXPERIMENT MANAGEMENT COMMANDS									            #
#################################################################################

init-experiment:
    pipenv install --dev mflow
    mlflow ui # located at port 5000

run-experiment:
    mlflow run $(experiment_name) -P $(experiment_params)

deploy-experiment:
    mlflow models serve -m runs:/$(experiment_id)/model --port $(experiment_port)

#################################################################################
# DOCKER BUILD COMMANDS														    #
#################################################################################

## Initialize a docker repository in ECR and save the information from the response
ecr-init:
	# log in to ECR
	(aws ecr get-login --no-include-email --region us-east-1)
	# create a json of the repository information
	aws ecr create-repository --repository_name $(PROJECT_NAME)/$(IMAGE_NAME) >> ecr_config.json
	# extract environment variables from the ecr information
	cat ecr_config.json | python3 -c "import sys, json; print('REPOSITORY_URI=\"'+json.load(sys.stdin)['repository']['repositoryUri']+'\"')" >> .env
	cat ecr_config.json | python3 -c "import sys, json; print('REPOSITORY_NAME=\"'+json.load(sys.stdin)['repository']['repositoryName']+'\"')" >> .env
	cat ecr_config.json | python3 -c "import sys, json; print('REGISTRY_ID=\"'+json.load(sys.stdin)['repository']['registryId']+'\"')" >> .env
	# update envi with new environment variables
	source .env

## Build docker image
ecr-build:
	# source .env
	docker build -t $(REPOSITORY_NAME) .
	# TODO: insert some sort of docker test here
	# TODO: don't forget to consider/ incorporate hadolint further in the pipeline

## Push image to ecr repository
ecr-push:
	source .env
	build_tag=$(git rev-parse --short HEAD)
	docker tag $(RESPOSITORY_NAME):latest $(RESPOSITORY_URI):$(build_tag)
	docker push $(REPOSITORY_URI):$(build_tag)

docker-repo-delete:
	aws ecr delete-repository --repository-name $(REPOSITORY_NAME) --force

#################################################################################
# LAMBDA BUILD COMMANDS														 #
#################################################################################

# TODO: Create a package_repo function to create lambda layers
build-layer:
	mkdir -p lambda/utils/ && touch lambda/utils/package_repo.py && touch lambda/__init__.py && touch lambda/utils/__init__.py
	docker run -it -v $(PWD):/var/task $(HOME)/.aws:/root/.aws -p 8081:80 lambci/lambda:build-python3.7 python lambda/utils/package_repo.py

#################################################################################
# PROJECT RULES																 #
#################################################################################



#################################################################################
# Self Documenting Commands													 #
#################################################################################

.DEFAULT_GOAL := help

# Inspired by <http://marmelab.com/blog/2016/02/29/auto-documented-makefile.html>
# sed script explained:
# /^##/:
# 	* save line in hold space
# 	* purge line
# 	* Loop:
# 		* append newline + line to hold space
# 		* go to next line
# 		* if line starts with doc comment, strip comment character off and loop
# 	* remove target prerequisites
# 	* append hold space (+ newline) to line
# 	* replace newline plus comments by `---`
# 	* print line
# Separate expressions are necessary because labels cannot be delimited by
# semicolon; see <http://stackoverflow.com/a/11799865/1968>
.PHONY: help
help:
	@echo "$$(tput bold)Available rules:$$(tput sgr0)"
	@echo
	@sed -n -e "/^## / { \
		h; \
		s/.*//; \
		:doc" \
		-e "H; \
		n; \
		s/^## //; \
		t doc" \
		-e "s/:.*//; \
		G; \
		s/\\n## /---/; \
		s/\\n/ /g; \
		p; \
	}" ${MAKEFILE_LIST} \
	| LC_ALL='C' sort --ignore-case \
	| awk -F '---' \
		-v ncol=$$(tput cols) \
		-v indent=19 \
		-v col_on="$$(tput setaf 6)" \
		-v col_off="$$(tput sgr0)" \
	'{ \
		printf "%s%*s%s ", col_on, -indent, $$1, col_off; \
		n = split($$2, words, " "); \
		line_length = ncol - indent; \
		for (i = 1; i <= n; i++) { \
			line_length -= length(words[i]) + 1; \
			if (line_length <= 0) { \
				line_length = ncol - indent - length(words[i]) - 1; \
				printf "\n%*s ", -indent, " "; \
			} \
			printf "%s ", words[i]; \
		} \
		printf "\n"; \
	}' \
	| more $(shell test $(shell uname) = Darwin && echo '--no-init --raw-control-chars')
