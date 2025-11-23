---
marp: true
theme: vorlesung
backgroundImage: url('./images/background.svg')
footer: Vorlesung Software Engineering Wintersemester 25/26
paginate: true
---

<!-- _class: lead -->

# Domain Driven Design
## Software Engineering
## Sven Eppler

![width:1100px center](images/sodge-hochschule.png)

---

<!-- _class: chapter -->

# Domain Driven Design
## Fachlichkeit über Technik

---

# Domain Driven Design

![bg right:42%](./images/eric-evans-ddd-book.jpg)
- Idee die 2003 von Eric Evans 
- Bei DDD steht die Anwendungsdomäne und deren Fachlichkeit im Vordergrund
- Technische Details werden solange wie möglich ausgeblendet
- Der Kern der Anwendung wird ohne Abhängigkeiten an sog. Infrastruktur modeliert
- Software ist kein Selbstzweck!

---

# Fachlichtkeit über Technik

- Vergleich zum agilen Manifest
- Modellieren der Wirklichkeit der Software-Anwender
    - Dinge mit denen die Anweder hantieren sollten in der Software wieder gefunden werden.
- Die selbe Sache/der Selbe Begriff kann je nach Kontext unterschiedlich sein
    - Beispiel: Landkarte
        - Globus vs. Geographische Landkarte vs.  Politische Landkarte vs. Straßenatlas vs. Seekarten
- Identifizieren, herausarbeiten und verstehen dieser Fachlichkeit ist notwendig um für die Anwender "sinnvolle" Software zu schreiben

---

# DDD Elemente: Ubiquitos Language
- Eine "allgegenwärtige" Sprache finden
- Die meisten Fachdomänen besitzen bereits eine solche Sprache
    - Die Domänenexperten der jeweiligen Domäne verständigen sich so
- Mißverständnisse und falsche Annahme bei allen beteiligen finden und "beseitigen"
- Verwendung dieser Sprache an allen Stellen:
    - In der Kommunikation, in der Dokumentation, im Quellcode, in den Logfiles, etc.
- Verfassen eines gemeinsam gepflegtens "Glossars" welche Dinge genau was Bedeuten

---

# DDD Elemente: Bounded Context
- Ein in der Fachlichkeit existierende Abgrenzung
- Identifizieren von Grenzen von Modellen und auch z.B. von Begriffen
- Erlaubt die Verwendung der "gleichen Sache" in unterschiedlichen Kontexten
- Ein Bounded Context ist i.d.R. auch eine Konsistenzgrenze, innerhalb eines BC gelten transaktionelle Garantien
    - Typischerweise nicht umsetzbar über BC Grenzen
- Beispiel: Ein "Auftrag" im Kontext von "Einkauf", "Produktion" und "Marketing"

---

# DDD Elemente: Entitites

- Entities sind eindeutig identifizierbar (ID)
- Haben eine sog. Lebensdauer, d.H. sie werden zu bestimmten Zeitpunkten erzeugt (instantiiert) aber auch wieder zerstört/gelöscht
- Sind i.d.R. veränderlich (mutable)
    - Enthalten einen internen State
- Beispiel: Anstellungsverhältnis
    - Ist eindeutig identifizierbar, startet mit der Einstellungen, ändert sich z.B. durch Beförderung, endet mit Entlassung.

---

# DDD Elemente: Value Objects

- Sind nicht eindeutig identifizierbar (anonym)
- Werden häufig wiederverwendet
- Haben "Value Semantic", das bedeutet das der selbe Wert auch das selbe Objekt beschreibt
- Sind unendlich gültig
- Sind i.d.R. nicht veränderlich (immutable)
- Beispiel: Position im Unternehmen (Entwickler, CEO, Hausmeister, Lieferadresse)

---

# DDD Elemente: Domain Events

- Ereignisse die in der Fachdomäne vorkommen
- Zum Teil "natürlich" oder auch "synthetisch"
    - Auftreten eines Erdbebens für den Erdbebenmeßdienst
    - Befördern eines Mitarbeiters
- Domain Events erfassen die Änderungen in einer Domäne
- Werden in der Vergangenheitsform benannt
- Domain Events müssen idempotent sein (Tolerant ggü. der mehrfachen Anwendung des selben Events)

---

