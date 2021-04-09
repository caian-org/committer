.DEFAULT_GOAL := build

VC = v
VFLAGS = -W -prod
ARTIFACT = commiter


build:
	@$(VC) $(VFLAGS) auto-commiter.v -o $(ARTIFACT)
