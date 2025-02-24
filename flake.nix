{
  description = "A Python development environment with uv and isolated venv";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/cf8cc1201be8bc71b7cbbbdaf349b22f4f99c7ae"; # 2024-04-29
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs, nixpkgs-unstable, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
        pkgsUnstable = import nixpkgs-unstable { inherit system; };
        # Combine library paths for LD_LIBRARY_PATH
        ldLibraryPath = pkgs.lib.makeLibraryPath (with pkgs; [
          stdenv.cc.cc  # libstdc++.so.6
          zlib          # libz.so.1
        ]);
      in
      {
        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            python3       # Standard Python 3
            # uv            # For package management
            stdenv.cc.cc  # Provides libstdc++.so.6
            zlib          # Provides libz.so.1
          ] ++ [ pkgsUnstable.uv ];

          shellHook = ''
            # Define the library path
            export LD_LIBRARY_PATH="${ldLibraryPath}:$LD_LIBRARY_PATH"

            # Set the virtual environment path
            VENV_DIR=".venv"

            # Create or use the virtual environment
            if [ ! -d "$VENV_DIR" ]; then
              echo "Creating a new virtual environment with uv..."
              uv init || { echo "Failed to create uv project!"; exit 1; }
            else
              echo "Using existing virtual environment..."
            fi

            # Activate the virtual environment
            echo "Python development environment ready!"
            echo "Use 'uv add <package>' to install Python packages in the uv project."
          '';
        };

        # Add templates output for nix flake init
        templates = {
          default = {
            description = "A python development environment with uv for NixOS";
            path = ./.;
          };
        };
    });
}

