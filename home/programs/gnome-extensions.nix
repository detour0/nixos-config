{ pkgs, ... }:
{
  home.packages = [
    pkgs.bibata-cursors
  ];

  # All the cursor related stuff does nada at the moment....
  home.pointerCursor = {
    gtk.enable = true; # Enable for GTK applications
    x11.enable = true; # Enable for X11 (optional if using Wayland)
    package = pkgs.bibata-cursors; # Cursor theme package
    name = "Bibata"; # Cursor theme name
    size = 24; # Adjust cursor size as needed
  };

  dconf = {
    enable = true;
    settings = {

      "org/gnome/desktop/background" = {
        picture-uri-dark = "file://${toString ../../assets/blackhole_bw_4k.png}";
        picture-options = "zoom";
      };

      "org/gnome/shell" = {
        enabled-extensions = [
          # pkgs.gnomeExtensions.open-bar.extensionUuid
          pkgs.gnomeExtensions.blur-my-shell.extensionUuid
          pkgs.gnomeExtensions.freon.extensionUuid
          pkgs.gnomeExtensions.net-speed-simplified.extensionUuid
          pkgs.gnomeExtensions.rounded-window-corners-reborn.extensionUuid
          pkgs.gnomeExtensions.appindicator.extensionUuid
          pkgs.gnomeExtensions.caffeine.extensionUuid
          pkgs.gnomeExtensions.unblank.extensionUuid
        ];
      };

      # Optional: Configure dynamic workspaces or set a fixed number
      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 5; # Set to desired number of workspaces
      };

      # Configure keyboard shortcuts for switching to specific workspaces
      "org/gnome/desktop/wm/keybindings" = {
        switch-to-workspace-1 = [ "<Super>z" ]; # Switch to Workspace 1
        switch-to-workspace-2 = [ "<Super>x" ]; # Switch to Workspace 2
        switch-to-workspace-3 = [ "<Super>c" ]; # Switch to Workspace 3
        switch-to-workspace-4 = [ "<Super>v" ]; # Switch to Workspace 4
        switch-to-workspace-5 = [ "<Super>b" ]; # Switch to Workspace 5

        # Move windows to specific workspaces
        move-to-workspace-1 = [ "<Super><Alt>z" ];
        move-to-workspace-2 = [ "<Super><Alt>x" ];
        move-to-workspace-3 = [ "<Super><Alt>c" ];
        move-to-workspace-4 = [ "<Super><Alt>v" ];
        move-to-workspace-5 = [ "<Super><Alt>b" ];
      };

      "org/gnome/mutter" = {
        workspaces-only-on-primary = false; # Ensure workspaces span all monitors
      };

      "org/gnome/desktop/interface" = {
        cursor-theme = "Bibata"; # Match the home.pointerCursor.name
      };
      "org.gnome.settings-daemon.plugins.power" = {
        sleep-inactive-ac-type = "nothing";
      };

      "org/gnome/shell/extensions/openbar" = {
        accent-color = [
          0.0
          0.75
          0.75
        ];
        accent-override = false;
        apply-accent-shell = false;
        apply-flatpak = false;
        apply-gtk = false;
        apply-menu-notif = false;
        apply-menu-shell = false;
        autofg-bar = false;
        autofg-menu = false;
        autohg-menu = true;
        autotheme-dark = "Select Theme";
        autotheme-font = false;
        autotheme-light = "Select Theme";
        autotheme-refresh = false;
        balpha = 0.65;
        bartype = "Floating";
        bcolor = [
          0.173
          0.176
          0.231
        ];
        bg-change = true;
        bgalpha = 0.84;
        bgalpha2 = 1.0;
        bgcolor = [
          0.122
          0.137
          0.176
        ];
        bgcolor2 = [
          0.200
          0.208
          0.260
        ];
        bgpalette = true;
        bguri = "file:///home/flavio/.config/background";
        border-wmax = false;
        bordertype = "solid";
        bottom-margin = 6.5;
        boxalpha = 0.0;
        boxcolor = [
          1.0
          1.0
          1.0
        ];
        bradius = 6.0;
        buttonbg-wmax = true;
        bwidth = 0.5;
        candy1 = [
          0.976
          0.494
          0.529
        ];
        candy10 = [
          0.09
          0.19
          0.72
        ];
        candy11 = [
          0.75
          0.49
          0.44
        ];
        candy12 = [
          1.0
          0.92
          0.12
        ];
        candy2 = [
          0.643
          0.659
          0.820
        ];
        candy3 = [
          0.645
          0.660
          0.823
        ];
        candy4 = [
          0.643
          0.659
          0.820
        ];
        candy5 = [
          0.639
          0.659
          0.820
        ];
        candy6 = [
          0.643
          0.659
          0.820
        ];
        candy7 = [
          0.95
          0.12
          0.67
        ];
        candy8 = [
          0.18
          0.76
          0.49
        ];
        candy9 = [
          0.93
          0.20
          0.23
        ];
        candyalpha = 1.0;
        candybar = true;
        card-hint = 10;
        color-scheme = "prefer-dark";
        count1 = 295222;
        count10 = 40;
        count11 = 16;
        count12 = 7;
        count2 = 106329;
        count3 = 55685;
        count4 = 49379;
        count5 = 27621;
        count6 = 24762;
        count7 = 1469;
        count8 = 1306;
        count9 = 77;
        cust-margin-wmax = false;
        dark-accent-color = [
          0.0
          0.75
          0.75
        ];
        dark-bcolor = [
          0.173
          0.176
          0.231
        ];
        dark-bgcolor = [
          0.122
          0.137
          0.176
        ];
        dark-bgcolor-wmax = [
          0.125
          0.125
          0.125
        ];
        dark-bgcolor2 = [
          0.200
          0.208
          0.260
        ];
        dark-bguri = "file:///home/flavio/.config/background";
        dark-boxcolor = [
          1.0
          1.0
          1.0
        ];
        dark-candy1 = [
          0.976
          0.494
          0.529
        ];
        dark-candy10 = [
          0.09
          0.19
          0.72
        ];
        dark-candy11 = [
          0.75
          0.49
          0.44
        ];
        dark-candy12 = [
          1.0
          0.92
          0.12
        ];
        dark-candy13 = [
          0.38
          0.63
          0.92
        ];
        dark-candy14 = [
          0.37
          0.36
          0.39
        ];
        dark-candy15 = [
          0.40
          0.23
          0.72
        ];
        dark-candy16 = [
          1.0
          0.32
          0.32
        ];
        dark-candy2 = [
          0.643
          0.659
          0.820
        ];
        dark-candy3 = [
          0.645
          0.660
          0.823
        ];
        dark-candy4 = [
          0.643
          0.659
          0.820
        ];
        dark-candy5 = [
          0.639
          0.659
          0.820
        ];
        dark-candy6 = [
          0.643
          0.659
          0.820
        ];
        dark-candy7 = [
          0.95
          0.12
          0.67
        ];
        dark-candy8 = [
          0.18
          0.76
          0.49
        ];
        dark-candy9 = [
          0.93
          0.20
          0.23
        ];
        dark-dbgcolor = [
          0.125
          0.125
          0.125
        ];
        dark-fgcolor = [
          0.180
          0.184
          0.235
        ];
        dark-hscd-color = [
          0.0
          0.7
          0.75
        ];
        dark-iscolor = [
          0.125
          0.125
          0.125
        ];
        dark-mbcolor = [
          0.524
          0.538
          0.680
        ];
        dark-mbgcolor = [
          0.176
          0.180
          0.235
        ];
        dark-mfgcolor = [
          0.953
          0.902
          0.905
        ];
        dark-mhcolor = [
          0.639
          0.659
          0.820
        ];
        dark-mscolor = [
          0.427
          0.445
          0.590
        ];
        dark-mshcolor = [
          0.420
          0.404
          0.537
        ];
        dark-palette1 = [
          42
          47
          63
        ];
        dark-palette10 = [
          90
          100
          120
        ];
        dark-palette11 = [
          20
          20
          36
        ];
        dark-palette12 = [
          137
          140
          150
        ];
        dark-palette2 = [
          107
          103
          137
        ];
        dark-palette3 = [
          201
          116
          126
        ];
        dark-palette4 = [
          61
          73
          105
        ];
        dark-palette5 = [
          79
          81
          110
        ];
        dark-palette6 = [
          126
          93
          114
        ];
        dark-palette7 = [
          22
          21
          20
        ];
        dark-palette8 = [
          251
          208
          72
        ];
        dark-palette9 = [
          208
          44
          24
        ];
        dark-shcolor = [
          0.0
          0.0
          0.0
        ];
        dark-smbgcolor = [
          0.290
          0.295
          0.360
        ];
        dark-vw-color = [
          0.0
          0.7
          0.75
        ];
        dark-winbcolor = [
          0.0
          0.7
          0.75
        ];
        dashdock-style = "Default";
        dbgalpha = 0.85;
        dbgcolor = [
          0.125
          0.125
          0.125
        ];
        dborder = true;
        dbradius = 100.0;
        default-font = "Sans 12";
        disize = 48.0;
        dshadow = true;
        fgalpha = 1.0;
        fgcolor = [
          0.180
          0.184
          0.235
        ];
        font = "Monospace Bold 11";
        gradient = false;
        gradient-direction = "vertical";
        gtk-popover = false;
        gtk-shadow = "Default";
        gtk-transparency = 1.0;
        halpha = 0.5;
        handle-border = 3.0;
        hbar-gtk3only = false;
        hcolor = [
          0.0
          0.7
          0.9
        ];
        headerbar-hint = 0;
        heffect = false;
        height = 28.0;
        hscd-color = [
          0.0
          0.7
          0.75
        ];
        import-export = true;
        isalpha = 0.84;
        iscolor = [
          0.125
          0.125
          0.125
        ];
        light-accent-color = [
          0.0
          0.75
          0.75
        ];
        light-bcolor = [
          1.0
          1.0
          1.0
        ];
        light-bgcolor = [
          0.125
          0.125
          0.125
        ];
        light-bgcolor2 = [
          0.0
          0.7
          0.75
        ];
        light-bguri = "file:///home/flavio/.config/background";
        light-boxcolor = [
          0.125
          0.125
          0.125
        ];
        light-candy1 = [
          0.0
          0.61
          0.74
        ];
        light-candy10 = [
          0.09
          0.19
          0.72
        ];
        light-candy11 = [
          0.75
          0.49
          0.44
        ];
        light-candy12 = [
          1.0
          0.92
          0.12
        ];
        light-candy13 = [
          0.38
          0.63
          0.92
        ];
        light-candy14 = [
          0.37
          0.36
          0.39
        ];
        light-candy15 = [
          0.40
          0.23
          0.72
        ];
        light-candy16 = [
          1.0
          0.32
          0.32
        ];
        light-candy2 = [
          1.0
          0.41
          0.41
        ];
        light-candy3 = [
          0.63
          0.16
          0.8
        ];
        light-candy4 = [
          0.94
          0.60
          0.23
        ];
        light-candy5 = [
          0.03
          0.41
          0.62
        ];
        light-candy6 = [
          0.56
          0.18
          0.43
        ];
        light-candy7 = [
          0.95
          0.12
          0.67
        ];
        light-candy8 = [
          0.18
          0.76
          0.49
        ];
        light-candy9 = [
          0.93
          0.20
          0.23
        ];
        light-dbgcolor = [
          0.125
          0.125
          0.125
        ];
        light-fgcolor = [
          1.0
          1.0
          1.0
        ];
        light-hcolor = [
          0.0
          0.7
          0.9
        ];
        light-hscd-color = [
          0.0
          0.7
          0.75
        ];
        light-iscolor = [
          0.125
          0.125
          0.125
        ];
        light-mbcolor = [
          1.0
          1.0
          1.0
        ];
        light-mbgcolor = [
          0.125
          0.125
          0.125
        ];
        light-mfgcolor = [
          1.0
          1.0
          1.0
        ];
        light-mhcolor = [
          0.0
          0.7
          0.9
        ];
        light-mscolor = [
          0.0
          0.7
          0.75
        ];
        light-mshcolor = [
          1.0
          1.0
          1.0
        ];
        light-palette1 = [
          42
          47
          63
        ];
        light-palette10 = [
          90
          100
          120
        ];
        light-palette11 = [
          20
          20
          36
        ];
        light-palette12 = [
          137
          140
          150
        ];
        light-palette2 = [
          107
          103
          137
        ];
        light-palette3 = [
          201
          116
          126
        ];
        light-palette4 = [
          61
          73
          105
        ];
        light-palette5 = [
          79
          81
          110
        ];
        light-palette6 = [
          126
          93
          114
        ];
        light-palette7 = [
          22
          21
          20
        ];
        light-palette8 = [
          251
          208
          72
        ];
        light-palette9 = [
          208
          44
          24
        ];
        light-shcolor = [
          0.0
          0.0
          0.0
        ];
        light-smbgcolor = [
          0.125
          0.125
          0.125
        ];
        light-winbcolor = [
          0.0
          0.7
          0.75
        ];
        margin = 5.9;
        margin-wmax = 2.0;
        mbalpha = 0.19;
        mbcolor = [
          0.524
          0.538
          0.680
        ];
        mbg-gradient = false;
        mbgalpha = 1.0;
        mbgcolor = [
          0.176
          0.180
          0.235
        ];
        menu-radius = 10.0;
        menustyle = true;
        mfgalpha = 1.0;
        mfgcolor = [
          0.953
          0.902
          0.905
        ];
        mhcolor = [
          0.639
          0.659
          0.820
        ];
        monitor-height = 1080;
        monitor-width = 1920;
        monitors = "all";
        mscolor = [
          0.427
          0.445
          0.590
        ];
        mshalpha = 0.0;
        mshcolor = [
          0.420
          0.404
          0.537
        ];
        neon = false;
        neon-wmax = false;
        notif-radius = 9.0;
        palette1 = [
          42
          47
          63
        ];
        palette10 = [
          90
          100
          120
        ];
        palette11 = [
          20
          20
          36
        ];
        palette12 = [
          137
          140
          150
        ];
        palette2 = [
          107
          103
          137
        ];
        palette3 = [
          201
          116
          126
        ];
        palette4 = [
          61
          73
          105
        ];
        palette5 = [
          79
          81
          110
        ];
        palette6 = [
          126
          93
          114
        ];
        palette7 = [
          22
          21
          20
        ];
        palette8 = [
          251
          208
          72
        ];
        palette9 = [
          208
          44
          24
        ];
        pause-reload = false;
        position = "bottom";
        prominent1 = [
          100
          100
          100
        ];
        prominent2 = [
          100
          100
          100
        ];
        prominent3 = [
          100
          100
          100
        ];
        prominent4 = [
          100
          100
          100
        ];
        prominent5 = [
          100
          100
          100
        ];
        prominent6 = [
          100
          100
          100
        ];
        qtoggle-radius = 9.0;
        radius-bottomright = true;
        radius-topright = true;
        reloadstyle = false;
        removestyle = false;
        sbar-gradient = "none";
        set-fullscreen = true;
        set-notif-position = false;
        set-notifications = false;
        set-overview = false;
        set-yarutheme = false;
        shadow = false;
        slider-height = 4.0;
        smbgalpha = 0.95;
        smbgcolor = [
          0.290
          0.295
          0.360
        ];
        smbgoverride = true;
        success-color = [
          0.15
          0.635
          0.41
        ];
        traffic-light = false;
        trigger-autotheme = false;
        trigger-reload = false;
        vpad = 4.0;
        vw-color = [
          0.0
          0.7
          0.75
        ];
        warning-color = [
          0.96
          0.83
          0.17
        ];
        width-bottom = true;
        width-left = true;
        width-top = true;
        winbalpha = 0.75;
        winbcolor = [
          0.0
          0.7
          0.75
        ];
        winbradius = 15.0;
        winbwidth = 0.0;
        window-hint = 0;
        wmax-hbarhint = false;
        wmaxbar = false;
      };
    };
  };
}
