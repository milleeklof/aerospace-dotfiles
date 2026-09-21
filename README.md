# AeroSpace + Karabiner på macOS

Min fönsterhantering: [AeroSpace](https://github.com/nikitabobko/AeroSpace) (i3-liknande tiling) och [Karabiner-Elements](https://karabiner-elements.pqrs.org/) för en hyper-tangent.

## Filosofi

1. **En app per workspace, med mnemoniska bokstäver.** Workspace-bytet är en deterministisk appväxlare: hyper + `O` går alltid till Obsidian, oavsett vad som är öppet. Inget `cmd-tab` och ingen gissning.
2. **Workspace 1 är hemmet för Ghostty och Claude, med vardagssaker flytande ovanpå.** Ghostty (vänster 2/3) och Claude (höger 1/3) ligger tilade. Meddelanden, Anteckningar, Foton, Finder, FaceTime och fönster från min kod (Python, OpenGL) hamnar där som *flytande* fönster ovanpå, så de beter sig som om AeroSpace inte fanns.
3. **Workspace 2–4 är för tillfälliga fönster i helskärm.** Sådant jag inte använder ofta, utan bara just nu.
4. **Workspace 5 är för presets.** När jag vill arbeta på ett visst sätt kör jag färdiga layouter som *lånar* fönster från bokstavsworkspacesen och skickar tillbaka dem när jag är klar.
5. **Hyper-tangenten** gör att inga genvägar krockar med macOS, appar eller tecken som `@`, `|`, `[` och `{` på svenskt tangentbord.

## Workflow

Grundregeln är att **allt jag använder ofta har en egen workspace där det alltid ligger öppet**. Jag kommer åt det på ett ögonblick, och i regel ligger varje app ensam i helskärm. På det viset används AeroSpace mest som en snabb appväxlare, inte som ett tiling-verktyg.

- **Bokstavsworkspaces (A, B, C, D, M, N, O, S, V):** en app var, alltid öppen, alltid ensam. Hyper + bokstav tar mig dit, och hyper + `tab` hoppar mellan de två senaste.
- **Workspace 1, vardagsytan:** Ghostty (vänster 2/3) och Claude (höger 1/3), tilade. Ovanpå ligger flytande fönster för det jag har uppe lite här och där, som Meddelanden, Anteckningar, Foton, Finder, FaceTime samt fönster från kod (Python, OpenGL). De flytande fönstren beter sig som utan AeroSpace.
- **Workspace 2–4, tillfälligt:** fönster i helskärm som jag inte använder ofta utan bara behöver just nu.
- **Workspace 5, presets:** vissa stunder vill jag arbeta på ett visst sätt, till exempel Vivaldi, Obsidian och Claude bredvid varandra. Då kör jag ett preset (hyper + `p`, sedan `1`, `2` eller `3`). Apparna lånas till workspace 5 och tilas. Hyper + `p`, sedan `r` skickar hem dem igen till sina egna workspaces och tar mig till workspace 1.

## Hyper-tangent

Höger option är remappad i Karabiner till `ctrl+opt+cmd` (regeln ligger i `karabiner/right-option-hyper.json` och klistras in via *Add your own rule*). AeroSpace ser bara kombinationen, så alla bindningar i `aerospace.toml` börjar med `ctrl-alt-cmd-`.

- Caps Lock är Control (macOS-inställning) och rörs inte. Det behövs för tmux-prefixet och alla `ctrl`-genvägar.
- Vänster option är fri för å, ä, ö, `@`, `|` med mera.
- Skulle det kännas fel går det att byta `right_option` i regeln mot `fn` eller `right_command`. AeroSpace-configen påverkas inte.

## Tangenter

Med hyper = höger option:

| Vad | Tangent |
|---|---|
| Byt workspace | hyper + `<bokstav/siffra>` |
| Flytta fönster till workspace | hyper + shift + `<bokstav/siffra>` |
| Föregående workspace | hyper + `tab` |
| Fokus | hyper + `h/j/k/l` |
| Flytta fönster | hyper + shift + `h/j/k/l` |
| Ändra storlek | hyper + `-` / `=` |
| Layout tiles / accordion | hyper + `/` / `,` |
| Presetläge | hyper + `p`, sedan `1`, `2`, `3` eller `r` |
| Service mode | hyper + shift + `;` |

Service mode: `f` växlar flytande/tiling, `r` återställer layouten (`flatten-workspace-tree`), `esc` laddar om configen, `backspace` stänger alla andra fönster.

## Workspaces

| Workspace | Innehåll |
|---|---|
| 1 | Ghostty (vänster 2/3) och Claude (höger 1/3), tilade, med flytande vardagsfönster ovanpå: Meddelanden, Anteckningar, Foton, Finder, FaceTime, Python-/OpenGL-fönster, allt utan egen regel |
| 2–4 | Tillfälliga fönster i helskärm |
| 5 | Presets |
| A | Anki |
| B | Brave |
| F | Firefox |
| C | Kalender |
| D | Discord (startas vid behov) |
| M | Mail |
| N | Notion |
| O | Obsidian |
| S | Sioyek |
| V | Vivaldi |

## Presets

Skriptet `aerospace/layout.sh` flyttar appar till workspace 5, tilar dem och balanserar kolumnerna. Startar appen om den inte är öppen.

| Preset | Vänster | Mitten | Höger |
|---|---|---|---|
| `work1` | Vivaldi | Ghostty | Claude |
| `work2` | Vivaldi | Obsidian | Claude |
| `work3` | Obsidian | Sioyek | Claude |

`restore` (hyper + `p`, sedan `r`) skickar varje app hem till sin workspace enligt `home_ws` i skriptet, sätter Ghostty till 2/3 och Claude till 1/3 på workspace 1, gör övriga fönster på 1 flytande och landar på workspace 1. Varje preset börjar med `restore`, så man kan hoppa direkt mellan dem.

`layout.sh home1` gör bara den delen: hämtar Ghostty och Claude till workspace 1, tilar dem, balanserar och gör Ghostty 2/3 och Claude 1/3 (skärmbredden läses ut med `osascript` och Ghostty får `resize width +W/6`). Det rör inga andra fönster och byter inte workspace.

## Flytande fönster

`layout floating` tar ett fönster ur tiling-trädet. AeroSpace slutar styra dess storlek och position, så det går att dra och skala fritt. Fönstret ligger kvar på sin workspace. Läget sitter på fönstret, inte på workspacen. Växla manuellt med service mode + `f`, eller `aerospace layout floating tiling`.

## Regler att komma ihåg

- **`[[on-window-detected]]` körs bara när ett fönster skapas.** Redan öppna fönster flyttas inte av en ny regel. Kör `layout.sh restore` eller stäng och öppna appen igen.
- **Första matchande regel vinner.** Specifika appregler ska stå före fångstregeln.
- **Fångstregeln står sist** och skickar allt utan egen regel flytande till workspace 1. I `config-version = 2` måste den ha ett `if`, därför `if.app-name-regex-substring = '.'`.
- **Nya appar:** lägg till en regel i `aerospace.toml` *och* en rad i `home_ws` i `layout.sh`. Bundle-id hittar man med:

  ```bash
  aerospace list-windows --monitor all --format '%{window-id}|%{app-bundle-id}|%{app-name}|%{workspace}'
  ```

## Kända krångel

- **Ghostty och flikar.** Varje Ghostty-flik ser AeroSpace som ett eget fönster, och de slåss om samma ram när de tilas. Ghostty är tilat på workspace 1 och i presets, så flikbuggen gäller där. Använd splits (`cmd-d`, `cmd-shift-d`) eller tmux i stället för flikar, och ha ett enda Ghostty-fönster (skriptet och `home1` tar bara det första fönstret).
- **`--all` kan inte kombineras med filterflaggor** i `aerospace list-windows`. Använd `--monitor all`.
- **Sioyek och andra appar utan fönster** kan starta utan att skapa ett fönster, och hoppas då över av presets.
- Ändras bara `layout.sh` behövs ingen omladdning. Ändras `aerospace.toml` laddas den om automatiskt (`auto-reload-config = true`).

## Installation

```bash
brew install --cask nikitabobko/tap/aerospace
brew install --cask karabiner-elements
```

1. Länka configen:

   ```bash
   mkdir -p ~/.config/aerospace
   ln -s ~/dotfiles/aerospace/aerospace.toml ~/.config/aerospace/aerospace.toml
   ln -s ~/dotfiles/aerospace/layout.sh ~/.config/aerospace/layout.sh
   chmod +x ~/dotfiles/aerospace/layout.sh
   ```

2. I Karabiner-Elements: *Complex Modifications → Add your own rule* och klistra in **innehållet** i `karabiner/right-option-hyper.json`. Filen är själva regeln och är inte en importfil, så den ska inte läggas i `~/.config/karabiner/assets/complex_modifications/`.
3. Ge Karabiner behörigheterna den ber om (Input Monitoring och drivrutinen under Systeminställningar).
4. `layout.sh` utgår från `/opt/homebrew/bin/aerospace`. På en Intel-Mac är sökvägen `/usr/local/bin/aerospace`.
5. Stäng av *Displays have separate Spaces* om du använder flera skärmar, och använd inte Mission Controls Spaces samtidigt.

## Filer

```
dotfiles/
├── README.md
├── aerospace/
│   ├── aerospace.toml
│   └── layout.sh
└── karabiner/
    └── right-option-hyper.json
```
