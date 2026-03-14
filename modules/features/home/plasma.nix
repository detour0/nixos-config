{ ... }:
{

  programs.plasma = {
    enable = true;
    # Set all options not declard in pm to default on login
    overrideConfig = false;
    #
    # Some high-level settings:
    #
    workspace = {
      lookAndFeel = "org.kde.breezedark.desktop";
      cursor = {
        theme = "Breeze";
        size = 32;
      };
      iconTheme = "Papirus-Dark";
    };

    hotkeys.commands."launch-konsole" = {
      name = "Launch Konsole";
      key = "Meta+Alt+K";
      command = "konsole";
    };

    fonts = {
      general = {
        family = "JetBrains Mono";
        pointSize = 12;
      };
    };

    panels = [
      # Windows-like panel at the bottom
      {
        location = "bottom";
        widgets = [
          # We can configure the widgets by adding the name and config
          # attributes. For example to add the the kickoff widget and set the
          # icon to "nix-snowflake-white" use the below configuration. This will
          # add the "icon" key to the "General" group for the widget in
          # ~/.config/plasma-org.kde.plasma.desktop-appletsrc.
          {
            name = "org.kde.plasma.kickoff";
            config = {
              General = {
                icon = "nix-snowflake";
                alphaSort = true;
              };
            };
          }
          # Or you can configure the widgets by adding the widget-specific options for it.
          # See modules/widgets for supported widgets and options for these widgets.
          # For example:
          # {
          #  kickoff = {
          #    sortAlphabetically = true;
          #    icon = "nix-snowflake-white";
          #  };
          # }
          # Adding configuration to the widgets can also for example be used to
          # pin apps to the task-manager, which this example illustrates by
          # pinning dolphin and konsole to the task-manager by default with widget-specific options.
          # {
          #   iconTasks = {
          #     launchers = [
          #       "applications:org.kde.dolphin.desktop"
          #       "applications:org.kde.konsole.desktop"
          #     ];
          #   };
          # }
          # Or you can do it manually, for example:
          {
            name = "org.kde.plasma.icontasks";
            config = {
              General = {
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "applications:org.kde.konsole.desktop"
                ];
              };
            };
          }
          # If no configuration is needed, specifying only the name of the
          # widget will add them with the default configuration.
          # "org.kde.plasma.marginsseparator"
          # If you need configuration for your widget, instead of specifying the
          # the keys and values directly using the config attribute as shown
          # above, plasma-manager also provides some higher-level interfaces for
          # configuring the widgets. See modules/widgets for supported widgets
          # and options for these widgets. The widgets below shows two examples
          # of usage, one where we add a digital clock, setting 12h time and
          # first day of the week to Sunday and another adding a systray with
          # some modifications in which entries to show.
          {
            digitalClock = {
              calendar.firstDayOfWeek = "monday";
              time.format = "24h";
            };
          }
          {
            systemTray.items = {
              # We explicitly show bluetooth and battery
              shown = [
                # "org.kde.plasma.battery"
                # "org.kde.plasma.bluetooth"
              ];
              # And explicitly hide networkmanagement and volume
              hidden = [
                # "org.kde.plasma.networkmanagement"
                # "org.kde.plasma.volume"
              ];
            };
          }
        ];
        hiding = "normalpanel";
      }
    ];

    powerdevil = {
      AC = {
        powerButtonAction = "lockScreen";
        autoSuspend = {
          action = "nothing";
          # idleTimeout = 1000;
        };
        turnOffDisplay = {
          idleTimeout = 1000;
          idleTimeoutWhenLocked = 20;
        };
      };
      battery = {
        powerButtonAction = "sleep";
        whenSleepingEnter = "standbyThenHibernate";
      };
      lowBattery = {
        whenLaptopLidClosed = "hibernate";
      };
    };

    kwin = {
      edgeBarrier = 0; # Disables the edge-barriers introduced in plasma 6.1
      cornerBarrier = false;
      # scripts.polonium.enable = false;
    };

    kscreenlocker = {
      lockOnResume = true;
      timeout = 120;
    };

    #
    # Some mid-level settings:
    #
    shortcuts = {
      ksmserver = {
        "Lock Session" = [
          "Screensaver"
          "Meta+Ctrl+Alt+L"
        ];
      };

/*       kwin = {
        # "Expose" = "Meta+,";
        "Switch Window Down" = "Meta+J";
        "Switch Window Left" = "Meta+H";
        "Switch Window Right" = "Meta+L";
        "Switch Window Up" = "Meta+K";
      }; */
#       ActivityManager = {
#           "switch-to-activity-2f6b3df2-80a8-4dba-83b9-eeb9033d9e27" = "Meta+V,none,Switch to activity \"browsing\"";
#           "switch-to-activity-ef316a8a-24ef-4c39-81bd-8c436ad5fa63" = "Meta+C,none,Switch to activity \"markets\"";
#           "switch-to-activity-46f11b91-3ab9-4869-9b95-93801e7b20b5" = "Meta+X,none,Switch to activity \"coding/learn\"";
#           "switch-to-activity-e860db6f-3d07-4810-9667-4996111d2c6f" = "Meta+Z,none,Switch to activity \"coding/projects\"";
#       };
    };

    #
    # Some low-level settings:
    #
    configFile = {
      baloofilerc."Basic Settings"."Indexing-Enabled" = false;
      kwinrc = {
        "org.kde.kdecoration2".ButtonsOnLeft = "SF";
        "NightColor"."Active" = true;
        "NightColor"."Mode" = "Location";
        "Plugins"."poloniumEnabled" = false;
      };
      # Disables splash screen
      ksplashrc = {
        "[KSplash]" = {
            "Engine" = "None";
        };
      };
      kactivitymanagerdrc = {
        "activities" = {
          "2f6b3df2-80a8-4dba-83b9-eeb9033d9e27" = "browsing";
          "ef316a8a-24ef-4c39-81bd-8c436ad5fa63" = "markets";
          "46f11b91-3ab9-4869-9b95-93801e7b20b5" = "coding/learn";
          "e860db6f-3d07-4810-9667-4996111d2c6f" = "coding/projects";
        };
      };
    };
  };
}
