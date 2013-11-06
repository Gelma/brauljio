#!/bin/bash

errore () {
	echo "------"
	echo "Errore: $1"
	echo "------"
	exit 1
}

controlla_distro () {
	[ "$(lsb_release -is)" = "Ubuntu" ] || errore "brauljo funziona solo con Ubuntu"
}


controlla_distro

exit

cd /tmp || exit

for package in \
	ardesia \
	cellwriter \
	curtain \
	florence
	gnome-mag \
	gtk-recordmydesktop \
	xfce4-screenshooter \
	do
		apt-get -y install $package
	done

# installo vox-launcher
wget https://vox-launcher.googlecode.com/files/vox-launcher_0.1-1_all.deb && dpkg -i vox-launcher_0.1-1_all.deb && apt-get -f install -y

# installo spotlighter
dst="/tmp/spotlighter.deb"
[ "$(uname -m)" = 'x86_64' ] && src="https://ardesia.googlecode.com/files/spotlighter_0.3-1_amd64.deb"
[ "$(uname -m)" = 'i686' ] && src="https://ardesia.googlecode.com/files/spotlighter_0.3-1_i386.deb"
wget "$src" -O "$dst" && dpkg -i "$dst"

# installo whiteboard
wget "https://dl.dropboxusercontent.com/u/1188340/python-whiteboard%20deb%20packages/python-whiteboard_1.0.5_all.deb" && dpkg -i python-whiteboard* ; apt-get -y -f install

# installo opensankore
dst="/tmp/opensankore.zip"
[ "$(uname -m)" = 'x86_64' ] && src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_amd64.zip"
[ "$(uname -m)" = 'i686' ] && src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_i386.zip"
wget "$src" -O "$dst" && unzip "$dst" && dpkg -i Open-Sankore*.deb ; apt-get -f -y install

# installo iprase
wget 'http://try.iprase.tn.it/prodotti/software_didattico/giochi/download/iprase_2006.zip' && unzip iprase_2006.zip && losetup /dev/loop2 iprase_2006.iso && mkdir /tmp/iprase_iso && mount /dev/loop2 /tmp/iprase_iso/ && cp -a /tmp/iprase_iso/ /opt/iprase

