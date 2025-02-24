{
  description = "A Python development environment with uv and isolated venv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/cf8cc1201be8bc71b7cbbbdaf349b22f4f99c7ae"; # 2024-04-29
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    # Define top-level templates output
    {
      templates = {
        default = {
          description = "A Python development environment with uv for NixOS";
          path = ./.;  # Points to the root of the flake
        };
      };
    } // flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgsUnstable = import nixpkgs-unstable { inherit system; };
        ldLibraryPath = pkgs.lib.makeLibraryPath (with pkgs; [
          stdenv.cc.cc  # libstdc++.so.6
          zlib          # libz.so.1
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3
            stdenv.cc.cc
            zlib
          ] ++ [ pkgsUnstable.uv ];

          shellHook = ''
            export LD_LIBRARY_PATH="${ldLibraryPath}:$LD_LIBRARY_PATH"
            VENV_DIR=".venv"
            if [ ! -d "$VENV_DIR" ]; then
              echo "Creating a new virtual environment with uv..."
              uv init || { echo "Failed to create uv project!"; exit 1; }
            else
              echo "Using existing virtual environment..."
            fi
            echo "Python development environment ready!"
            echo "Use 'uv add <package>' to install Python packages in the uv project."
          '';
        };
      });
}
