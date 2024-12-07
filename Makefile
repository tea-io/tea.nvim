.PHONY: format check-format lint

format:
	stylua **/*.lua

check-format:
	stylua --check **/*.lua

lint:
	luacheck **/*.lua
