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
	unzip -f "$zip" || errore "(9) nell'esplosione di OpenSankore"
	sudo gdebi --non-interactive Open-Sankore*.deb || errore "(10) nell'installazione di OpenSankore"
}

installa_whiteboard () {
	# tento l'installazione dal repo
	sudo apt-get install -y python-whiteboard && return || errore "(11) installazione Python-Whiteboard da Ubuntu"
	# se fallisco, faccio manualmente
	crea_area_di_lavoro "whiteboard"
	wget -c "https://dl.dropboxusercontent.com/u/1188340/python-whiteboard%20deb%20packages/python-whiteboard_1.0.5_all.deb" || errore "(12) nello scaricamento di Python Whiteboard"
	sudo gdebi --non-interactive python-whiteboard*
}

installa_iprase () {
	# controllo se l'installazione gia' esiste
	[ -d /opt/iprase ] && return
	# diversamente procedo
	crea_area_di_lavoro "iprase"
	wget -c 'http://try.iprase.tn.it/prodotti/software_didattico/giochi/download/iprase_2006.zip' || errore "(13) nello scaricamento di IPRASE"
	unzip -f iprase_2006.zip || errore "(14) nell'esplosione di IPRASE"
	mkdir -p ISO || errore "(15) creazione mountpoint"
	sudo mount -o loop,ro iprase_2006.iso ISO || errore "(16) mount dell'iso"
	sudo cp -a ISO/ /opt/iprase || errore "(17) durante copia file IPRASE"
	sudo umount ISO
}

controlla_distro
installa_pacchetti_ufficiali
installa_vox-launcher
installa_spotlighter
installa_opensankore
installa_whiteboard
installa_iprase
