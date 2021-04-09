.DEFAULT_GOAL := build

VC = v
VFLAGS = -W -prod
ARTIFACT = commiter

HERE = $(shell pwd)


build:
	@cd $(HERE) && $(VC) $(VFLAGS) auto-commiter.v -o $(ARTIFACT)
