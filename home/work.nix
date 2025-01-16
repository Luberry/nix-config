{ config, pkgs,lib,inputs ,... }:
{
	programs = {
		git={
			userName="Dylan Kozicki";
			userEmail="dylan.kozicki@imubit.com";
			signing={
				key="${config.home.homeDirectory}/.ssh/id_ed25519.pub";
				signByDefault=true;
			};
			extraConfig.gpg.format="ssh";
		};

	};
	home={
		file={
			".zshrc-extra.zsh" = {
				source=./dotfiles/zsh/.zshrc.work.zsh;
			};
		};
	};
}
