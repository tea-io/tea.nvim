{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "lua-dev-env";

  buildInputs = [
    pkgs.lua
    pkgs.luajitPackages.luacheck
    pkgs.stylua
  ];

}
