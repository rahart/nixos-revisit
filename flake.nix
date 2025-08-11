{
  description = "NixOS + Home Manager: clean starter";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ... }:
  let
    system = "x86_64-linux";
    pkgs = import nixpkgs { inherit system; };
  in {
    nixosConfigurations.HOST = nixpkgs.lib.nixosSystem {
      inherit system;
      modules = [
        # --- System layer ---
        ({ config, pkgs, ... }: {
          nix.settings.experimental-features = [ "nix-command" "flakes" ];
          time.timeZone = "America/Denver";

          users.users.hex = {
            isNormalUser = true;
            description = "hex"
            extraGroups = [ "wheel" "video" "audio" "input" "networkmanager" ];
            shell = pkgs.zsh;
          };

          programs.hyprland.enable = true;
          services.greetd.enable = true;
          services.greetd.package = pkgs.greetd;
          services.greetd.settings.default_session = {
            command = "${pkgs.greetd.tuigreet}/bin/tuigreet --time --remember --cmd 'dbus-run-session Hyprland'";
            user = "greeter";
          };
          users.users.greeter.isSystemUser = true;

          hardware.opengl.enable = true;
          services.pipewire = { enable = true; alsa.enable = true; pulse.enable = true; };
          services.libinput.enable = true;
          networking.networkmanager.enable = true;

          environment.systemPackages = with pkgs; [ git vim tmux kitty ];

          # Hyper-V/VM note: remove these if bare metal
          # virtualisation.hypervGuest.enable = true;
          # boot.kernelParams = [ "video=Virtual-1:1920x1080@60" ];

          system.stateVersion = "25.05";
        })

        # --- Home Manager layer wired into NixOS switch ---
        (home-manager.nixosModules.home-manager)
        {
          home-manager.useUserPackages = true;
          home-manager.users.hex = import ./home/hex.nix;
        }
      ];
    };

    # (Optional) directly target HM without system switch
    homeConfigurations."hex@HOST" = home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = [ ./home/hex.nix ];
    };
  };
}
