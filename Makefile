.DEFAULT_GOAL := build

VC = v
VFLAGS = -W


build:
	@$(VC) $(VFLAGS) run auto-commiter.v
