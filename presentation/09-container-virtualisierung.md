---
marp: true
theme: vorlesung
backgroundImage: url('./images/background.svg')
footer: Vorlesung Software Engineering Wintersemester 25/26
paginate: true
---

<!-- _class: lead -->

# Container Virtualisierung
## Software Engineering
## Sven Eppler

![width:1100px center](images/sodge-hochschule.png)

---

<!-- _class: chapter -->

# Von BareMetal zu Containern
## Wie sind wir hier her gekommen?

---

# Am Anfang stand da ein Server

- Bis 2005 war es normal, dass ein Server eine "echte Kiste aus Metall" war
- Meist wurden für verschiedene Dienst (NFS, FTP, Mail, HTTP) mehrere Server betrieben
    - Wichtig für die Ausfallsicherheit
    - Kostenintensiv (Anschaffung & Betriebskosten)
    - Schlechte Resourcenausnutzung

---

# Hardware Virtualisieurng

- Konzept bereits in den 1960/1970er Jahren bei IBM Mainframes im Einsatz
- In den 90er reine Nischenlösung
- 2005 bringen Intel (VT-x) und AMD (AMD-V) Hardware-Unterstützung für x86 Virtualisieurng
    - Dadurch entwickelt sich Hardware Virtualisierung zu einer Mainstream-Lösung

---

# Hardware Virtualisierung

- Auf dem "Host" läuft ein sog. Hypervisor der die physikalischen Resources verwaltet
- Der Hypervisor kann viele VirtualleMachines erzeugen, verwalten und ausführen
- Die "Guests" bekommen in diesem Szenario gar nicht mit, dass sie in einer virtualisierten Umgebung laufen
    - Dennoch ist es häufig nötig "guest extensions" zu installieren, für vollen support

---

# Hardware Virtualisierung Vorteile

- **Ressourceneffizienz**: Mehrere VMs teilen sich die Hardware eines Hosts (Konsolidierung)
- **Isolation**: Fehler in einer VM beeinflussen andere VMs oder den Host nicht
- **Flexibilität**: Alte Betriebssysteme oder inkompatible Software können parallel betrieben werden
- **Verwaltung**: Snapshots, einfache Migrationen (vMotion) und Backups
- **Provisionierung**: Neue Server in Minuten statt Wochen

---

# Hardware Virtualisierung Nachteile

- **Overhead**: Jede VM benötigt ein vollständiges Betriebssystem (Kernel, Binaries, Libraries)
- **Performance**: Virtualisierungsschicht kostet Leistung (CPU, I/O)
- **Speicherplatz**: Redundante Datenhaltung durch viele (fast) gleiche OS-Installationen
- **Startzeit**: Booten einer VM dauert so lange wie ein physischer Server
- **Licensing**: Kosten für OS-Lizenzen können steigen
- **Overprovisioning**: Kann zu Leistungsengpässen führen, wenn Ressourcen überbucht sind ("Noisy Neighbor")
---

# Containervirtualisierung

- Kernidee: Isolation einzelner Prozesse, statt ganzer Betriebssysteme/Serverhardware
- Basiert technologisch auf Features aus dem Linux Kernel:
    - Cgroups
    - Namespaces
- Beides Konzepte die schon lange im Kernel existieren (cgroups seit 2007, Namespaces 2002-2013)
- Ab 2013 dann "Containerisierung" wie wir sie heute kennen mit Linux Containers (LXC)

---

# Namespaces

- Namespaces im Linux-Kernel sind vergleichbar mit Gruppen
    - Jede Gruppe hat nur Sichtbarkeit auf die anderen Gruppenteilnehmer, aber nicht über Gruppengrenzen hinaus
- Es gibt verschiedene Arten von Namespaces:
    - User-Namespace (UserId und Berechtigungen)
    - Network-Namespace (Netzwerk Zugriff)
    - Process-Namespace (Prozessliste)
    - Mount-Namespaces (Dateisystem Zugriff)
