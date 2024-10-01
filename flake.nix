{
  description = "Computational assignment grading";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
          };
        };
      in
      {
        devShell = pkgs.mkShell {
          buildInputs = with pkgs; [
            (python3.withPackages (ps: with ps; [
              #healpy # HEALPY IS NOT IN NIXPKGS, SO NEED TO MANUALLY PACKAGE IT!
              pandas
              matplotlib
              numpy
              scipy
            ]))
			jupyter
          ];
		shellHook = ''
		alias jop='BROWSER=brave jupyter-notebook'
		echo "Welcome to PHY coding course grading flake!"
		'';
        };
      }
    );
}
