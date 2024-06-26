PROJECT_DIR = $(shell echo ${PWD})

.PHONY: all build run

build:
	podman build --pull=false -t docker.io/ipea7892/osf-hyoung-ffcws:latest \
		-f Containerfile .

run:
	podman run --rm -it \
	    -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
	    -v "$(PROJECT_DIR)":/home/root/project "docker.io/ipea7892/osf-hyoung-ffcws:latest"

pkg:
	rm -rf docs/
	podman run --rm \
	    -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
	    -v "$(PROJECT_DIR)":/home/root/project \
		"docker.io/ipea7892/osf-hyoung-ffcws:latest" \
		bash -c 'R -e "devtools::document() ; pkgdown::build_site()"'
	git add . && git commit -m "deploy new version" && git push 

all:
	@rm -rf docs/
	@cp inst/_targets.yaml inst/Data-simulation-and-parameter-recovery-with-brms.Rmd vignettes/articles 
	@R -e "devtools::document() ; pkgdown::build_site()"
	# @git add . && git commit -m "deploy new version" && git push