- Mithilfe von Namespaces ist es möglich, einen Prozess so zu starten, dass dieser sich für den einzigen Prozess auf dem System hält

---

# Cgroups

- Cgroups ist ein Konzept um für einen einzelnen Prozess Resourcenlimits zu definieren
- Mögliche Resourcen:
    - CPU
    - Arbeitsspeicher
    - I/O Limits
    - Deviceaccess (`/dev/`)
    - Processlimits
- Dadurch wird es möglich, einzelne Prozesse so zu limitieren, wie man das zuvor nur von Hardware Vritualisierung kannte

---

# Sidenote: Warum ich vermeide Docker zu sagen

- Docker und "Docker Container" beschreibt im wesentlichen was wir heute unter Containerisierung verstehen
- Docker selbst ist eine Firma, die Containerisierung in den Massenmarkt gebracht hat
- Technisch ist Docker aber eher eine leere Hülle
    - Sämtliche relevanten Technologien für Containerisierung sind OpenSource
        - Cloudnative Foundation (CNCF)
        - Open Container Initiative (OCI)
- D.H. obwohl Docker zu Synonym für Container wurde, ist es für Container kaum noch relevant

---

# Sidenote: Warum ich vermeide Docker zu sagen

- Hauptprodukt: Docker Desktop für Windows
- Betreiben der populärsten Image-Registry Docker-Hub
    - Seit April 2025 Einschränkung der Zugriffe/Stunde
- Konzept des Docker-Daemon als Root-Prozess ist ein Auslaufmodell
    - Rootless-Container Engines wie z.B. `podman` die Zukunft
