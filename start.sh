#!/bin/sh
if ! [ -f windows.ini ]; then
    ./sbin/apk update 
	./sbin/apk add curl
    ./sbin/apk add qemu qemu-img qemu-system-x86_64 qemu-ui-gtk 
    wget https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-amd64.tgz 
    tar xvzf ngrok-v3-stable-linux-amd64.tgz &> /dev/null 
    rm ngrok-v3-stable-linux-amd64.tgz 
	echo "windows.ini created"
	echo "os=win7">> windows.ini
	echo "ram=4G">> windows.ini
	echo "threads=1">> windows.ini
	echo "cores=2">> windows.ini
	echo "ngrok=">> windows.ini
	exit
    #echo "Ngrok Token" 
    #read -p "> " ngrok && echo "ngrok=$ngrok">> windows.ini
else
    while read -r var value; do
    FULL="$var=$value"
      export $var
    done < windows.ini
    ./ngrok config add-authtoken $ngrok
	if ! [ -f windows.img ]; then
		if [ "$os" = "win7" ]; then
        	echo "Windows 7 downloading..."
            wget -O windows.img https://bit.ly/akuhnetw7X64
        fi
    fi
    nohup ./ngrok tcp 3388 &>/dev/null &
    clear -x
    echo "----WIN7--------------------------------------------"
    echo "Подготовка..."
    echo "Это займёт некоторое время!"
    echo "---------------------------------------------------"
    sleep 4
    echo "----WIN7--------------------------------------------"
    echo "Виртуальная машина Windows 7 уже запускается!"
    echo "Откройте 'Пуск', введите в поиске 'Подключение к удалённому столу', позже введите этот IP:"
    curl --silent --show-error http://127.0.0.1:4040/api/tunnels | sed -nE 's/.*public_url":"tcp:..([^"]*).*/\1/p'
    echo "---------------------------------------------------"
    qemu-system-x86_64 -hda windows.img -m $ram -smp cores=$cores,threads=$threads -net user,hostfwd=tcp::3388-:3389 -net nic -object rng-random,id=rng0,filename=/dev/urandom -device virtio-rng-pci,rng=rng0 -vga vmware -nographic
fi