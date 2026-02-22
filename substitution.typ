#import "cipher_utils.typ": *
#import "@preview/suiji:0.5.1": *
#import "utils.typ": *

#let frequencytable(mapping, counts, k:none) = {
    [
      #set text(font: "Fira Code", size: 9pt)
      #set align(left)
      #if k != 2 [
        
          #table(columns: (auto,) + (1fr,)* (mapping.len()), rows: 3, align: center, table.header([#{
          if k != none {
            strong("K" + str(k))
          }
        }], ..mapping.keys()), "Frequency", ..counts.map(it => str(it)), "Replacement")

      ] else [
        #table(columns: (auto,) + (1fr,)* (mapping.len()), rows: 3, align: center, table.header([#{
          "Replacement"
        }]), strong("K2"), ..mapping.values(), "Frequency", ..counts.map(it => str(it)))
      ]
    ]
}

#let aristo_encode(plaintext, mapping) = {
  return upper(plaintext).clusters().map(c => if alphabet.contains(c) { 
    return mapping.at(c) 
  } else { 
    return c 
  }).join("")
}

#let aristocrat(rng, plaintext, value, type, k : none, questiontext : none, key : none, shift : none) = {
  if not (upper(type) == "DECODE" or upper(type) == "EXTRACT") {
    return (rng, error("Aristocrat type must be specified (decode or extract)"))
  }

  let display(questiontext, ciphertext, mapping, counts, value, k, type, key) = {
    if questiontext == none {
      questiontext = "Solve this " + strong("Aristocrat") + " cipher"
      if k != none {
        questiontext += " that was encoded using a " + strong("K" + str(k)) + " alphabet."
      } else {
        questiontext += "."
      }
      if type == "EXTRACT" {
        questiontext += " What was the key used to encode it?"
      }
    }
    [
      #box()[
        (#value points) #questiontext
        \
        #set text(font: "Fira Code", size: 14pt)
        #set align(center)
        
        #box(width: 100%)[
          #set align(left)

          
          #{
            if type == "EXTRACT" [
              #set text(size: 12pt)
              Keyword:
              #set text(size: 14pt)
              #block(below: 1em, above: 0.5em)[
                #table(columns: key.codepoints().map(it => {
                  if it == " " {
                    return 0.5em
                  } else {
                    return 1em
                  }
                }), rows: (2em), align: center, stroke: none, ..key.codepoints().map(it => {
                  if it == " " {
                    return table.cell("")
                  } else {
                    return table.cell(stroke: black)[ ]
                  }
                }))
              ]
            ]
          }
          
          
          #set par(leading: 3em, spacing: 3em)

          #ciphertext
          
          #frequencytable(mapping, counts, k: k)
        ]
      ]

    ]
  }

  if k == none {
    if type == "EXTRACT" {
      return (rng, error("k must be specified for extract type"))
    }
    let (rng, shuffled_alphabet) = generate_rand_alphabet(rng)
    let mapping = alphabet.clusters().zip(shuffled_alphabet, exact: true).to-dict()
    let ciphertext = aristo_encode(plaintext, mapping)
    let counts = alphabet.clusters().map(c => upper(ciphertext).clusters().filter(pc => pc == c).len())
    return (rng, display(questiontext, ciphertext, mapping, counts, value, k, type, key))
  } else {
    if key == none {
      return (rng, error("Key must be provided when k is specified"))
    }
    if shift == none {
      return (rng, error("Shift must be provided when k is specified"))
    }
    let cleaned_key = key.replace(regex("[^A-Za-z]"), "")
    let ciphertext_alpha = generate_k_alphabet(cleaned_key, shift)
    let plaintext_alpha = alphabet
    if k == 2 {
      (ciphertext_alpha, plaintext_alpha) = (plaintext_alpha, ciphertext_alpha)
    } else if k == 3 {
      plaintext_alpha = circle_shift(ciphertext_alpha, -shift)
    }
    let mapping = plaintext_alpha.clusters().zip(ciphertext_alpha.clusters(), exact: true).sorted().to-dict()
    for (key, value) in mapping{
      if key == value {
        return (rng, error("Invalid mapping: " + key + " maps to itself"))
      }
    }
    let ciphertext = aristo_encode(plaintext, mapping)
    let counts = alphabet.clusters().map(c => upper(ciphertext).clusters().filter(pc => pc == c).len())
    return (rng, display(questiontext, ciphertext, mapping, counts, value, k, type, key))
  }
} 

