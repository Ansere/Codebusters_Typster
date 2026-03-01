#import "cipher_utils.typ" : *
#import "utils.typ" : *

#let replacement_table = {
  let morse = range(0, 26).map(it => [
    #(calc.floor(it / 9), calc.floor(calc.rem(it, 9)/3), calc.rem(it, 3)).map(it => "⦁-×".codepoints().at(it)).join("\n")
    ])

  [
    #set text(font: "Fira Code", size: 12pt)
    #table(columns: (auto,) + (1fr,) * 26, align: horizon + center, "Replacement", ..("",) * 26, "Morse\nFraction", ..morse, )
  ]
}

#set text(font:"Fira Code", size: 14pt)

#let frac_morse(plaintext, key, crib, value, bonus : false, questiontext: none) = {
  plaintext = plaintext.replace(regex("[^A-Za-z]"), "")
  key = key.replace(regex("[^A-Za-z]"), "")
  if upper(crib) not in upper(plaintext) {
    return error("Crib must be a substring of the plaintext")
  }
  if crib.len() < 4 {
    return error("Crib must be at least 4 characters long.")
  }
  let morse = to_morse(upper(plaintext))
  morse = morse + "x" * calc.rem(3 - calc.rem(morse.len(), 3), 3)
  let key_alphabet = strip_repeats(upper(key)) + alphabet.clusters().filter(it => not upper(key).contains(it)).join("")
  let mapping = key_alphabet.clusters().enumerate().map(it => {
    let (index, letter) = it
    let morsed_letter = (calc.floor(index / 9), calc.floor(calc.rem(index, 9)/3), calc.rem(index, 3)).map(it => ".-x".codepoints().at(it)).join("")
    return (morsed_letter, letter)
  }).to-dict()
  let ciphertext = morse.clusters().chunks(3, exact: true).map(it => mapping.at(it.join("")))
  if questiontext == none {
    questiontext = "Decode this " + strong("Fractionated Morse") + " cipher. You are told the plaintext contains the crib " + strong(upper(crib)) + " somewhere."
  }
  let displayed_ciphertext = ciphertext.join(sym.zws)
  box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    #box(width: 100%, height: auto)[
      #[
        #set text(tracking: 2em)
        #set align(left)
        #set par(leading: 3em, spacing: 3em)
        
        #set text(font: ("Fira Code"), size: 15pt)


        #displayed_ciphertext
      ]
      #replacement_table
    ]
  ]
}