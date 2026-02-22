#import "cipher_utils.typ": *
#import "@preview/suiji:0.5.1": *
#import "utils.typ": *

#let get_word_list(mapping) = {
  let word_list = read("wordlist.txt").split("\n").filter(it => it != "").map(it => upper(it.trim()))
  let word_mappings = (:)
  for word in word_list {
    let baconed_word = word.clusters().map(c => mapping.at(c)).join("")
    if baconed_word in word_mappings {
      word_mappings.at(baconed_word).push(word)
    } else {
      word_mappings.insert(baconed_word, (word,))
  }}
  return word_mappings
}

#let baconian(rng, plaintext, type, value, a: none, b: none, questiontext: none, amount : 0, bonus : false) = {
  if type == none {
    return (rng, error("Baconian type must be specified (encode or decode)"))
  }
  let bacon = baconify(plaintext)
  if questiontext == none {
    questiontext = "Decode this " + strong("Baconian") + " cipher."
  }
  if bonus {
    questiontext += strong(" ★ This is a special bonus question.")
  }
  if type == "SEQUENCE" or type == "LETTERS" {
    if a == none or b == none {
      return (rng, error("Both A and B characters must be specified for " + type + " type"))
    }
    let ciphertext = ""
    if type == "LETTERS" {
      let curr_a = 0
      let curr_b = 0
      for c in bacon {
        if c == "0" {
          ciphertext += a.codepoints().at(curr_a)
          curr_a = calc.rem(curr_a + 1, a.codepoints().len())
        } else if c == "1" {
          ciphertext += b.codepoints().at(curr_b)
          curr_b = calc.rem(curr_b + 1, b.codepoints().len())
        }
      }
    } else {
      for (i, c) in bacon.clusters().enumerate() {
        if c == "0" {
          ciphertext += a.codepoints().at(calc.rem(i, a.codepoints().len()))
        } else if c == "1" {
          ciphertext += b.codepoints().at(calc.rem(i, b.codepoints().len()))
        }
      }
    }
    return (rng, [
      #box()[
        (#value points) #questiontext
        \
        #set text(font: "Fira Code", size: 14pt)
        #set align(center)

        #box(width: 100%)[
          #set align(left)
          #set par(leading: 3em, spacing: 3em)
          #set text(font: ("Fira Code", "Source Han Code JP R"), size: 14pt)
          #ciphertext
        ]
      ]
    ])
  } else if type == "WORDS" {
    if amount == none or amount <= 0 {
      return (rng, error("Amount of words must be specified and greater than 0 for WORDS type"))
    }
    amount = calc.rem(amount - 1, 26) + 1  
    let mapping = (:)
    let c = 0
    let (rng, rand) = random-f(rng)
    let curr = calc.round(rand)
    for letter in alphabet {
      mapping.insert(letter, str(curr))
      c += 1
      if c >= amount {
        c = 0
        curr = 1 - curr
      }
    }
    let word_mappings = get_word_list(mapping)
    let bacon_chunks = bacon.clusters().chunks(5).map(it => it.join(""))
    let ciphertext_words = ()
    for chunk in bacon_chunks {
      if chunk in word_mappings {
        let choice = 0
        (rng, choice) = choice-f(rng, word_mappings.at(chunk))
        ciphertext_words.push(choice)
      } else {
        return (rng, error("No word found for Baconian chunk: " + chunk))
      }
    }
    let ciphertext = ciphertext_words.join(" ")
    return (rng, [
      #box()[
        (#value points) #questiontext
        \
        #set text(font: "Fira Code", size: 14pt)
        #set align(center)

        #box(width: 100%)[
          #set align(left)
          #set par(leading: 3em, spacing: 3em)
          #set text(font: ("Fira Code", "Source Han Code JP R"), size: 14pt)
          #ciphertext
        ]
      ]
     ]
    )
  } else {
    return (rng, error("Invalid Baconian type specified. Must be SEQUENCE, LETTERS, or WORDS."))
  }
}