#let patristocrat(rng, plaintext, value, type, k : none, questiontext : none, key : none, shift : none) = {
  if questiontext == none {
    questiontext = "Solve this " + strong("Patristocrat") + " cipher"
    if k != none {
      questiontext += " that was encoded using a " + strong("K" + str(k)) + " alphabet."
    } else {
      questiontext += "."
    }
  }
  let plaintext_adj = blockify(plaintext.replace(regex("[^A-Za-z]"), ""), 5).join(" ")
  aristocrat(rng, plaintext_adj, value, type, k: k, questiontext: questiontext, key: key, shift: shift)
}

#let xenocrypt(rng, plaintext, value, type, k : none, questiontext : none, key : none, shift : none) = {
  if not (upper(type) == "DECODE" or upper(type) == "EXTRACT") {
    return (rng, error("Xenocrypt type must be specified (decode or extract)"))
  }

  let display(questiontext, ciphertext, mapping, counts, value, k, type, key) = {
    if questiontext == none {
      questiontext = "Solve this " + strong("Xenocrypt") + " cipher"
      if k != none {
        questiontext += " that was encoded using a " + strong("K" + str(k)) + " alphabet."
      } else {
        questiontext += "."
      }
      if type == "EXTRACT" {
        questiontext += " What was the key used to encode it?"
      }
    }
    [
      #box()[
        (#value points) #questiontext
        \
        #set text(font: "Fira Code", size: 14pt)
        #set align(center)
        
        #box(width: 100%)[
          #set align(left)
          #{
            if type == "EXTRACT" [
              #set text(size: 12pt)
              Keyword:
              #set text(size: 14pt)
              #block(below: 1em, above: 0.5em)[
                #table(columns: key.codepoints().map(it => {
                  if it == " " {
                    return 0.5em
                  } else {
                    return 1em
                  }
                }), rows: (2em), align: center, stroke: none, ..key.codepoints().map(it => {
                  if it == " " {
                    return table.cell("")
                  } else {
                    return table.cell(stroke: black)[ ]
                  }
                }))
              ]
            ]
          }
          #set par(leading: 3em, spacing: 3em)
          #ciphertext
          
          #frequencytable(mapping, counts, k: k)
        ]
      ]

    ]
  }

  let spanish_alphabet = "ABCDEFGHIJKLMNÑOPQRSTUVWXYZ"

  let generate_rand_span_alphabet(rng) = {
    let shuffledAlphabet = ()
    let iden = false
    while not iden {
      (rng, shuffledAlphabet) = shuffle-f(rng, spanish_alphabet.clusters())
      iden = true
      for i in range(27) {
        if spanish_alphabet.codepoints().at(i) == shuffledAlphabet.at(i) {
          iden = false
          break
        }
      }
    }
    return (rng, shuffledAlphabet)
  }

  let generate_k_alphabet(key, shift) = {
    let circle_shift(s, shift) = { 
      let n = s.clusters().len()
      return s.codepoints().enumerate().map(it => s.codepoints().at(calc.rem(it.at(0) - shift, n))).join("")
    }

    let k_alphabet = strip_repeats(key) + spanish_alphabet.clusters().filter(it => not key.contains(it)).join("")
    k_alphabet = circle_shift(k_alphabet, shift)
    return k_alphabet
  }

  plaintext = upper(plaintext).replace("Á", "A").replace("É", "E").replace("Í", "I").replace("Ó", "O").replace("Ú", "U")

  if k == none {
    let (rng, shuffled_alphabet) = generate_rand_span_alphabet(rng)
    let mapping = spanish_alphabet.clusters().zip(shuffled_alphabet, exact: true).to-dict()
    let ciphertext = aristo_encode(plaintext, mapping)
    let counts = spanish_alphabet.clusters().map(c => upper(ciphertext).clusters().filter(pc => pc == c).len())
    return (rng, display(questiontext, ciphertext, mapping, counts, value, k, type, key))
  } else {
    if key == none {
      return (rng, error("Key must be provided when k is specified"))
    }
    if shift == none {
      return (rng, error("Shift must be provided when k is specified"))
    }
    // the key can also contain n-tildes, so include it 
    let cleaned_key = upper(key).replace(regex("[^A-Za-zÑ]"), "")
    let ciphertext_alpha = generate_k_alphabet(cleaned_key, shift)
    let plaintext_alpha = spanish_alphabet
    if k == 2 {
      (ciphertext_alpha, plaintext_alpha) = (plaintext_alpha, ciphertext_alpha)
    } else if k == 3 {
      plaintext_alpha = circle_shift(ciphertext_alpha, -shift)
    }
    let unsorted_mapping = plaintext_alpha.clusters().zip(ciphertext_alpha.clusters(), exact: true).to-dict()
    let mapping = spanish_alphabet.clusters().map(it => (it, unsorted_mapping.at(it))).to-dict()
    for (key, value) in mapping{
      if key == value {
        return (rng, error("Invalid mapping: " + key + " maps to itself"))
      }
    }
    let ciphertext = aristo_encode(plaintext, mapping)
    let counts = spanish_alphabet.clusters().map(c => upper(ciphertext).clusters().filter(pc => pc == c).len())
    return (rng, display(questiontext, ciphertext, mapping, counts, value, k, type, key))
  }
} 

