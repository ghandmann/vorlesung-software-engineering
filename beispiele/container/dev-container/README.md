# Dev Container Example

Dieses Verzeichnis enthält ein Dev Container Setup für Visual Studio Code.

Die Relevanten Daten sind im Ordner `.devcontainer` und darin die Datei `devcontainer.json`.

Damit das klappt, muss die Extension "Dev Containers" (`ms-vscode-remote.remote-containers`) installiert sein. Wenn man damit diesen Ordern öffnet, fragt VS Code ob der aktuelle Ordner im Container neu geöffnet werden soll.

Danach wird eine Dev-Container Umgebung erzeugt auf Basis eines C# Images von der Microsoft Registry runterlädt.

Wenn alles abgeschlossen ist, kann VS Code normal verwendet werden. In der Konsole steht auch der `dotnet` Befehl zur Verfügung, obwohl dieser auf dem Host evtl. gar nicht installiert ist.

Alle Dateien liegen in Wirklichkeit auf dem Host-System, werden aber via `bind mount` in den Container gemounted und stehen so zur Verfügung.