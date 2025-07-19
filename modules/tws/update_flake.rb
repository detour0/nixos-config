#!/usr/bin/env ruby

# This script can be used to update the `flake.nix`. Use it like this:
#
#   ./update_tws.rb > tws.nix
#
# Note that the sha256 below is not dynamically supplied. If the TWS installer
# has been updated since this was written, Nix will complain about the hash
# not matching when trying to build the flake. Just swap in the hash it
# mentions and things should just work.
# REQUIRES RUBY --> 'nix-shell -p ruby'

require 'tmpdir'

Dir.mktmpdir do |tmp_dir|
  tws_installer = File.join tmp_dir, "tws-latest-standalone-linux-x64.sh"

  sfx_archive = File.join tmp_dir, "sfx_archive.tar.gz"

  install4j_dir = File.join tmp_dir, "install4j"
  i4jparams_file = File.join install4j_dir, "i4jparams.conf"
  stats_file = File.join install4j_dir, "stats.properties"


  system "wget -O #{tws_installer} https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh"

  tws_byte_count_info = `wc -c #{tws_installer}`
  tws_byte_count = tws_byte_count_info.split(" ").first.to_i

  sfx_archive_byte_count = `sed -nE 's/^tail -c ([0-9]+).*/\\1/p' #{tws_installer}`
  sfx_archive_byte_count = sfx_archive_byte_count.strip.to_i

  system "mkdir -p #{install4j_dir}"
  system "tail --bytes #{sfx_archive_byte_count} #{tws_installer}", out: sfx_archive
  system "tar -C #{install4j_dir} -xf #{sfx_archive}", err: File::NULL

  version = `sed -nE 's/.*variable name="buildInfo" value="Build ([0-9\.]+[A-Za-z]?).*/\\1/p' #{i4jparams_file}`
  version = version.strip

  zero_dat_byte_count = `sed -nE 's/^file\\.size\\.0=([0-9]+)/\\1/p' #{stats_file}`
  zero_dat_byte_count = zero_dat_byte_count.strip.to_i

  installer_offset = tws_byte_count - (sfx_archive_byte_count + zero_dat_byte_count)

  install4j_installer_matches = `sed -nE 's/.*\\$INSTALL4J_JAVA_PREFIX.*install4j\\.Installer([0-9]+).*/\\1/p' #{tws_installer}`
  install4j_installer = install4j_installer_matches.split.first

  flake_contents = %Q(
{
  description = "Interactive Brokers Trader Workstation";

  inputs.nixpkgs.url = "github:NixOS/nixpkgs/release-24.05";

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; overlays = [ self.overlay ]; });
    in

    {

      overlay = final: prev: {
        libPath = final.lib.makeLibraryPath (with final; [
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
        ]);


        tws = with final; stdenv.mkDerivation {
          name = "ib-tws";
          version = "#{version}";

          src = final.fetchurl {
            url = "https://download2.interactivebrokers.com/installers/tws/latest-standalone/tws-latest-standalone-linux-x64.sh";
            # This will have to change if the TWS installer is updated.
            hash = "sha256-Ejjp+vwp9cfNtot/PBYp+HsKZsti62ppIJf4SFFrkC4=";
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
            head --bytes #{installer_offset} "$src" > install.sh

            # Extract the data file (0.dat).
            tail --bytes +#{installer_offset + 1} "$src" 2> /dev/null | head --bytes #{zero_dat_byte_count} > install4j/0.dat

            # Extract the installer and jre.
            tail --bytes #{sfx_archive_byte_count} "$src" > sfx_archive.tar.gz

            # Unpack the installer and JRE.
            tar -xf sfx_archive.tar.gz -C install4j
            tar -xf install4j/jre.tar.gz -C $out/jre

            # Patch JRE binaries.
            for file in $out/jre/bin/*
            do
              patchelf \\
                --set-interpreter "$(cat $NIX_CC/nix-support/dynamic-linker)" \\
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
            LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH" \\
              $out/jre/bin/java -version

            # Run the installer, storing artifacts in $out.
            cd install4j && \\
              LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH" \\
              INSTALL4J_JAVA_HOME="$out/jre" \\
                $out/jre/bin/java \\
                  -DjtsConfigDir="/home/jts" \\
                  -classpath "i4jruntime.jar:launcher0.jar" \\
                  install4j.Installer#{install4j_installer} "-q" "-dir" "$out"

            # Wrap the entrypoint.
            cat << SRC > $out/bin/tws
            #! ${final.bash}/bin/bash

            # On startup, ensure the tws config dir is setup.
            TWS_DIR="\\$HOME/.tws"
            if [ ! -d "\\$TWS_DIR" ]; then
                mkdir -p "\\$TWS_DIR"
                echo "TWS config dir created at: \\$TWS_DIR"
            fi
            # Setup env, and launch tws.
            LD_LIBRARY_PATH="${libPath}:\\$LD_LIBRARY_PATH" \\
            INSTALL4J_JAVA_HOME="$out/jre" \\
            $out/tws -J-DjtsConfigDir=\\$TWS_DIR -J-Djdk.gtk.version=2
            SRC

            chmod +x $out/bin/tws
          '';
        };

      };

      packages = forAllSystems (system:
        {
          inherit (nixpkgsFor.${system}) tws;
        });

      defaultPackage = forAllSystems (system: self.packages.${system}.tws);
    };
}
  ).strip

  puts flake_contents
end