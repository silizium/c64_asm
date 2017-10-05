Anleitung für den SVS-Mon für den C64

Speichermonitor mit freier Speicherkonfiguration,
Diskettenmonitor, Sprite und Zeichensatzeditor.
Länge: 4097 Bytes

Copyright SVS-Mon by Sven Volker Spreier
Anleitung von Hanno Behrens

Befehle:
X - Exit

M - Monitor
    M aaaa [eeee]          - Anzeigen von...[bis] in Hexadezimalzahlen.
                             Die Textdarstellung hängt von A (Voreinstellung
                             ASCII) oder P (Bildschirmcode) ab.
                             ASCII wird revers, Bildschirmcode normal
                             ausgegeben.
    M                      - Anzeigen des Voreingestellten Diskbuffers



R - Register/Read
    R                      - Registeranzeige
    R tr sc                - Lesen von Track/Sector
    R *                    - Lesen des verketteten Track/Sectors.

: - Memory-Zeile ändern
    :aaaa bb [bb...]       - bis zu 8 Bytes eingeben

F - Fill
    F aaaa eeee vv

C - Compare
    C aaaa eeee vvvv       - Vergleiche Speicherbereiche von aaaa bis
                             eeee mit vvvv

K - Konfiguration
    K x                    - 1-7 Speicherkonfiguration (lobyte von 1)
                             Voreinstellung 1 entspricht $37

H - Hunt
    H aaaa eeee {vv...   |"string"} - Sucht nach Hex oder ASCII
    H*aaaa eeee {vv vv...|"string"} - Bei mindestens 2 Zeichen
                             erweiterte suche nach Differenzen,
                             findet auch Bildschirmcodes

@ - Diskettenstatus
    @                      - Diskettenstatus
    @ "Diskettenkommando"  - z.B. "N:Name,ID" für formatieren

L - Load
    L "Name" dd [aaaa]     - Laden des Files von Drive dd nach
                             Adresse aaaa
                             Gibt an von-bis geladen wurde.

V - Verify
    V "Name" dd aaaa       - Vergleichen des Files von Drive dd mit
                             Adresse aaaa

S - Save/Sprite
    S "Name" dd aaaa eeee  - Speichern auf Drive dd von aaaa
                             bis eeee
    S aaaa [eeee]          - Sprite von aaaa bis eeee anzeigen

O - Old
    O                      - Die BASIC New-Funktion rückgängig
                             machen

T - Transfer
    T aaaa eeee zzzz [[+|-]vv] - Speicherbereich von aaaa bis eeee
                             nach zzzz kopieren, wobei vv zum
                             Wert der Übertragenen Bytes exklusiv
                             ODER verknüpft, addiert
                             oder subtrahiert werden kann.
                             Voreinstellung ist exklusiv ODER.
                             Die Speicherbereiche dürfen
                             sich natürlich überlappen.

U - Umrechnen
    U !ddddd               - von einer Dezimalzahl,
    U $xxxx                - einer Hexadezimalzahl
    U %bbbbbbbb [bbbbbbbb] - oder einer Binärzahl
                             in die jeweils anderen.

A - ASCII anzeigen
    A aaaa [eeee]          - Zeigt von aaaa bis eeee die Speicher-
                             inhalte als ASCII-Dump an
    A                      - schaltet Memorydump-Text auf ASCII
                             (Voreinstellung)

. - Zeile ASCII ändern
    .aaaa Text             - eingeben von Text in CBM-Ascii bis
                             zu 32 Zeichen

; - Register ändern
    ; pppp iiii sp ac xr yr sr  nv-bdizc
                           - Alle Werte werden erst bei
                             Verlassen des Monitors gesetzt.
                             Mit G kann man den Prozessorcounter
                             anspringen, das Statusregister kann
                             sowohl als Byte, wie auch als
                             Bitmuster geändert werden.

G - Goto
    G [aaaa]               - Ausführen des Programmes an der
                             Adresse aaaa, wenn diese angegeben wurde
                             oder benutzen des Wertes im PC-Register.

P - Bildschirmcodes anzeigen
    P aaaa [eeee]          - Zeigt von aaaa bis eeee die Speicher-
                             inhalte als Bildschirmcode-Dump an
    P                      - Schaltet Memorydump-Text auf Bild-
                             schirmcode.


/ - Bildschirmcodes einlesen
    /aaaa Text             - Eingeben von Text im Bildschirm-
                             code bis zu 32 Zeichen.

D - Disassemble
    D aaaa [eeee]          - Dissassembliert den Code ab der
                             Adresse aaaa, bis zur Adresse eeee.
                             Mit *S lassen sich die Striche
                             nach JMP, BRK und RTS ein- und
                             ausschalten.

, - Assemblieren eines Befehles
    ,          CMD ARG     - Der Assembler verlangt, daß die
                             Befehle im 6502-Standard an der
                             vorgesehenen Stelle stehen.
                             Er gibt die nächste freie Speicher-
                             stelle aus, setzt den Cursor und
                             wartet auf den nächsten Befehl.
                             Er akzeptiert nur Hexadezimalzahlen
                             im Format $hhhh oder $hh. Die
                             Branches werden als absolute Adresse
                             eingegeben, die Umrechnung in den
                             relativen Wert erledigt der Assembler.
                             Verlassen kann man die Eingabezeile
                             mit einem leeren Return oder Cursor.

* - Diverses
    *                      - Gibt den letzten gelesenen Track/
                             Sektor aus.
    * aa                   - Ändert den eingestellten Speicher-
                             bereich auf $aa00. Voreingestellt
                             ist zum Lesen von Blöcken $8000.
    *B                     - Umschalten auf zweiten Bildschirm
                             bei $8400?.
    *BI                    - Editieren des anderen Bildschirms
                             zum Abspeichern selbstladender
                             Programme. Verlassen des Bild-
                             schirms mit RETURN.
    *S                     - An- und Ausschalten des Disassemble-
                             RTS/JMP/BRK-Striches.

W - Write eines Blocks
    W *                    - Schreiben des aktuellen Blockes
                             an seine Adresse.
    W tr se                - Schreiben des aktuellen Blockes
                             auf den angegebenen Track/Sectors.

Z - Zeichen anzeigen
    Z aaaa [eeee]          - Zeichensatz anzeigen.
                             Jeder "." steht dabei für ein
                             0-Bit, jeder "*" für ein 1-Bit.
                             Wie beim Sprite kann auch hier 
                             geändert werden.

' - Zeichen/Sprites einlesen
  'aaaa bbbbbbbb [...]     - Eingeben von Bytes im Binärformat
                             an die Adresse aaaa. Es können bis
                             zu 3 Bytes in einer Zeile gelesen
                             werden, so wie es beim Sprite nötig
                             ist.

Viel Spaß beim Arbeiten mit dem SVS-Mon!

Die  Anleitung  wurde  5 Jahre nach Fertigstellung des Programmes
geschrieben.   Wenn  jemand  noch eine Funktion entdecken sollte,
meine  Adresse  ist  unten  angegeben.   Lob wird weitergeleitet,
Schmach in die Endablage gelegt.

  Z-Netz-Adresse:
  H.Behrens@AMTRASH.ZER

  Hausbox:
  Deutschland (049)
  Hamburg     (040)
  MAG-Box     Port 3 (657 13 32)   2400:8N1    24h online
              Port 4 (657 11 45)     "
              Port 5 (656 50 21)     "
  User: Behrens

