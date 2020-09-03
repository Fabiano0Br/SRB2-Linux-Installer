#!/bin/bash

#########################################
#	SRB2 Installer for Linux	#
# 			Made by Fafabis	#
######################################### 

VER="2.2.6" # Version name
OS=`uname -a` # OS name
ARCH=`uname -m` # Architeture
GAMEDIR=/usr/share/games/SRB2/

# Checks which distro is being used
# Arch based distros and arch
if echo $OS | grep -i -e artix -e arco -e parabola -e anarchy -e arch -e manjaro; then
	PKG="pacman -S --noconfirm "
# Debian/Ubuntu based
elif echo $OS | grep -i -e debian -e ubuntu -e pop; then
	PKG="apt install -y libgme-dev libsdl2-dev libsdl2-mixer-dev"
	export LIBGME_CFLAGS=
	export LIBGME_LDFLAGS=-lgme
# Gentoo
elif echo $OS | grep -i -e gentoo; then
	PKG="emerge libsdl2 sdl2-mixer"
fi

if echo $ARCH == "x86_64";then
	CFLAGS=LINUX64
else 
	CFLAGS=LINUX
fi

# If AUR is avaliable, make it a option
if yay -P; then
CHOICE=$(zenity \
	--width="1000"\
	--height="500"\
	--list \
	--radiolist \
	--column "Install" \
	--column "Installation" \
	--column "Details" \
	--ok-label="Install"\
	TRUE "Flatpak" "Get SRB2 from flatpak repository"\
	FALSE "Compile" "Compile SRB2"\
	FALSE "AUR" "Get SRB2 from AUR repository"
)
else 
CHOICE=$(zenity \
	--width="1000"\
	--height="500"\
	--list \
	--radiolist \
	--column "Install" \
	--column "Installation" \
	--column "Details" \
	--ok-label="Install"\
	TRUE "Flatpak" "Get SRB2 from flatpak repository"\
	FALSE "Compile" "Compile SRB2"
)
fi

if [ "$?" != 1 ]
then
PRIVATE=`zenity --password`
fi

if echo $CHOICE | grep -q "AUR"
then (
	echo 0
	echo "# Installing SRB2 from AUR..."
	yay --answerdiff=None -S srb2

  	echo 100
	echo "# Done!"
) | zenity --title "Installing SRB2 $VER" --progress --auto-kill
fi

if echo $CHOICE | grep -q "Compile" # Compiles
then (
	echo 0
	echo "# Installing packages..."
	echo $PRIVATE | sudo -S $PKG sdl2 sdl2_mixer git unzip
	echo 10
	echo "# Downloading source..."
	mkdir /home/$USER/.local/share/srb2installer/
	cd /home/$USER/.local/share/srb2installer/
	git clone https://git.magicalgirl.moe/STJr/SRB2 --branch SRB2_release_$VER

  	echo 30
	echo "# Compiling..."
	make -C SRB2/src/ LINUX64=1
	if [ "$?" != "0" ]; then
	zenity --error --width=400 --height=200 --text "Something went wrong when compiling, check logs" 
	exit 1
	fi
	echo 60
	echo "# Downloading data..."
	wget --quiet $(curl --silent "https://api.github.com/repos/STJr/SRB2/releases/latest" | grep "Data" | grep "SRB2_release_" | cut -c 31- | cut -d '"' -f 2) -O SRB2-Data.zip
	mkdir srb2data 
	wget https://flathub.org/repo/appstream/x86_64/icons/128x128/org.srb2.SRB2.png
	mv org.srb2.SRB2.png srb2data/icon.png
	echo N | unzip -d ~/.local/share/srb2installer/srb2data/ SRB2-Data.zip
	echo $PRIVATE | sudo -S mkdir -p $GAMEDIR
	echo $PRIVATE | sudo -S mv srb2data/* $GAMEDIR
	echo $PRIVATE | sudo -S mv SRB2/bin/Linux64/Release/lsdl2srb2 /usr/bin/srb2
	echo 80
	echo "# Adding icons..."
	echo $PRIVATE | sudo -S printf "[Desktop Entry]\nVersion=2.2.6\nType=Application\nName=Sonic Robo Blast 2\nComment=A 3D Sonic the Hedgehog fangame based on a modified version of Doom Legacy\nExec=srb2\nIcon=/usr/share/games/SRB2/icon.png\nTerminal=false\nCategories=Game;" > /usr/share/applications/srb2.desktop
	echo "100"
	echo "# Done!"
	) | zenity --title "Installing SRB2 $VER" --progress --auto-kill
fi 

if echo $CHOICE | grep -q "Flatpak"
then (
	echo 0
	echo "# Installing Flatpak"
	$PKG flatpak
	echo 50
	echo "# Installing SBR2"
	flatpak install -y flathub org.srb2.SRB2
	echo 90 
	echo "# Adding symbolic link"
	echo $PRIVATE | sudo -S printf "#!/bin/sh\nflatpak run org.srb2.SRB2" > /usr/bin/fsrb2
	echo $PRIVATE | sudo -S chmod 777 /usr/bin/fsrb2
	echo 100
	echo "# Done!"
	) | zenity --title "Installing SRB2 $VER" --progress --auto-kill
fi
