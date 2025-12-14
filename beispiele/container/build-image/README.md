# Einfache Container Image Beispiel

## Container bauen

```bash
$ docker build -t my-first-image .
```

Baut auf Basis der Datei `Dockerfile` ein neues Container-Image und nennt es `my-container`

## Container ausführen

```bash
$ docker run --rm my-first-image
```

Startet einen Container auf Basis des Image `my-first-image`. Da kein Befehl angegeben wurde, wird der `CMD`-Befehl aus dem Image ausgeführt.

Entsprechend wird dann auf der Konsole einfach ausgegeben, was im Script `my_script.sh` steht.


Hinweis: `--rm` sorgt dafür, dass der Container nach dem Beenden auch gleich gelöscht wird. Ohne diese Angabe bleiben die Container auf dem System zurück, dass ist meistens nicht gewünscht. Diese "Leichen" können mit `docker ps -a` aufgelistet werden. Und dann mit `docker rm $ImageId/ContainerName` gelöscht werden.
