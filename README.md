# F1 26 MRL — Monday Racing League

Private Auswertungsseite für unsere F1-26-Multiplayer-Rennen. Eine einzelne,
in sich geschlossene `index.html` ohne Build-Schritt.

Gewertet wird das komplette Feld, Menschen und KI gemischt — eine echte
Meisterschaft über 22 Fahrer.

## Woher die Ergebnisse kommen

Nach dem Rennen im Spiel „Renndaten speichern" wählen. F1 schreibt dann eine
CSV nach `%USERPROFILE%\OneDrive\Dokumente\My Games\F1 25\session results\`,
benannt `session_results_TTMMJJJJ_HHMM.csv`. Darin stehen Klassifizierung,
Zeiten, beste Runden und die Vorfälle.

Zwei Dinge fehlen der CSV: die Strecke und die Rundenzahl. Die Strecke steht im
Nachbarordner `replays` im Dateinamen (gleicher Zeitstempel wie die CSV), die
Rundenzahl ist hier aus Gesamtzeit und schnellster Runde geschätzt.

Und: Das Spiel schreibt nur den eigenen Namen in die CSV — alle anderen
Mitfahrer heißen dort `Spieler:in`. Wer das war, muss von Hand zugeordnet
werden.

## Daten pflegen

Alles Inhaltliche steht ganz oben im ersten `<script>`-Block der `index.html`:

| Konstante | Bedeutung |
|---|---|
| `LEAGUE_NAME`, `SEASON` | Überschrift der Seite |
| `TOTAL_ROUNDS` | geplante Saisonlänge |
| `FASTEST_LAP_POINT` | `true` = +1 Punkt für die schnellste Runde (nur Top 10) |
| `DRIVERS` | `id`, `name`, `tag`, `team`, `color` |
| `RACES` | pro Rennen `round`, `gp`, `circuit`, `date`, `laps`, `fastestLap`, `results` |

`results` ist die Zielreihenfolge von P1 abwärts, jeweils `driver` + `gap`;
bei einem Ausfall `dnf: true`. Punkte, Siege, Podien und die Gesamtwertung
rechnet die Seite selbst aus, nach 25-18-15-12-10-8-6-4-2-1.

## Lokal ansehen

`index.html` einfach im Browser öffnen — kein Server nötig.

## Veröffentlichen

Die Seite läuft über GitHub Pages aus dem Repo-Root heraus. Nach dem Ändern
der Daten:

```bash
git add index.html && git commit -m "Rennergebnis ergänzen" && git push
```

Der neue Stand ist nach etwa einer Minute online.

---

Keine Verbindung zur Formula One Group, EA oder Codemasters. Enthält keine
offiziellen Logos oder Markenzeichen.
