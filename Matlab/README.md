# Projet EN31 
## Projet de transmission vidéo utilisant des radios-logicielles.

Le fichier ````tx_stream.ts````, a été créé en utilisant FFMPEG :
````
ffmpeg -loop 1 -framerate 1/2 -i lion.jpg -c:v mpeg2video -t 6 tx_stream_.ts
````

Vous pouvez aussi utiliser VLC.
Sous Linux :
````
cvlc -vvv votre_video.avi --sout="#transcode{vcodec=h264,vb=100}:standard{access=file,mux=ts,dst=votre_fichier_ts.ts}"
````

Sous mac-OSX :
````
./Applications/VLC.app/Contents/MacOS/VLC -I dummy -vvv your_video.avi --sout="#transcode{vcodec=h264,vb=100}:standard{access=file,mux=ts,dst=votre_fichier_ts.ts}"
````
Dans ces lignes, le parametre vb (video bitrate en kbits/s) peut vous servir à régler la qualité de l'image après encodage. Il existe aussi un parametre ab (audio bit rate). Vous trouverez plus d'information à l'adresse https://wiki.videolan.org/Transcode/.