#let affine(plaintext, value, a, b, questiontext: none) = {
  if calc.gcd(a, 26) != 1 {
    error("a must be coprime to 26")
    return
  }
  if questiontext == none {
    questiontext = "Solve this " + strong("Affine") + " cipher with a = " + str(a) + " and b = " + str(b) + "."
  }
  let mapping = alphabet.clusters().map(c => {
    let x = conv_0A25Z(c)
    let y = calc.rem(a * x + b, 26)
    return (c, conv_A0Z25(y))
  }).to-dict()
  let ciphertext = aristo_encode(plaintext, mapping)
  box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    
    #box(width: 100%)[
      #set align(left)
      #set par(leading: 3em, spacing: 3em)
      #ciphertext
    ]
  ]

}

#let caesar(plaintext, value, shift, questiontext: none) = {
  if questiontext == none {
    questiontext = "Solve this " + strong("Caesar") + " cipher with a shift of " + str(shift) + "."
  }
  let mapping = alphabet.clusters().map(c => {
    let x = conv_0A25Z(c)
    let y = calc.rem(x + shift, 26)
    return (c, conv_A0Z25(y))
  }).to-dict()
  let ciphertext = aristo_encode(plaintext, mapping)
  box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    
    #box(width: 100%)[
      #set align(left)
      #set par(leading: 3em, spacing: 3em)
      #ciphertext
    ]
  ]
}

#let atbash(plaintext, value, questiontext: none) = {
  if questiontext == none {
    questiontext = "Solve this " + strong("Atbash") + " cipher."
  }
  let mapping = alphabet.clusters().map(c => {
    let x = conv_0A25Z(c)
    let y = calc.rem(-x, 26) + 25
    return (c, conv_A0Z25(y))
  }).to-dict()
  let ciphertext = aristo_encode(plaintext, mapping)
  box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    
    #box(width: 100%)[
      #set align(left)
      #set par(leading: 3em, spacing: 3em)
      #ciphertext
     ]
   ]
}