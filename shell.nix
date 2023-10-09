{ sources ? import ./nix/sources.nix
, compiler ? "default"
, system ? builtins.currentSystem
, ...
}:

let
  ##################
  ## LOAD NIXPKGS ##
  ##################

  ## Import nixpkgs pinned by niv:
  pkgs = import sources.nixpkgs { inherit system; };

  ###########
  ## SHELL ##
  ###########

  ## Prepare Nix shell:
  thisShell = pkgs.mkShell {
    ## Build inputs for development shell:
    buildInputs = [
      pkgs.faas-cli
    ];

    ## Shell hook for development shell:
    shellHook = ''
      ## Environment variables:
      export PROJECT_DEV_ROOT="$(git rev-parse --show-toplevel)"

      ## Shell aliases:
      alias riched="${pkgs.rich-cli}/bin/rich --emoji --center --width 120 --panel rounded --theme rrt --hyperlinks"
      alias devsh-welcome="riched ''${PROJECT_DEV_ROOT}/README.md"

      ## Shell functions:
      faas-curl() {
        OPENFAAS_URL="http://$(lxc list name=faasd --format=json | jq -r ".[0].state.network.eth0.addresses[]|select(.family == \"inet\")|.address"):8080"
        curl ''${OPENFAAS_URL} --request-target "''${@}"
      }

      ## Greet:
      devsh-welcome
      echo
      echo '**Run devsh-welcome to see Welcome notice again**' | riched -m -
    '';
  };
in
thisShell
