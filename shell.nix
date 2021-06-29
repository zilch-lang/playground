{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "zilch-playground";
  version = "0.0.1";

  buildInputs = with pkgs; [
    purescript
    spago

    nodejs
    nodePackages.npm
  ];
}
