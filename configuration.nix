{ pkgs, config, ... }: {

  imports = [
    ./hardware-configuration.nix
  ];

  # automatic nix garbage collection
  nix.gc = {
    automatic = true;
    dates = "weekly";
  };

  nix.settings = {
    # enable flakes
    experimental-features = "nix-command flakes";
    # saves some disk space
    auto-optimise-store = true;
    # allows remote rebuild
    trusted-users = [ "james" ];
  };

  networking.hostName = "keep";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # firewall !!!
  networking.firewall.enable = true;

  # ssh access
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };
  # open ssh port
  networking.firewall.allowedTCPPorts = [ 22 ];

  # tailscale daemon
  services.tailscale.enable = true;

  programs.fish.enable = true;
  users.users.james = {
    isNormalUser = true;
    initialPassword = "thisisabadpassword";
    shell = pkgs.fish;
    # sudo
    extraGroups = [ "wheel" "docker" ];
    # let me in
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzFa1hmBsCrPL5HvJZhXVEaWiZIMi34oR6AOcKD35hQ james@countess"
    ];
  };

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # install some basic stuff for humans
  environment.systemPackages = with pkgs; [
    neovim
    git
    tree
    curl
    dua
    ranger
    rsync
    docker-compose
    neofetch
  ];

  virtualisation.docker = {
    enable = true;
    liveRestore = false;
    autoPrune.enable = true;
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  services.zfs.autoScrub.enable = true;
  services.btrfs.autoScrub.enable = true;

  services.cron = {
    enable = true;
  };

}
