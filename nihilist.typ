#import "@preview/meander:0.4.1": *
#import "utils.typ": *
#import "cipher_utils.typ": *

#let nihilist(plaintext, key, polybius, value, bonus : false, questiontext: none) = {
  plaintext = upper(plaintext).replace(regex("[^A-Za-z]"), "")
  key = upper(key).replace(regex("[^A-Za-z]"), "")
  polybius = upper(polybius).replace(regex("[^A-Za-z]"), "")
  if key.replace(" ", "") == "" {
    return error("Key cannot be empty")
  }
  if polybius.replace(" ", "") == "" {
    return error("Polybius key cannot be empty")
  }
  polybius = polybius.replace("J", "I")
  let polybius_dict = (
    strip_repeats(polybius) + alphabet.clusters().filter(it => it != "J" and it not in polybius).join("")
  )
    .clusters()
    .enumerate()
    .map(it => {
      let (index, letter) = it
      let row = calc.quo(index, 5) + 1
      let col = calc.rem(index, 5) + 1
      return (letter, row * 10 + col)
    })
    .to-dict()
  let ciphertext = plaintext
    .clusters().enumerate()
    .map(it => str(polybius_dict.at(it.at(1)) + polybius_dict.at(key.at(calc.rem(it.at(0), key.len())))))
    .chunks(5).map(it => it.join(" "))
    .map(it => box()[
      #it
    ])
  if questiontext == none {
    questiontext = "Encode this plaintext using the " + strong("Nihilist") + " cipher with a key of " + strong(key) + " and a Polybius key of " + strong(polybius) + ". What is the resulting ciphertext?"
  }
  if bonus {
    questiontext += strong(" ★ This is a special bonus question.")
  }
  box(width: 100%)[
    (#value points) #questiontext
    #set text(font: "Fira Code", size: 14pt)

    #box()[
      #set par(leading: 6em)
    #reflow({
      placed(top + right, table(
        columns: (1.9em,) * 6,
        rows: (2em,) * 6,
        table.cell(stroke: none)[], [1], [2], [3], [4], [5], [1], [], [], [], [], [], [2], [], [], [], [], [], [3], [], [], [], [], [], [4], [], [], [], [], [], [5], [], [], [], [], [], align: horizon + center
      ))
      container()
      content[
      
        #{
          for thing in ciphertext {
            thing
            h(2em)
          }
        }
      ]
    })
    ]
    

  ]
}