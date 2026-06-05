# Edit this configuration file to define what should be installed on your 
# system.  Help is available in the configuration.nix(5) man page and in 
# the NixOS manual (accessible by running 'nixos-help').
#
# ==================================================================== 
# IMPORTANT: This configuration uses flakes! 
# ==================================================================== To 
# rebuild your system, use the following commands:
#
#   sudo nixos-rebuild switch --flake /etc/nixos#nixos sudo nixos-rebuild 
#   boot --flake /etc/nixos#nixos sudo nixos-rebuild test --flake 
#   /etc/nixos#nixos
#
# After editing this file, remember to commit changes: cd /etc/nixos && 
#   sudo git add -A && sudo git commit -m "Update config"
#
# Cleanup commands (boot partition is only 96MB!): sudo 
#   nix-collect-garbage -d # Delete all old generations sudo nix-env 
#   --delete-generations +3 -p /nix/var/nix/profiles/system # Keep last 3 
#   sudo nixos-rebuild boot --flake /etc/nixos#nixos # Rebuild boot 
#   entries df -h /boot # Check boot partition space
# ====================================================================

{ config, pkgs, ... }:

let
  codex = pkgs.stdenv.mkDerivation rec {
    pname = "codex";
    version = "0.118.0";
    src = pkgs.fetchurl {
      url = "https://github.com/openai/codex/releases/download/rust-v${version}/codex-x86_64-unknown-linux-gnu.tar.gz";
      sha256 = "sha256-Ig8VyhxjnpBarjhdqWDhiXiC/udmU/X59d/6X3VPfJg=";
    };
    nativeBuildInputs = [ pkgs.autoPatchelfHook ];
    buildInputs = [ pkgs.stdenv.cc.cc.lib pkgs.openssl pkgs.libcap pkgs.zlib ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/bin
      cp codex-x86_64-unknown-linux-gnu $out/bin/codex
      chmod +x $out/bin/codex
    '';
  };

  lazysqlNvim = pkgs.lazysql.overrideAttrs (old: rec {
    version = "0.5.1";
    src = pkgs.fetchFromGitHub {
      owner = "jorgerojas26";
      repo = "lazysql";
      rev = "v${version}";
      hash = "sha256-rdXZmvyBzVcvycFP/AmrnOuVauQKrmJ1ZTIXc0TWxSI=";
    };
    vendorHash = "sha256-FbAt/HsjoxqAKWQqqWN2xuyyTG2Ic4DcyEU4O0rjpQE=";
    ldflags = [ "-X main.version=${version}" ];
  });
in


{ imports = [ ./hardware-configuration.nix ];

  boot.loader.efi.canTouchEfiVariables = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.systemd-boot.configurationLimit = 5;

  nix.settings.experimental-features = [ "nix-command" "flakes"];

  networking.hostName = "nixos";
  networking.firewall.trustedInterfaces = [ "docker0" ]; 
  networking.firewall.extraCommands = ''
    iptables -I INPUT -i br-+ -j ACCEPT '';

  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Brussels";

  i18n.defaultLocale = "en_US.UTF-8";

  services.xserver.videoDrivers = ["nvidia"];

  services.xserver.xkb = { layout = "pl"; variant = "";
  };

  console.keyMap = "pl2";

  users.users.jente = { isNormalUser = true; description = "Jente"; 
    extraGroups = [ "networkmanager" "wheel" "docker" "adbusers" "kvm" "dialout" ]; 
    packages = with pkgs; [
      (wineWowPackages.full.override { wineRelease = "staging"; 
        mingwSupport = true;
      })
      winetricks ]; shell = pkgs.zsh;
  };

  nixpkgs.config.allowUnfree = true;

  programs.direnv.enable = true; programs.direnv.nix-direnv.enable = 
  true;

  environment.systemPackages = with pkgs; [
    egl-wayland
    vim 
    wget
    pkgs.waybar
    pkgs.dunst
    libnotify
    swaybg
    tmux
    rofi
    kitty
    firefox
    google-chrome
    nwg-displays
    code-cursor
    vscode
    docker
    jetbrains-toolbox
    gitkraken
    teams-for-linux
    neovim
    wezterm
    unzip
    git
    gcc
    lazydocker
    lazysqlNvim
    vesktop
    spotify
    blueman
    ctop
    pavucontrol
    claude-code
    codex
    signal-desktop
    slack
    htop
    btop
    davinci-resolve
    blender
    darktable
    figma-linux
    krita
    audacity
    reaper
    penpot-desktop
    ffmpeg
    insomnia
    playerctl
    hyprpanel
    mkcert
    yazi
    ripgrep (pkgs.python3.withPackages(ps: [ ps.pygame ]))
    lazygit
    lsd
    zellij
    steam-run
    xwayland-satellite
    bun
    pkgs.libsecret 
    pkg-config
    devenv
    keymapp
    obsidian
    lsof
    termscp
    xclip
    jq
    zed-editor
    helix
    rclone
    monaspace

    # Rust development
    rustc
    cargo
    rustfmt
    clippy
    rust-analyzer

    # Language servers
    lua-language-server
    pyright
    yaml-language-server
    bash-language-server 
    vscode-langservers-extracted
    dockerfile-language-server-nodejs
    vtsls 
    intelephense

    # Go development
    go gopls

    # Flutter & Android development
    flutter 
    android-studio 
    android-tools 
    jdk17
  ];

  programs.fuse.userAllowOther = true;

  hardware.keyboard.zsa.enable = true;

  programs.zsh = { enable = true; autosuggestions.enable = true; 
    syntaxHighlighting.enable = true;
  };

  hardware.bluetooth.enable = true; hardware.bluetooth.powerOnBoot = 
  true;

  services.blueman.enable = true;

  services.udisks2.enable = true;

  # PlatformIO udev rules for hardware access
  services.udev.packages = [ 
    pkgs.platformio-core.udev 
    pkgs.openocd
  ];

  virtualisation.docker.enable = true;
  
  systemd.slices.docker = { description = "Slice for Docker containers"; 
    sliceConfig = {
      MemoryMax = "30G";
    };
  };

  zramSwap = { enable = true; memoryPercent = 25;
  };

  # ========================================================================== 
  # Memory management - prevent system hangs at high memory usage 
  # ==========================================================================

  # Option 1: Enable systemd-oomd to kill processes before system hangs 
  # Without this, oomd runs but doesn't monitor any cgroups
  systemd.oomd = { enable = true; enableRootSlice = true; 
    enableUserSlices = true; enableSystemSlice = true;
  };

  systemd.services."user@".serviceConfig.ManagedOOMMemoryPressureLimit = 
  "90%";

  # Option 2: Disk-based swap as emergency overflow when zram can't help 
  # zram uses RAM for compression, so it can't save you when RAM is 
  # critically low
  swapDevices = [{ device = "/var/lib/swapfile"; size = 8 * 1024;
  }];

  # Option 3: Kernel tuning for earlier memory reclaim
  boot.kernel.sysctl = {
    "vm.min_free_kbytes" = 131072; # 128MB reserved free memory
    "vm.watermark_scale_factor" = 50; #Less aggressive reclaim (default is 10)
  };

  nix.gc = { automatic = true; dates = "weekly"; options = "--delete-older-than 7d"; };


  # Some programs need SUID wrappers, can be configured further or are 
  # started in user sessions. programs.mtr.enable = true; 
  # programs.gnupg.agent = {
  #   enable = true; enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon. services.openssh.enable = true;

  # Open ports in the firewall. networking.firewall.allowedTCPPorts = [ 
  # ... ]; networking.firewall.allowedUDPPorts = [ ... ]; Or disable the 
  # firewall altogether. networking.firewall.enable = false;

  # This value determines the NixOS release from which the default 
  # settings for stateful data, like file locations and database versions 
  # on your system were taken. It‘s perfectly fine and recommended to 
  # leave this value at the release version of the first install of this 
  # system. Before changing this value read the documentation for this 
  # option (e.g. man configuration.nix or on 
  # https://nixos.org/nixos/options.html).
  system.stateVersion = "25.05"; # Did you read the comment?

  programs.hyprland = { enable = true; xwayland.enable = true;
  };

  services.xserver.desktopManager.cinnamon.enable = true;
  services.power-profiles-daemon.enable = false;

  programs.niri.enable = true;

  programs.mango.enable = true;
  
  environment.variables = {
    EDITOR = "nvim";
    VISUAL = "nvim";
    CLAUDE_CODE_EFFORT_LEVEL = "max";
  };

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; CHROME_EXECUTABLE = "google-chrome-stable";
    ANDROID_HOME = "/home/jente/Android/Sdk"; EDITOR = "nvim"; VISUAL =
    "nvim";
    GBM_BACKEND = "nvidia-drm";
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    LIBVA_DRIVER_NAME = "nvidia";
  };

  xdg.portal.enable = true; xdg.portal.extraPortals = [ 
  pkgs.xdg-desktop-portal-gtk ];

  security.rtkit.enable = true; services.pipewire = {
    enable = true; alsa.enable = true; alsa.support32Bit = true; 
    pulse.enable = true; jack.enable = true; wireplumber.configPackages = 
    [
      (pkgs.writeTextDir 
        "share/wireplumber/bluetooth.lua.d/51-bluez-config.lua" '' 
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true, ["bluez5.enable-msbc"] = true, 
          ["bluez5.enable-hw-volume"] = false, -- Disable absolute volume 
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '') ];
  };
  
  services.xserver.enable = true; services.displayManager.sddm.enable = 
  true; services.displayManager.sddm.wayland.enable = true;

  # Enable OpenGL
  hardware.graphics = { enable = true; enable32Bit = true;
  };

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;

    # Power management - helps prevent crashes on Wayland
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module - RECOMMENDED for RTX 4090 
    # (Ada Lovelace) This is more stable on Wayland/Hyprland than the 
    # proprietary module
    open = true;

    # Enable the Nvidia settings menu
    nvidiaSettings = true;

    # Use beta driver
    package = config.boot.kernelPackages.nvidiaPackages.beta;
  };

  services.flatpak.enable = true;

  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };

  services.auto-cpufreq = {
    enable = true;
    settings = {
      charger = {
        governor = "performance";
        turbo = "auto";
      };
      battery = {
        governor = "schedutil";
        turbo = "auto";
      };
    };
  };

  programs.firefox.enable = true;

  programs.nix-ld = { enable = true; libraries = with pkgs; [
      xorg.libX11 xorg.libXext xorg.libXrender xorg.libXtst xorg.libXi
      xorg.libXcursor xorg.libXrandr xorg.libXcomposite xorg.libXdamage
      xorg.libXfixes fontconfig freetype zlib glib gtk3 libGL libGLU
    ];
  };

  programs.obs-studio = { enable = true; enableVirtualCamera = true; 
    plugins = with pkgs.obs-studio-plugins; [
      wlrobs obs-backgroundremoval obs-pipewire-audio-capture 
      obs-vkcapture
    ];
  };

  # Thunar file manager
  programs.thunar = { enable = true; plugins = with pkgs.xfce; [
      thunar-archive-plugin thunar-volman
    ];
  };
  services.gvfs.enable = true; # Trash, mount, and other functionalities 
  services.tumbler.enable = true; # Thumbnail support

  xdg.mime.defaultApplications = { "text/html" = "firefox.desktop"; 
    "x-scheme-handler/http" = "firefox.desktop"; "x-scheme-handler/https" 
    = "firefox.desktop"; "x-scheme-handler/about" = "firefox.desktop"; 
    "x-scheme-handler/unknown" = "firefox.desktop";
    # Thunar as default file manager
    "inode/directory" = "thunar.desktop"; 
    "application/x-gnome-saved-search" = "thunar.desktop";
  };

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;
}
