#!/bin/bash

TMP="/tmp/brauljo"
SCRIPT="$(readlink -e $0)"
BASE="$(dirname "$BASE")"
CACHE="$BASE/cache"
ubuntu_release=$(lsb_release -rs)

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

configura_repository_esterni () {
	if [ -e "/etc/apt/sources.list.d/webupd8team-java-saucy.list" ] ; then
		sudo add-apt-repository -y ppa:webupd8team/java || errore "(19) configurazione PPA Java"
	fi
	
	if [ -e "/etc/apt/sources.list.d/ubuntu-wine-ppa-saucy.list" ] ; then
		sudo add-apt-repository -y ppa:ubuntu-wine:ppa || errore "(21) configurazione PPA Wine"
	fi
}

aggiorna_installazione () {
	# creo link cache locale
	if [ -d "$CACHE/lubuntu_deb" ] ; then
		sudo ln -s -f $CACHE/lubuntu_deb/*deb /var/cache/apt/archives/ || errore "(31) creazione cache pacchetti"
	fi
	sudo apt-get update || errore "(24) update dell'installazoine"
	sudo apt-get dist-upgrade -y || errore "(25) dist-upgrade"
	# Todo: aggiungere copia in cache locale
}

installa_pacchetti_ufficiali () {
	for pacchetto in $(cat "$BASE/installa_$ubuntu_release.txt")
	do
		sudo apt-get install -y "$pacchetto" || errore "(2) durante l'installazione del pacchetto $pacchetto"
	done
}

installa_vox-launcher () {
	crea_area_di_lavoro "vox"
	deb="vox-launcher_0.1-1_all.deb"
	if [ ! -e "$CACHE/$deb" ] ; then
		wget -c https://vox-launcher.googlecode.com/files/vox-launcher_0.1-1_all.deb || errore "(5) durante lo scaricamento di Vox-Launcher"
	else
		ln -s "$CACHE/$deb" . || errore "(27) creazione link vox launcher"
	fi
	sudo gdebi --non-interactive $deb || errore "(6) nell'installazione di Vox Launcher"
	# python-xlib necessario per risolvere dipendenza, segnalare bug al manutentore
}

installa_spotlighter () {
	# è gia' presente nella distro. Lo lascio per support futuro.
	return
	crea_area_di_lavoro "spotlighter"
	deb="spotlighter.deb"
	[ "$(arch)" = 'x86_64' ] && src="http://ardesia.googlecode.com/files/spotlighter_0.3-1_amd64.deb" || src="http://ardesia.googlecode.com/files/spotlighter_0.3-1_i386.deb"
	wget -c "$src" -O "$deb" || errore "(7) nello scaricamento di spotlighter"
	sudo gdebi --non-interactive "$deb" || errore "(8) nell'installazione di spotlighter"
}

installa_opensankore () {
	crea_area_di_lavoro "opensankore"
	zip="opensankore.zip"
	[ "$(arch)" = 'x86_64' ] && src="Open-Sankore_Ubuntu_12.04_2.1.0_amd64.zip" || src="Open-Sankore_Ubuntu_12.04_2.1.0_i386.zip"
	if [ ! -e "$CACHE/$src" ] ; then
		wget -c "http://ftp.open-sankore.org/current/$src" -O "$zip" || errore "(9) nello scaricamento di opensankore"
	else
		ln -s "$CACHE/$src" "$zip"
	fi
	unzip -o "$zip" || errore "(10) nell'esplosione di OpenSankore"
	sudo gdebi --non-interactive Open-Sankore*.deb || errore "(11) nell'installazione di OpenSankore"
}

installa_whiteboard () {
	# tento l'installazione dal repo
	sudo apt-get install -y python-whiteboard && return || errore "(12) installazione Python-Whiteboard da Ubuntu"
	# se fallisco, faccio manualmente
	crea_area_di_lavoro "whiteboard"
	wget -c "https://dl.dropboxusercontent.com/u/1188340/python-whiteboard%20deb%20packages/python-whiteboard_1.0.5_all.deb" || errore "(13) nello scaricamento di Python Whiteboard"
	sudo gdebi --non-interactive python-whiteboard*
}

installa_iprase () {
	# controllo se l'installazione gia' esiste
	[ -d /opt/iprase ] && return
	# diversamente procedo
	crea_area_di_lavoro "iprase"
	if [ ! -e "$CACHE/iprase_2006.zip" ] ; then
		wget -c 'http://try.iprase.tn.it/prodotti/software_didattico/giochi/download/iprase_2006.zip' || errore "(14) nello scaricamento di IPRASE"
	else
		ln -s "$CACHE/iprase_2006.zip" iprase_2006.zip
	fi
	unzip -o iprase_2006.zip || errore "(15) nell'esplosione di IPRASE"
	mkdir -p ISO || errore "(16) creazione mountpoint"
	sudo mount -o loop,ro iprase_2006.iso ISO || errore "(17) mount dell'iso"
	sudo cp -a ISO/ /opt/iprase || errore "(18) durante copia file IPRASE"
	sudo umount ISO
}

installa_java () {
	# controllo cache
	if [ -d "$CACHE/oracle-jdk7-installer" ] ; then
		sudo mkdir -p /var/cache/oracle-jdk7-installer/ || errore "(26) crezione cache Java"
		sudo ln -s -f $CACHE/oracle-jdk7-installer/*tar.gz /var/cache/oracle-jdk7-installer/ || errore "(27) creazione link cache Java"
	fi
	sudo apt-get install -y oracle-java7-set-default || errore "(20) installazione JAVA"
}

installa_wine () {
	sudo apt-get install -y winetricks wine1.7 wine-mono4.5.0 || errore "(22) installazione di Wine"
}

installa_extras () {
	sudo apt-get install -y lubuntu-restricted-extras ubuntu-restricted-extras || errore "(23) installazione degli extras"
}

installa_chrome () {
	crea_area_di_lavoro "chrome"
	deb="chrome.deb"
	[ "$(arch)" = 'x86_64' ] && src="google-chrome-stable_current_amd64.deb" || src="google-chrome-stable_current_i386.deb"
	if [ ! -e "$CACHE/$src" ] ; then
		wget -c "https://dl.google.com/linux/direct/$src" -O "$deb" || errore "(28) nello scaricamento di Google Chrome"
	else
		ln -s "$CACHE/$src" "$deb"
	fi
	sudo gdebi --non-interactive "$deb" || errore "(29) nell'installazione di Google Chrome"
}

disinstalla_pacchetti_ufficiali () {
	for pacchetto in $(cat "$BASE/disinstalla_$ubuntu_release.txt")
	do
		sudo apt-get remove -y "$pacchetto" || errore "(30) durante l'installazione del pacchetto $pacchetto"
	done
}

controlla_distro
configura_repository_esterni
aggiorna_installazione
installa_pacchetti_ufficiali
installa_vox-launcher
installa_spotlighter
installa_opensankore
installa_whiteboard
installa_iprase
installa_java
installa_wine
installa_extras
installa_chrome
disinstalla_pacchetti_ufficiali