# DDD Elemente: Domain Events
- Idempotentes Event:
```json
{
    "eventType": "GeldÜberwiesen",
    "amount": 2000,
    "balanceBefore": 5000,
    "balanceAfter": 3000
}
```
- Nicht idempotentes Event:
```json
{
    "eventType": "GeldÜberwiesen",
    "amount": 2000,
}
```


---

# DDD Elemente: Aggregate

- Zentrales Objekt mit dem "gearbeitet" wird
- Kapselt Entities und Value Objects
- Nimmt über Methoden Kommandos entgegenen
- Stellt die eigene Konsistenz sicher (Invarianzen)
- Führt Kommandos nur aus, wenn sie im Aktuellen Zustand zulässig sind
- Emitiert Domain Event(s) als Reaktion auf ein Kommando
- Verarbeitet Domain Events um das Aggregate in den aktuellen Zustand zu bringen

---

# DDD Beispiel: Hotelbuchung

- Eventuous ist ein DDD Framework für C#
- Beispiel BookingAggregate:
    - [Booking.cs](https://github.com/Eventuous/eventuous/blob/dev/test/Eventuous.Sut.Domain/Booking.cs)

---

# DDD: Architektur

![center width:600px](./images/ddd-onionModel.png)

---

# DDD: Architektur

- Zwiebelschichten-Prinzip
    - Jedes Layer Abstrahiert einen anderen Bereich
    - Abhängigkeiten existieren nur von "außen" nach "innen"
- Im Zentrum steht das Domain-Model
- Vergleiche: Hexagonal Architecture

---

# DDD: Event Storming
- Es wird versucht zu ermitteln welche Ereignisse in der Fachdomäne vorkommen
- Wie diese Ereeignisse heißen
- Was passieren muss, dass diese Ereignisse ausgelöst werden
- Welche Daten diese Ereignisse transportieren
- Daraus ergeben sich die Domain Events die das Aggregate erzeugt
- Beispiel: Bewerber Eingestellt, Mitarbeiter Entlassen, Mitarbeiter befördert (Sprache! Kontext!)

---

# DDD: Domain Story Telling

- Durch Domain Story Telling soll herausgefunden werden:
    - Welche Bounded Contexts miteinander interagieren (kommunizieren)
    - Welche Informationen (Domain Events, Aggregates, Value Objects) sie austauschen
- Beispiel:
    - Kandidat bewirbt sich bei HumanResources
    - HumanResources bewertet Kandidat
    - HumanResources übergibt relevante Kandidaten an Fachabteilung
    - Fachabteilung wählt Kandidaten für Vorstellungsgespräch aus
    - HumanResources lädt _Kandidat_ und _Fachabteilung_ zum Vorstellungesgespräch ein

---

# Event Sourcing
- Kein eigenes DDD Konzept, aber bietet sich an
- Klassische Datenbanken speichern immer nur den ist-Zustand, nicht die Historie die dazu geführt hat
    - Vergleiche: User hat die eMail "epplers@hs-albsig.de"
    Frage: Welche eMail-Adresse hatte er früher?
- Bei EventSourcing wird nur die Kette der (Domain) Events gespeichert, daraus lässt sich der Zustand zu jedem beliebigen Zeitpunkt rekonstruieren

---

# Event Sourcing

- Aus den Events lassen sich zusätzliche Informationen ableiten:
    - Gibt es User, die öfter als 5 mal ihren Wohnort geändert haben?
    - Welche Bestellungen wurden innerhalb von 10 Minuten storniert?
    - Bei welchen Songs macht der User die Lautstärke höher?
- Der Speicherort für diese Events wir EventStore genannt
- Aus Performance-Gründen werden i.d.R. ReadModels voraus berechnet
    - Beispiel: UserProfile, WatchHistory, WhatToWatchNext
    - Wo Licht ist, ist auch Schatten: Stale ReadModels
---

# Command Query Responsibility Segregation (CQRS)

- Im wesentlichen die Unterscheiden zwischen schreibendem und lesendem Zugriff
- Kommandos ändern den Zustand
    - Schlechter Skalierbar da Seiteneffektbehaftet -> evtl. synchronisation notwendig
- Queries geben nur eine sicht auf den Zustand (View) zurück
    - Gute Skalierbar da Seiteneffektfrei
- Passt daher sehr gut zu DDD und EventSourcing
    - Commands werden an das Aggregate übergeben
    - Queries werden aus den ReadModels bedient

