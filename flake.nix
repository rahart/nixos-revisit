{
  description = "NixOS 25.05 + Home Manager (hex)";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    dotfiles.url = "github:rahart/dotfiles";
    dotfiles.flake = false;
  };

  outputs = { self, nixpkgs, home-manager, dotfiles, ... }:
  let
    system = "x86_64-linux";
  in {
    nixosConfigurations.HOST = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        ({ pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];

          users.users.hex = {
            isNormalUser = true;
            extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" ];
            shell = pkgs.zsh;
          };

          networking.networkmanager.enable = true;
          environment.systemPackages = with pkgs; [ git vim tmux gcc ];

          # match your installed release
          system.stateVersion = "25.05";
        })

        # Home Manager, attached to the system
        home-manager.nixosModules.home-manager
        {
          home-manager.useUserPackages = true;
          home-manager.extraSpecialArgs = { inherit dotfiles; };
          home-manager.users.hex = import ./home/hex.nix;
        }
      ];
    };

    # Optional: build HM alone (no root)
    homeConfigurations."hex@HOST" =
      home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs { inherit system; };
        modules = [ ./home/hex.nix ];
        extraSpecialArgs = { inherit dotfiles; };
      };
  };
}