- Panik: [Kubernetes 1.24 entfernt Docker-Unterstützung (2022)](https://www.heise.de/news/Container-Kubernetes-1-24-entfernt-Docker-Unterstuetzung-6950512.html)
    - Meint: Kubernetes bringt seine eigene Container-Runtime mit und jedes bestehende Docker-Container-Image ist einfach kompatibel

---

<!-- _class: chapter -->

# Containerisierungs Basics
## Die wichtigen building blocks

---

# Container Images

- Das _Image_ ist die Vorlage für einen _Container_
- Images sind komplett Read-Only (aka Immutable)
    - Dadurch können verschiedene Container auf dem selben Image basieren
    - Änderungen im Container haben keinen Effekt auf das Image!
- Images werden in sog. Layern aufgebaut
    - vgl. Ein Stapel von Klarsichtfolien
    - Die Layer sind über eine kryptografisch verkettete Liste verknüpft
    - Daten die in einem Layer vorhanden waren, bleiben es für immer!
    - Layer werden mittels SHA256 identifiziert
    - Selber Hash bedeutet identisches Layer

---

# Container Images

- Können fertig aus einer Image-Registry bezogen werden
    - z.B. [Docker-Hub](https://hub.docker.com/), [Quay.io](https://quay.io)
- Oder werden selber gebaut mittels `Dockerfile`/`Containerfile`

---

# Container

- Container sind auf Basis eines Image erzeugte "Laufzeitumgebungen" die gestartet und gestoppt werden können
- Container gelten grundsätzlich als vergänglich (_ephemeral_)
    - "Aus dem Staub, in den Staub"
    - Sämtliche Änderungen im laufenden Container gehen verloren, wenn er gelöscht wird
    - Ideal für "statless" Anwendungen
- Problem: Was aber, wenn Daten persistiert werden müssen (z.B. Datenbank)
    - Auslagern der Daten in sog. "Volumes"
        - Data-Only-Container
        - Host-Bind-Mounts

---

<!-- _class: chapter -->

# Wir bauen uns einen Container
## Wie geht das?

---

# Erzeugen von Images

- Container werden mithilfe eines "Kochrezeptes" erstellt
    - aka Deklarativ
- Dazu wird ein `Dockerfile`/`Containerfile` genuzt 
    - [Dockerfile Reference](https://docs.docker.com/reference/dockerfile/)
- Jedes "schreibende" Statement erzeugt ein neues Layer
    - `RUN ...`
    - `COPY ...`
- Das letzte Layer eines Images wird dann mittels Name und Tag markiert
    - Grundsätzlich geht es technisch immer nur um SHA256 Hashes!

---

# Erzeugen von Images

```Dockerfile
# Base Image
FROM ubuntu:24.04 

# Daten vom Host ins Image-Layer kopieren
COPY my_script.sh /home/root/ 

# Commando im Layer ausführen
RUN date +'%F %T' > /home/root/image_created

# Startkommando definieren
CMD ["/bin/bash", "/home/root/my_script.sh"]
```

Siehe `$repo/beispiele/container/build-image/`.

---

# Image benennen

- Images bekommen einen Namen
- Auf Docker-Hub hat sich ein Schema etabliert:
    - `docker.io/$Username/$ImageName`
- Tags werden genutzt um Images zu Versionieren und alternative "flavors" anzubieten
    - Z.B. Welches Base-Image wird genutzt
    - Beispiel: [Nginx](https://hub.docker.com/_/nginx)
- Docker-Hub spezifisch: Offizielle vs. User-Images
    - Wichtig: Docker Inc. hostet nur, erzeugt selber keine Images!!!
    - Due diligence liegt bei den Nutzern!
---

# Image benennen

- Achtung: `latest`-Tag!
    - Wird kein Tag angegeben, wird `latest` als default genutzt
    - `latest` bezeichnet daher immer nur das zuletzt gebaute, nicht automatisch das neuste Image!
    - Außerdem: Wenn ich schon ein `latest`-Image auf dem System habe, wird gar kein "neueres" geholt
      Solange mal wieder mit `docker pull` ein neues gefunden wird

---

# Caching von Layern

- Um das erzeugen von Images zu beschleunigen wird ein Layer-Cache genutzt
- Jedes Layer wird ja anhand seines SHA256 Hash identifiziert
- Zusätzlich wird gespeichert, welche Anweisung im `Dockerfile` welches Zwischenlayer erzeugt
- Dadurch können teile eines `Dockerfiles` komplett aus dem Cache genutze werden
- Erst wenn eine Veränderung am `Dockerfile` auch zu einem neuen Hash des Layers führt, werden auch alle nachfolgenden Layer neu gebaut
    - Erinnerung: cryptografisch verkettete Liste!

---

<!-- _class: image-only -->

# Caching von Layern - Cache Invalidation

Version 1
```Dockerfile
FROM node:lts
COPY package.json /app/
WORKDIR /app/
RUN npm install
COPY * /app/
```
Version 2
```Dockerfile
FROM node:lts
COPY package.json /app/
WORKDIR /app/
# Cache invalidation ab hier
RUN echo "blubb" > /blubb.txt
RUN npm install
COPY * /app/
```
---

# Der Buildcontext

- Beim erzeugen eines Container-Images gibt es einen sog. Builcontext
    - Dieser beschreibt, welche Dateien für das erzeugen des Images relevant sind
    - Sonderfall Docker: Da bei Docker der Daemon als Systemservice läuft, muss der Buildcontext via Netzwerk an den Daemon übergeben werden
    - Grundsätzlich sollte der Buildcontext klein gehalten werden und nur relevante Dateien umfassen
        - Dockerfile
        - Alle Dateien die im Image enthalten sein sollen

---

# Der Buildcontext

- Um Dateien/Ordner vom Buildcontext auszuschließen gibt es die Datei `.dockerignore`
- Ähnliche wie die Datei `.gitignore` können damit Dateien/Ordner angegeben werden, die nicht zum Docker-Daemon geschickt werden sollen
- Pro Zeile wird einfach ein Ignore-Pattern angegeben
- Typische Angaben:
    - node_modules Ordner
    - Logfiles
    - Build-Artefakte (lib und obj files, etc.)
    - Dokumentationsdateien
---

# Der Buildcontext

Beispiel `.dockerignore`
```txt
node_modules/
build/
*.swp
```
---

<!-- _class: chapter -->

# Vom Image zum Container
## Wie man Container startet

---

# Starten von Containern

- Mittels `docker run` können Container gestartet werden
    - `run` ist dabei eine Kombination aus `docker create` und `docker start`
- Beim Starten kann mit `--name` ein Name angegeben werden, ansonsten wird einer Autogeneriert
    - Jeder Container hat aber auch eine SHA256 Hash als Identifikation
- Mit `docker ps` können alle laufenden Container aufgelistet werden
- Die meisten Container starten ihre Anwendung im Fordergrund und laufen, bis sie mit STRG+C beendet werden
    - Beispiel: `docker run nginx:alpine`

---

# Starten von Containern

- Häufig will man Container aber eher wie Serverprozesse im Hintergrund ausführen
    - Dazu gibt es die Option `-d` / `--detach`
    - Dann läuft der Container im Hintegrund und muss mittels `docker stop` gestopt werden
- Container die gestoppt sind, sind noch nicht gelöscht
    - Diese müssen entweder mit `docker rm $name/$hash` gelöscht werden
    - Oder mit `--rm` gestartet werden, dann werden sie nach dem Beenden gelöscht

---

# Starten von Containern

- Sofern die Anwendung im Container es unterstützt, kann auch eine interaktive Session im Container gestartet werden
    - `-i` für Interactive
    - `-t` für tty Allokation
    - Beispiel: `docker run -it --rm ubuntu:24.04 /bin/bash`
    - Sehr praktisch um schnell eine Experimentierumgebung zu erzeugen

---

# Starten von Container

- Live Beispiel: Container sind nur Prozesse auf dem System!

---

# Docker Netzwerk

- Mittels Networking-Namespaces kann jeder Container auch ein eigenes Netzwerk bekommen
- Bei Docker sind alle Container per Default im Docker-Netzwerk
    - Jeder Container bekommt eine eigene IP aus dem Bereich 172.17.x.y
    - Über diese IP sind die Container untereinander verbunden
- Startet im Container eine Netzwerkanbindung, verwendet sie auch diese "Docker lokale" IP um den Dienst anzubieten
    - D.H. vom Host aus ist der Dienst **NICHT** via 127.0.0.1 erreichbar!
    - Aber via 172.17.x.y

---

# Docker Netzwerk

- Das nutzen dieser Docker-Interne-IP von Außerhalb ist aber bad practice
- Die IP kann sich potentiell ändern
- Daher verwendet man Portforwarding auf den Host für konsistente Verbindungen
    - `-p [[BindIp]:HostPort]:[ContainerPort]`
        - `docker run --rm -p 1234:80 nginx:alpine`
    - `-P` Wählt freie "Client Ports" für alle "EXPOSED" Ports aus dem Dockerfile automatisch
        - `docker run -P nginx:alpine`
- ACHTUNG: Beide Optionen binden per default auf ANY_IP (0.0.0.0)
    - `docker run --rm -p 127.0.0.1:1234:80 nginx:alpine`

---

# Docker Netzwerk

- Mit `--network` kann auch gewählt werden, welche Netzwerk genutzt werden soll bei `docker run`
- Mit `docker networks` kann man Netzwerke erzeugen/löschen
- In seltenen Spezialfällen ist es notwendig, einen Container nicht in einen Networking-Namespace zu stecken, sondern auf dem `Host`-Netzwerk laufen zu lassen
    - `docker run --network=host`
    - Das ist z.B. notwendig bei Anwendungen die mittels Network-Broadcasts andere Geräte discovern wollen (z.B. Home-Assistant)
    (Ein Network-Broadcast innerhalb von 172.17.x.y wandert eben nicht in ihre heimisches 192.168.x.y Netz)

---

# Container Registries

- Eine "Container Registry" ist ein Dienst bei dem Container-Images gehostet werden
- Daduch können Images mit anderen benutzen geteilt werden ohne das diese das Image selbst erneut bauen müssten
    - Grundsätzlich würde ja das Teilen des `Dockerfile` ausreichen
- Registries gibt es viele:
    - Docker-Hub
    - Quay.io
    - Artifactory
    - GitLab Projektinterne Registry
    - [Run your own Registry](https://hub.docker.com/_/registry)

---

# Container Registries

- Images sollten vor der Verwendung "geprüft" werden
    - Vergleiche npmjs.com!
- Jeder kann Images mit (fast) beliebigen Namen hochladen
- Offizielle Images sind lediglich von autorisierten Accounts
- Identisches Supply-Chain-Dilemma wie bei Package-Repositories

---

# Container Registries

- Holen eines Images von einer Registry:
    - `docker pull ubuntu:24.04`
    - Zieht implizit das Image von Docker-Hub
- Besser: Fully-Qualified-Image-Name
    - Bestehen aus einem Host-Part und Image-Part
    - `docker.io/ubuntu:24.04` Image von Docker-Hub
    - `mcr.microsoft.com/vscode/devcontainers/javascript-node:0-16-bullseye`, mcr: Microsoft Container Registry
    - `quay.io/keycloak/keycloak`, quai.io: Red Hat Container Registry
- Der Befehl `docker images` zeigt alle lokalen Images an

---

<!-- _class: chapter -->

# Container Virtualisierung
## Isolation die schlecht isoliert

---

# Container sind kein Security-Konzept!

- Container teilen sich den Host-Kernel
    - Innerhalb eines Containers kann also auch auch der Host-Kernel angegriffen werden!
- Jeder user der via Docker einen Container starten darf, wird effekt root auf dem System
    - `docker run -it --rm ubuntu:24.04 id`
    - Der Prozess läuft dann als der root-User des Systems!
    - Mittels Bind-Mount kann so auf das **GESAMTE** Dateisystem zugegriffen werden
    - `docker run -it --rm -v /:/host/ ubuntu:24.04 /bin/bash`

---

# Container sind kein Security-Konzept!

- Generell gilt: Container-Virtualisierung ist ein sinnvolles System für Prozesse die "kooperieren wollen"
- Wer echte Isolation braucht, bzw. eher "aus Security Gründen isoliert" sollte weiterhin Hardware Virtualisierung einsetzen!
- Wichtig: Keine sensiblen Daten in Container-Images anlegen, diese können immer ausgelesen werden!
    - Beispiel: [dive - A tool for exploring each layer in a docker image](https://github.com/wagoodman/dive)

---

# Ausblick - Warum das ganze?

- Lokale Entwicklung
    - Mittels Container können für verschiedene Projekte verschiedene Runtimes/Compiler/Bibliotheken bereitgestellt werden
- Dev Container
    - Konzept von Microsoft das die gesamte Entwicklungsumgebung in einen Container verlagert
    - Alle Prozesse laufen im Container, auf dem Host läuft nur noch das grafische Frontend
    - Siehe `$repo/beispiele/container/dev-container/`

---

# Ausblick - Warum das ganze?

- Continious Integration / Continious Deployment
   - Alle gängigen CI/CD System nutzen mittlerweile Container zur Ausführung von Jobs
   - Häufig werden auch Container-Images durch CI/CD Pipelines erzeugt und Deployed
- Ausliefern von Software
    - Mittels Container-Images kann eine Anwendungen samt Dependencies ausgeliefert werden 
    - Bekannte Beispiele: snap und flatpak sind Systeme die Software "containerisiert" verteilen
    - Steam auf Linux läuft ebenfalls in einem Container
---

# Weiterführende Themen:

- Multistage Builds
- Container Orchestrierung
    - Docker Compose
    - Kubernetes
- Persistenz via Bind-Mounts

