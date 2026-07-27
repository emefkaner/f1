# Feierabend-Liga — F1 25 Multiplayer

Private Auswertungsseite für unsere F1-25-Multiplayer-Rennen. Eine einzelne,
in sich geschlossene `index.html` ohne Build-Schritt.

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
