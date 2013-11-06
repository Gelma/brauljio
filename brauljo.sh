#!/bin/bash

TMP="/tmp/brauljo"

errore () {
	echo "------"
	echo "Errore: $1"
	echo "------"
	exit 1
}

crea_area_di_lavoro () {
	area_di_lavoro="$TMP/$1"
	mkdir -p "$area_di_lavoro" && cd "$area_di_lavoro" || errore "(3) nella creazione di $area_di_lavoro"
}

controlla_distro () {
	[ "$(lsb_release -is)" = "Ubuntu" ] || errore "(1) brauljo funziona solo con Ubuntu"
}

installa_pacchetti_ufficiali () {
	elenco_software=(ardesia cellwriter curtain florence gdebi
	gtk-recordmydesktop xfce4-screenshooter)
	# gnome-mag non esiste più dopo la 12.04. Teniamo?

	for pacchetto in "${elenco_software[@]}"
	do
		sudo apt-get install -y "$pacchetto" || errore "(2) durante l'installazione di $pacchetto"
	done
}

installa_vox-launcher () {
	crea_area_di_lavoro "vox"
	wget -c https://vox-launcher.googlecode.com/files/vox-launcher_0.1-1_all.deb || errore "(4) durante lo scaricamento di Vox-Launcher"
	sudo gdebi --non-interactive vox-launcher_0.1-1_all.deb || errore "(5) nell'installazione di Vox Launcher"
	sudo apt-get install python-xlib -y # necessario per risolvere dipendenza, segnalare bug al manutentore
}

installa_spotlighter () {
	crea_area_di_lavoro "spotlighter"
	deb="spotlighter.deb"
	[ "$(arch)" = 'x86_64' ] && src="http://ardesia.googlecode.com/files/spotlighter_0.3-1_amd64.deb" || src="http://ardesia.googlecode.com/files/spotlighter_0.3-1_i386.deb"
	wget -c "$src" -O "$deb" || errore "(6) nello scaricamento di spotlighter"
	sudo gdebi --non-interactive "$deb" || errore "(7) nell'installazione di spotlighter"
}

installa_opensankore () {
	crea_area_di_lavoro "opensankore"
	zip="opensankore.zip"
	[ "$(arch)" = 'x86_64' ] && src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_amd64.zip" || src="http://ftp.open-sankore.org/current/Open-Sankore_Ubuntu_12.04_2.1.0_i386.zip"
	wget -c "$src" -O "$zip" || errore "(8) nello scaricamento di opensankore"
	unzip "$zip" || errore "(9) nell'esplosione di OpenSankore"
	sudo gdebi --non-interactive Open-Sankore*.deb || errore "(10) nell'installazione di OpenSankore"
}

installa_whiteboard () {
	# tento l'installazione dal repo
	sudo apt-get install python-whiteboard && return
	# se fallisco, faccio manualmente
	crea_area_di_lavoro "whiteboard"
	wget -c "https://dl.dropboxusercontent.com/u/1188340/python-whiteboard%20deb%20packages/python-whiteboard_1.0.5_all.deb" || errore "(11) nello scaricamento di Python Whiteboard"
	sudo gdebi --non-interactive python-whiteboard*
}

controlla_distro
installa_pacchetti_ufficiali
installa_vox-launcher
installa_spotlighter
installa_opensankore
installa_whiteboard

# installo iprase
#wget -c 'http://try.iprase.tn.it/prodotti/software_didattico/giochi/download/iprase_2006.zip' && unzip iprase_2006.zip && losetup /dev/loop2 iprase_2006.iso && mkdir /tmp/iprase_iso && mount /dev/loop2 /tmp/iprase_iso/ && cp -a /tmp/iprase_iso/ /opt/iprase

