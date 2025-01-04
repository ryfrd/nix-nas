{ pkgs, config, ... }: {

  imports = [ ./hardware-configuration.nix ];

  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.forceImportRoot = false;
  networking.hostId = "f42e33e7";
  # import pool at boot
  boot.zfs.extraPools = [ "warhead" ];
  # automatic scrubbing
  services.zfs.autoScrub.enable = true;
  services.btrfs.autoScrub.enable = true;

  # zfs snapshots
  services.sanoid = {
    enable = true;
    datasets = {
      "warhead/high-prio" = {
        autoprune = true;
        autosnap = true;
        recursive = true;
        hourly = 24;
        daily = 7;
        monthly = 12;
      };
    };
  };

  networking.hostName = "homelab";

  # bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "Europe/London";
  i18n.defaultLocale = "en_GB.UTF-8";

  # enable quicksync
  boot.kernelParams = [ "i915.enable_guc=2" ];
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [ intel-media-driver intel-compute-runtime ];
  };

  nix = {
    gc.automatic = true;
    gc.options = "-d";
    settings = { experimental-features = "nix-command flakes"; };
  };

  services.tailscale.enable = true;

  users.users = {
    james = {
      isNormalUser = true;
      shell = pkgs.fish;
      initialPassword = "changethisyoupickle";
      extraGroups = [ "wheel" "docker" ];
      # let laptop in
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPzFa1hmBsCrPL5HvJZhXVEaWiZIMi34oR6AOcKD35hQ james@countess" # laptop
      ];
    };
  };

  programs.fish.enable = true;

  systemd.extraConfig = ''
    DefaultTimeoutStopSec=30s
  '';

  environment.systemPackages = with pkgs; [
    # cronjob deps
    rsync
    curl

    docker-compose
  ];

  services.cron = {
    enable = true;
    systemCronJobs =
      [ "@daily root  sh /etc/cronjobs/hetzner-backup.sh /warhead/high-prio" ];
  };

  environment.etc = {
    "cronjobs/hetzner-backup.sh" = { source = ./cronjobs/hetzner-backup.sh; };
  };

  virtualisation.docker = {
    enable = true;
    autoPrune.enable = true;
    autoPrune.flags = [ "-a" ];
    daemon.settings = { dns = [ "1.1.1.1" ]; };
  };

  powerManagement = {
    enable = true;
    cpuFreqGovernor = "powersave";
    powertop.enable = true;
  };

  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  system.stateVersion = "23.11";
}
