{
  description = "Dotlify — dotfiles manager built on GNU Stow";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

  outputs = { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      forAllSystems = f: nixpkgs.lib.genAttrs systems
        (system: f nixpkgs.legacyPackages.${system});
    in
    {
      packages = forAllSystems (pkgs: rec {
        dotlify = pkgs.stdenv.mkDerivation {
          pname = "dotlify";
          # Keep in sync with lib/version.sh
          version = "0.11.14";
          src = ./.;

          # Shell script package — nothing to compile or check in the sandbox.
          dontBuild = true;
          doCheck = false;
          # Keep man page uncompressed so the CI path test (dfy.1, not dfy.1.gz) works.
          dontGzipMan = true;

          nativeBuildInputs = [ pkgs.makeWrapper ];

          installPhase = ''
            runHook preInstall

            mkdir -p "$out/bin" "$out/lib" "$out/locales" \
                     "$out/share/bash-completion/completions" \
                     "$out/share/zsh/site-functions" \
                     "$out/share/man/man1"

            install -m755 bin/dfy "$out/bin/dfy"
            cp lib/*.sh          "$out/lib/"
            cp locales/*.sh      "$out/locales/"
            install -m644 completions/dfy.bash \
              "$out/share/bash-completion/completions/dfy"
            install -m644 completions/_dfy \
              "$out/share/zsh/site-functions/_dfy"
            install -m644 man/dfy.1 "$out/share/man/man1/dfy.1"

            runHook postInstall
          '';

          # 1. Patch #!/usr/bin/env bash → Nix bash in all shell files.
          # 2. Wrap the binary so bash, stow, and figlet from the Nix store
          #    are always in PATH at runtime (required on macOS where system
          #    bash is 3.2 and stow/figlet may not be installed).
          postInstall = ''
            patchShebangs "$out/bin/dfy" "$out/lib"
            wrapProgram "$out/bin/dfy" \
              --prefix PATH : ${pkgs.lib.makeBinPath [
                pkgs.bash
                pkgs.stow
                pkgs.figlet
              ]}
          '';

          meta = with pkgs.lib; {
            description = "Bash framework on top of GNU Stow for managing dotfiles";
            longDescription = ''
              Dotlify (dfy) organises dotfiles into packages — directories under
              a central repository — and uses GNU Stow to create and remove
              symlinks in $HOME.  Works on Linux and macOS.
            '';
            homepage = "https://github.com/ajmasia/dotlify";
            license = licenses.gpl3Plus;
            platforms = platforms.unix;
            mainProgram = "dfy";
          };
        };

        default = dotlify;
      });

      apps = forAllSystems (pkgs: {
        default = {
          type = "app";
          program = "${self.packages.${pkgs.system}.dotlify}/bin/dfy";
        };
      });

      # nix develop  →  all tools needed for make check
      devShells = forAllSystems (pkgs: {
        default = pkgs.mkShell {
          packages = with pkgs; [ bash stow figlet bats shellcheck shfmt ];
        };
      });
    };
}
