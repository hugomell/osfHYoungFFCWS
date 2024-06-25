.PHONY: all

all:
	@rm -rf docs/
	@cp inst/_targets.yaml inst/Data-simulation-and-parameter-recovery-with-brms.Rmd vignettes/articles 
	@R -e "devtools::document() ; pkgdown::build_site()"
	# @git add . && git commit -m "deploy new version" && git push
