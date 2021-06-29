{ pkgs ? import <nixpkgs> {} }:

pkgs.mkShell {
  name = "zilch-playground";
  version = "0.0.1";

  buildInputs = with pkgs; [
    purescript
    spago

    dhall

    nodejs
    nodePackages.npm
  ];

  shellHook = ''
    export PATH="$(${pkgs.nodePackages.npm}/bin/npm config get prefix)/bin:$PATH"
  '';
}
