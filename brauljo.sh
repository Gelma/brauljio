#!/bin/bash

errore () {
	echo "------"
	echo "Errore: $1"
	echo "------"
	exit 1
}

crea_area_di_lavoro () {
	area_di_lavoro="$1"
	mkdir -p "$area_di_lavoro" && cd "$area_di_lavoro" || errore "(3) nella creazione di $area_di_lavoro"
}

controlla_distro () {
	[ "$(lsb_release -is)" = "Ubuntu" ] || errore "(1) brauljo funziona solo con Ubuntu"
}

installa_pacchetti_ufficiali () {
	elenco_software=(ardesia cellwriter curtain florence gdebi gnome-mag
	gtk-recordmydesktop xfce4-screenshooter)

	for pacchetto in "${elenco_software[@]}"
	do
		apt-get install -y "$package" || errore "(2) durante l'installazione di $pacchetto"
	done
}

installa_vox-launcher () {
	crea_area_di_lavoro "/tmp/brauljo/vox"
	wget https://vox-launcher.googlecode.com/files/vox-launcher_0.1-1_all.deb || errore "(4) durante lo scaricamento di Vox-Launcher"
	gdebi --non-interactive vox-launcher_0.1-1_all.deb || errore "(5) nell'installazione di Vox Launcher"
}

installa_spotlighter () {
	crea_area_di_lavoro "/tmp/brauljo/spotlighter"
	deb="spotlighter.deb"
	[ "$(arch)" = 'x86_64' ] && src="https://ardesia.googlecode.com/files/spotlighter_0.3-1_amd64.deb" || src="https://ardesia.googlecode.com/files/spotlighter_0.3-1_i386.deb"
	wget "$src" -O "$dst" || errore "(6) nello scaricamento di spotlighter"
	gdebi --non-interactive "$dst" $deb || errore "(7) nell'installazione di spotlighter"
}

installa_opensankore () {
	crea_area_di_lavoro "/tmp/brauljo/opensankore"
	deb="opensankore.zip"
	[ "$(arch)" = 'x86_64' ] && src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_amd64.zip" || src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_i386.zip"
	wget "$src" -O "$dst" || errore "(8) nello scaricamento di opensankore"
	gdebi --non-interactive "$dst" Open-Sankore*.deb || errore "(9) nell'installazione di OpenSankore"
}

controlla_distro
installa_pacchetti_ufficiali
installa_vox-launcher
installa_spotlighter
installa_opensankore

exit

cd /tmp || exit

# installo whiteboard
wget "https://dl.dropboxusercontent.com/u/1188340/python-whiteboard%20deb%20packages/python-whiteboard_1.0.5_all.deb" && dpkg -i python-whiteboard* ; apt-get -y -f install

# installo iprase
wget 'http://try.iprase.tn.it/prodotti/software_didattico/giochi/download/iprase_2006.zip' && unzip iprase_2006.zip && losetup /dev/loop2 iprase_2006.iso && mkdir /tmp/iprase_iso && mount /dev/loop2 /tmp/iprase_iso/ && cp -a /tmp/iprase_iso/ /opt/iprase

