.DEFAULT_GOAL := build

VC = v
VFLAGS = -W -prod -compress
ARTIFACT = committer

HERE = $(shell pwd)


build:
	@cd $(HERE) && $(VC) $(VFLAGS) committer.v -o $(ARTIFACT)
