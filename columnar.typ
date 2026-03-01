#import "@preview/suiji:0.5.1" : *
#import "utils.typ" : *

#let columnar(rng, plaintext, columns, crib, value, bonus : false,  questiontext: none) = {
  plaintext = upper(plaintext).replace(regex("[^A-Za-z]"), "")
  crib = upper(crib).replace(regex("[^A-Za-z]"), "")
  if upper(crib) not in upper(plaintext) {
    return (rng, error("Crib must be a substring of the plaintext"))
  }
  if columns > 9 {
    return (rng, error("Number of columns must be less than 10."))
  }
  if crib.len() < columns - 1 {
    return (rng, error("Crib must be at least [columns - 1] characters long."))
  }
  plaintext = plaintext + "X" * calc.rem(columns - calc.rem(plaintext.len(), columns), columns)
  let rows = calc.ceil(plaintext.len() / columns)
  let grid = range(0, rows).map(it => range(0, columns).map(_ => " "))
  for (i, char) in plaintext.clusters().enumerate() {
    grid.at(calc.quo(i, columns)).at(calc.rem(i, columns)) = char
  }
  let shuffled = 0
  (rng, shuffled) = shuffle-f(rng, range(0, columns).map(it => grid.map(row => row.at(it)).join("")))
  let ciphertext = shuffled.join("").clusters().chunks(5).map(it => it.join("")).join(" ")
  if questiontext == none {
   questiontext = "Decode this " + strong("Columnar Transposition") + " cipher. You are told the plaintext contains the crib " + strong(upper(crib)) + " somewhere."
  } 
  let disp = box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    #box(width: 100%, height: auto)[
      #[
        #set align(left)
        #set par(leading: 3em, spacing: 3em)
        
        #set text(font: ("Fira Code"), size: 14pt)
        #ciphertext
      ]
    ]
  ]
  return (rng, disp)
}




