#let cheat = [
  = Tables
  The tables below may be useful.

  #set text(font: "Fira Code")
  #grid(columns: (auto, auto, auto), gutter: (1fr, 0.2fr), table(columns: (3em,) + (1.5em,) * 13, align: center, table.header(strong("Keys"), .."ABCDEFGHIJKLM".clusters().map(it => strong(it))), 
  strong("A,B"), .."NOPQRSTUVWXYZ".clusters(),
  strong("C,D"), .."OPQRSTUVWXYZN".clusters(),
  strong("E,F"), .."PQRSTUVWXYZNO".clusters(),
  strong("G,H"), .."QRSTUVWXYZNOP".clusters(),
  strong("I,J"), .."RSTUVWXYZNOPQ".clusters(),
  strong("K,L"), .."STUVWXYZNOPQR".clusters(),
  strong("M,N"), .."TUVWXYZNOPQRS".clusters(),
  strong("O,P"), .."UVWXYZNOPQRST".clusters(),
  strong("Q,R"), .."VWXYZNOPQRSTU".clusters(),
  strong("S,T"), .."WXYZNOPQRSTUV".clusters(),
  strong("U,V"), .."XYZNOPQRSTUVW".clusters(),
  strong("W,X"), .."YZNOPQRSTUVWX".clusters(),
  strong("Y,Z"), .."ZNOPQRSTUVWXY".clusters()),
  // generate baconian mappings
  table(columns: (4em, 3em), align: center, "AAAAA", "A", "AAAAB", "B", "AAABA", "C", "AAABB", "D", "AABAA", "E", "AABAB", "F", "AABBA", "G", "AABBB", "H", "ABAAA", "I/J", "ABAAB", "K", "ABABA", "L", "ABABB", "M"),
  table(columns: (4em, 3em), align: center, "ABBAA", "N", "ABBAB", "O", "ABBBA", "P", "ABBBB", "Q", "BAAAA", "R", "BAAAB", "S", "BAABA", "T", "BAABB", "U/V", "BABAB", "W", "BABAB", "X", "BABBA", "Y", "BABBB", "Z"))

  #set align(center)
  #table(columns: (1.5em,) * 26, align: center, "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13", "14", "15", "16", "17", "18", "19", "20", "21", "22", "23", "24", "25")
  #table(columns: (1.5em,) * 26, align: center, "A", "B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q", "R", "S", "T", "U", "V", "W", "X", "Y", "Z", "Z", "Y", "X", "W", "V", "U", "T", "S", "R", "Q", "P", "O", "N", "M", "L", "K", "J", "I", "H", "G", "F", "E", "D", "C", "B", "A")
  #table(columns: (1.5em, ) * 12, align: center, "1", "3", "5", "7", "9", "11", "15", "17", "19", "21", "23", "25", "1", "9", "21", "15", "3", "19", "7", "23", "11", "5", "17", "25")
  #v(100%)
  #set text(font: "Libertinus")
  #set align(left)
  = Frequency Table of English letters
  #set text(font: "Fira Code", size: 10pt)
  #v(1em)
  #grid(columns: (auto, ) * 5, column-gutter: 1fr, row-gutter: 1em,
  "E - 12.51%","S - 6.54%","C - 3.06%","G - 1.96%","K - 0.67%",
  "T -  9.25%","R - 6.12%","U - 2.71%","W - 1.92%","X - 0.19%",
  "A -  8.04%","H - 5.49%","M - 2.53%","Y - 1.73%","J - 0.16%",
  "O -  7.60%","L - 4.14%","F - 2.30%","B - 1.54%","Q - 0.11%",
  "I -  7.26%","D - 3.99%","P - 2.00%","V - 0.99%","Z - 0.09%",
  "N -  7.09%", inset: (left: 2em)
  )
  #set text(font: "Libertinus")
  #set align(left)
  = Frequency Table of Spanish letters
  #set text(font: "Fira Code", size: 10pt)
  #v(1em)
  #grid(columns: (auto, ) * 5, column-gutter: 1fr, row-gutter: 1em,
  "E - 14.08%","I - 5.98%","M - 3.08%","Y - 1.09%","Z - 0.47%",
  "A - 12.16%","L - 5.24%","P - 2.89%","V - 1.05%","Ñ - 0.17%",
  "O -  9.20%","U - 4.69%","B - 1.49%","G - 1.00%","X - 0.14%",
  "S -  7.20%","D - 4.67%","H - 1.18%","F - 0.69%","K - 0.11%",
  "N -  6.83%","T - 4.60%","Q - 1.11%","J - 0.52%","W - 0.04%",
  "R -  6.41%","C - 3.87%", inset: (left: 2em)
  )

  #set text(font: "Libertinus")
  #par(justify: true, "For the purposes of cryptograms it is customary to treat n and ñ as distinct letters, but a and á are the same letter. Likewise for e and é, and i and í. In other words, all the accent marks get amputated when working with cryptograms. Also, while some older Spanish dictionaries consider ch, ll, and rr, to be their own letters — this has fallen out of modern usage. Accordingly, “burro” is considered as five letters: “b-u-r-r-o” and not as four letters “b-u-rr-o.”")

  = Morse Code
  #set text(font: "Fira Code", size: 10pt)
  #grid(columns: (auto, ) * 5, column-gutter: 1fr, 
    table(columns: (2em, 4em), align: horizon + center, "A", strong("•−"), "B", strong("−•"), "C", strong("−•−•"), "D", strong("−••"), "E", strong("•")),
    table(columns: (2em, 4em), align: horizon + center, "F", strong("••−•"), "G", strong("−−•"), "H", strong("••••"), "I", strong("••"), "J", strong("•−−−")),
    table(columns: (2em, 4em), align: horizon + center, "K", strong("−•−"), "L", strong("•−••"), "M", strong("−−"), "N", strong("−•"), "O", strong("−−−")),
    table(columns: (2em, 4em), align: horizon + center, "P", strong("•−−•"), "Q", strong("−−•−"), "R", strong("•−•"), "S", strong("•••"), "T", strong("−")),
    table(columns: (2em, 4em), align: horizon + center, "U", strong("••−"), "V", strong("•••−"), "W", strong("•−−"), "X", strong("−••−"), "Y", strong("−•−−"), "Z", strong("−−••")),
  )
  #grid(columns: (auto, ) * 5, column-gutter: 1fr,
    table(columns: (2em, 4em), align: horizon + center, "0", strong("−−−−−"), "1", strong("•−−−−")),
    table(columns: (2em, 4em), align: horizon + center, "2", strong("••−−−"), "3", strong("•••−−")),
    table(columns: (2em, 4em), align: horizon + center, "4", strong("••••−"), "5", strong("•••••")),
    table(columns: (2em, 4em), align: horizon + center, "6", strong("−••••"), "7", strong("−−•••")),
    table(columns: (2em, 4em), align: horizon + center, "8", strong("−−−••"), "9", strong("−−−−•")),
  )
  \

  #grid(columns: (auto, ) * 7, column-gutter: 1fr,
    table(columns: (4em, 2em), align: horizon + center, "•", "E", "••", "I", "•••", "S", "••••", "H", "−•••", "B", "−−−−−", "0", "•••••", "5"),
    table(columns: (4em, 2em), align: horizon + center, "−", "T", "−•", "A", "••−", "U", "•••−", "V", "−••−", "X", "•−−−−", "1", "−••••", "6"),
    table(columns: (4em, 2em), align: horizon + center, "−•", "N", "•−•", "R", "••−•", "F", "−•−•", "C", "••−−−", "2", "−−•••", "7"),
    table(columns: (4em, 2em), align: horizon + center, "−−", "M", "•−−", "W", "•−••", "L", "−•−−", "Y", "•••−−", "3", "−−−••", "8"),
      table(columns: (4em, 2em), align: horizon + center,
      "−••", "D", "•−−•", "P", "−−••", "Z", "••••−", "4", "−−−−•", "9"
    ),
    table(columns: (4em, 2em), align: horizon + center,
      "−•−", "K", "•−−−", "J", "−•−•", "Q"
    ),
    table(columns: (4em, 2em), align: horizon + center,
      "−−•", "G", "−−−", "O"
    ),
  )
  #v(100%)
]
