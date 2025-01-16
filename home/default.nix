{ config, pkgs,lib, ... }:

{
	programs={
		home-manager.enable=true;
		git.enable=true;
		zsh.oh-my-zsh.custom="${config.home.homeDirectory}/.oh-my-zsh-custom";

		i3blocks={
			enable=true;
			bars={
				top={
					playctl={
						command="${config.home.homeDirectory}/.i3blocks/playerctl";
						interval=5;
					};
					volume={
						instance="Master";
						interval="once";
						signal=10;
					};
					memory={
						label="MEM";
						interval=30;
					};
					cpu_usage={
						label="CPU";
						interval=10;
						separator=false;
					};
					temp={
						command="${config.home.homeDirectory}/.i3blocks/temperature";
						interval=10;
					};
					disk = {
						label="/";
						instance="/";
						interval=30;
					};
					iface = {
						color="#00FF00";
						interval=10;
					};
					time = {
						command="date '+%Y-%m-%d %H:%M:%S'";
						interval=5;	
					};
				};
			};
		};
	};
	xresources={
		path=null;
		properties=null;
	};
	home = {
		username = "dkozicki";
		stateVersion = "24.11";
		homeDirectory =
			if pkgs.stdenv.isDarwin then "/Users/${config.home.username}" else "/home/${config.home.username}";
		sessionVariables = {
			EDITOR = "nvim";
		};
		file={
			".Xresources" = {
				source= ./sway/Xresources;
			};
			".zshrc" = {
				source=./dotfiles/zsh/.zshrc;
			};
			".oh-my-zsh-custom/themes/agnoster-newline.zsh-theme" = {
				source=./dotfiles/zsh/agnoster-newline.zsh-theme;
			};
			
			"${config.home.homeDirectory}/.i3blocks/playerctl"={
				source=./sway/playerctl;
			};
			"${config.home.homeDirectory}/.i3blocks/temperature"={
				source=./sway/temperature;
			};

		};
	};
	fonts = {
		fontconfig.enable = true;
	};


	wayland.windowManager.sway = {
		enable=true;
		config=null;
		extraConfig = lib.fileContents ./sway/config;	
		package=null;
	};
	systemd.user.targets.tray = {
		Unit = {
			Description = "Home Manager System Tray";
			Requires = [ "graphical-session-pre.target" ];
		};
	};
	services = {
		udiskie = {
			enable=true;
			tray="always";
			notify=true;
			automount=true;
		};
		devilspie2 = {
			enable=true;
			config='''';
		};
		caffeine.enable=true;
	};

	gtk = {    
		enable = true; 
		theme = {     
			name = "Adwaita-dark";         
			package = pkgs.gnome-themes-extra;  
		};     
	};
}
