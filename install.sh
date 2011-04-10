success_message() {
	printf "
	Goldberg installation successful.

	To add a repository to Goldberg, use the following command:
		cd goldberg; bin/goldberg add <git url> <name>

	To start goldberg:
		cd goldberg; bin/goldberg start [port=3000]

	Feel free to send us your questions or feedback at goldberg@c42.in

	"
}

check_rvm()  { 
	echo -ne "Checking rvm.. "
	type -P rvm &>/dev/null || { 
		echo -ne "not available."
		echo "rvm is not not installed.  Please retry after installing rvm. (https://rvm.beginrescueend.com/rvm/install/)" >&2; 
		exit 1; 
	}  
	echo "present."
}

check_git()  { 
	echo -ne "Checking git.. "
	type -P git &>/dev/null || { 
		echo -ne "not available."
		echo "git is not not installed.  Please retry after installing git. (http://book.git-scm.com/2_installing_git.html)" >&2; 
		exit 1; 
	}  
	echo "present."
}

check_ruby()  { 
	echo -ne "Checking ruby.. "
	type -P ruby &>/dev/null || { 
		echo -ne "not available."
		echo "Ruby not installed."
		rvm install ruby-1.9.2-p180
		rvm use ruby-1.9.2-p180
	}  
	echo "present."
}

check_bundler() {
	echo -ne "Checking bundler.. "
	type -P bundle &>/dev/null || { 
		echo -ne "not available."
		echo "Bundler not installed."
		gem install bundler rake
	}  
	echo "present."
}

yes_or_no() {
	echo -n "$1 (y/n) "
	read ans
	case "$ans" in
	y|Y|yes|YES|Yes) return 0 ;;
	*) echo Exiting; return 1 ;;
	esac
}

install_goldberg() {
	git clone git://github.com/c42/goldberg.git
	cd goldberg
	rake db:create db:migrate
}


#----------------------------------------------------
printf "

-- Goldberg CI Server Installation (beta)

"
yes_or_no "This will install Goldberg in `pwd`/goldberg. Continue? " || exit 1;

check_rvm
check_ruby
check_git
install_goldberg

success_message
exit 0;