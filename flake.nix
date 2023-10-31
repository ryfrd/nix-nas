{
  inputs.nixpkgs.url = github:NixOS/nixpkgs/nixos-23.05;
  outputs = { nixpkgs, ... }: {
    nixosConfigurations."keep" = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        ./configuration.nix
      ];
    };
  };
}
