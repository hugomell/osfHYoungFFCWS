PROJECT_DIR = $(shell echo ${PWD})
DATE = $(shell date)
STR_DATE = DUMMY-DATE-- $(DATE)

.PHONY: all build pkg run 

build:
	sed -i "s/-ANCHOR-/$(STR_DATE)/" Containerfile
	podman build --pull=false -t docker.io/ipea7892/osf-hyoung-ffcws:pre-reg \
		-f Containerfile .
	sed -i 's/DUMMY-DATE--.*/-ANCHOR-"/' Containerfile

run:
	podman run --rm -it \
	    -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
	    -v "$(PROJECT_DIR)":/home/root/project "docker.io/ipea7892/osf-hyoung-ffcws:pre-reg"

pkg:
    # run demo pipeline
	podman run --rm \
	    -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
	    -v "$(PROJECT_DIR)":/home/root/project \
		"docker.io/ipea7892/osf-hyoung-ffcws:pre-reg" \
	    bash -c 'R -e "devtools::document(); devtools::install(upgrade = FALSE); osfHYoungFFCWS::run_demo_pipeline()"'
	rm Data-simulation-and-parameter-recovery-with-brms.*
	rm _targets.R _targets.yaml
    # project package update
	rm -rf docs/
	cp inst/Data-simulation-and-parameter-recovery-with-brms.Rmd \
        vignettes/articles/Data-simulation-and-parameter-recovery-with-brms.Rmd
	podman run --rm \
	    -e DISABLE_AUTH=true -p 127.0.0.1:8787:8787 \
	    -v "$(PROJECT_DIR)":/home/root/project \
		"docker.io/ipea7892/osf-hyoung-ffcws:pre-reg" \
		bash -c 'R -e "pkgdown::build_site()"'

push:
	git push 
	sed -i "s/-ANCHOR-/$(STR_DATE)/" Containerfile
	podman build --pull=false -t docker.io/ipea7892/osf-hyoung-ffcws:pre-reg \
		-f Containerfile .
	sed -i 's/DUMMY-DATE--.*/-ANCHOR-"/' Containerfile
	podman login docker.io
	podman push docker.io/ipea7892/osf-hyoung-ffcws:pre-reg

build-gitpod:
	podman build --pull=false -t docker.io/ipea7892/osf-hyoung-ffcws:gitpod \
		-f Containerfile-gitpod .

run-gitpod:
	podman run --rm -it \
	    -v "$(PROJECT_DIR)":/home/root/project "docker.io/ipea7892/osf-hyoung-ffcws:gitpod"

push-gitpod:
	podman login docker.io
	podman push docker.io/ipea7892/osf-hyoung-ffcws:gitpod



preview:
	@live-server docs/
