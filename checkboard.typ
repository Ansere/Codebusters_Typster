#import "cipher_utils.typ": *
#import "utils.typ": *
#import "@preview/meander:0.4.1": *

#let checkerboard(plaintext, row_key, col_key, polybius_key, value, bonus: false, questiontext: none) = {
  plaintext = upper(plaintext).replace(regex("[^A-Za-z]"), "").replace("J", "I")
  row_key = upper(row_key).replace(regex("[^A-Za-z]"), "")
  col_key = upper(col_key).replace(regex("[^A-Za-z]"), "")
  polybius_key = upper(polybius_key).replace(regex("[^A-Za-z]"), "").replace("J", "I")
  if row_key.len() != col_key.len() or row_key.len() != 5 {
    return error("Row key and column key must be 5 characters long.")
  }
  let polybius_dict = (
    strip_repeats(polybius_key) + alphabet.clusters().filter(it => it != "J" and not polybius_key.contains(it)).join("")
  )
    .clusters()
    .enumerate()
    .map(it => {
      let (index, letter) = it
      let row = calc.quo(index, 5)
      let col = calc.rem(index, 5)
      return (letter, row_key.at(row) + col_key.at(col))
    })
    .to-dict()
  let ciphertext = plaintext
    .clusters()
    .map(it => polybius_dict.at(it))
    .chunks(5)
    .map(it => it.join(" "))
    .map(it => box()[
      #it
    ])
  if questiontext == none {
    questiontext = (
      "Decode this plaintext using the "
        + strong("Checkerboard cipher")
        + " with Polybius key "
        + strong(polybius_key)
        + "."
    )
  }

  box(width: 100%)[
    (#value points) #questiontext
    #set text(font: "Fira Code", size: 14pt)

    #box()[
      #set par(leading: 6em)
    #reflow({
      placed(top + right, table(
        columns: (2em,) * 6,
        rows: (2em,) * 6,
        table.cell(stroke: none)[],
      ))
      container()
      content[
        #{
          for thing in ciphertext {
            thing
            h(1.5em)
          }
        }
      ]
    })
    ]
    

  ]
}

