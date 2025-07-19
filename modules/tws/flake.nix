{
  description = "Interactive Brokers Trader Workstation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

  outputs =
    { self, nixpkgs }:
    let
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (
        system:
        import nixpkgs {
          inherit system;
          overlays = [ self.overlay ];
        }
      );
    in

    {

      overlay = final: prev: {
        libPath = final.lib.makeLibraryPath (
          with final;
          [
            alsa-lib
            at-spi2-atk
            cairo
            cups
            dbus
            expat
            ffmpeg
            fontconfig
            freetype
            gdk-pixbuf
            glib
            gtk2
            gtk3
            javaPackages.openjfx19
            libdrm
            libGL
            libxkbcommon
            mesa
            nspr
            nss
            pango
            xorg.libXfixes
            xorg.libXcomposite
            xorg.libXdamage
            xorg.libXext
            xorg.libXrandr
            xorg.libXrender
            xorg.libXtst
            xorg.libXi
            xorg.libXxf86vm
            xorg.libxcb
            xorg.libX11
            zlib
          ]
        );

        tws =
          with final;
          stdenv.mkDerivation {
            name = "ib-tws";
            version = "10.39.1b";

            src = final.fetchurl {
              url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
              # This will have to change if the TWS installer is updated.
              hash = "sha256-2QS3EfOgBAI1SFameZkUKUUAhNwxmN3jHvj39ijMJxY=";
            };

            dontUnpack = true;
            dontConfigure = true;
            dontBuild = true;

            installPhase = ''
              set +o pipefail
              mkdir -p $out
              mkdir -p $out/bin
              mkdir -p $out/jre
              mkdir install4j

              # Extract the installer script. (unused)
              head --bytes 17981 "$src" > install.sh

              # Extract the data file (0.dat).
              tail --bytes +17982 "$src" 2> /dev/null | head --bytes 221397745 > install4j/0.dat

              # Extract the installer and jre.
              tail --bytes 95478114 "$src" > sfx_archive.tar.gz

              # Unpack the installer and JRE.
              tar -xf sfx_archive.tar.gz -C install4j
              tar -xf install4j/jre.tar.gz -C $out/jre

              # Patch JRE binaries.
              for file in $out/jre/bin/*
              do
                patchelf \
                  --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \
                  $file 2> /dev/null || true
              done

              # Unpack jars.
              unpack () {
                jar="`echo "$1" | awk '{ print substr($0,1,length($0)-5) }'`"
                $out/jre/bin/unpack200 -r "$1" "$jar"
                chmod a+r "$jar"
              }
              for jarpack in $out/jre/lib/*.jar.pack
              do
                unpack $jarpack
              done
              for jarpack in $out/jre/lib/ext/*.jar.pack
              do
                unpack $jarpack
              done

              # Run the bundled JRE, if this fails the build should also fail.
              LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH" \
                $out/jre/bin/java -version

              # Run the installer, storing artifacts in $out.
              cd install4j && \
                LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH" \
                INSTALL4J_JAVA_HOME="$out/jre" \
                  $out/jre/bin/java \
                    -DjtsConfigDir="/home/jts" \
                    -classpath "i4jruntime.jar:launcher0.jar" \
                    install4j.Installer311282719 "-q" "-dir" "$out"

              # Wrap the entrypoint.
              cat << SRC > $out/bin/tws
              #! ${final.bash}/bin/bash

              # On startup, ensure the tws config dir is setup.
              TWS_DIR="\$HOME/.tws"
              if [ ! -d "\$TWS_DIR" ]; then
                  mkdir -p "\$TWS_DIR"
                  echo "TWS config dir created at: \$TWS_DIR"
              fi
              # Setup env, and launch tws.
              LD_LIBRARY_PATH="${libPath}:\$LD_LIBRARY_PATH" \
              INSTALL4J_JAVA_HOME="$out/jre" \
              $out/tws -J-DjtsConfigDir=\$TWS_DIR -J-Djdk.gtk.version=2
              SRC

              chmod +x $out/bin/tws
            '';
          };

      };

      packages = forAllSystems (system: {
        inherit (nixpkgsFor.${system}) tws;
      });

      defaultPackage = forAllSystems (system: self.packages.${system}.tws);
    };
}
