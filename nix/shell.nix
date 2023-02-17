{ pkgs ? import ./nixpkgs-pinned.nix }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    purescript
    spago
    nodePackages.purescript-language-server
    nodejs
    nodePackages.npm
    firejail
  ];
}
