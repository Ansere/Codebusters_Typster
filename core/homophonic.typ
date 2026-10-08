#import "cipher_utils.typ": *
#import "utils.typ": *
#import "@preview/suiji:0.5.1": *

#let homophonic_mapping(key) = {
  key = answerize(key).replace("J", "I")
  let letters = alphabet.replace("J", "").clusters()
  let mapping = letters.enumerate().map(it => {
    let (index, letter) = it
    let values = key.clusters().enumerate().map(it => {
      let (band, start) = it
      return band * 25 + calc.rem-euclid(index - letters.position(it => it == start), 25) + 1
    })
    return (letter, values)
  }).to-dict()
  mapping.insert("J", mapping.at("I"))
  return mapping
}

#let homophonic_encode(rng, plaintext, mapping, crib_start: 0, crib_length: 0, alphabets: none) = {
  let bands = range(4)
  let crib_bands = ()
  if alphabets != none {
    (rng, bands) = shuffle-f(rng, bands)
    bands = bands.slice(0, alphabets)
    // Reveal each selected alphabet, then choose freely among those alphabets.
    for i in range(crib_length) {
      let band = 0
      if i < alphabets {
        band = bands.at(i)
      } else {
        (rng, band) = choice-f(rng, bands)
      }
      crib_bands.push(band)
    }
    (rng, crib_bands) = shuffle-f(rng, crib_bands)
  }
  let ciphertext = ()
  for (i, letter) in plaintext.clusters().enumerate() {
    let band = 0
    if alphabets != none and i >= crib_start and i < crib_start + crib_length {
      band = crib_bands.at(i - crib_start)
    } else {
      (rng, band) = choice-f(rng, range(4))
    }
    ciphertext.push(mapping.at(letter).at(band))
  }
  return (rng, ciphertext)
}

#let homophonic(rng, plaintext, type, value, key: none, crib: none, alphabets: none, bonus: false, questiontext: none) = {
  plaintext = answerize(plaintext).replace("J", "I")
  if plaintext == "" {
    return (rng, error("Plaintext cannot be empty"))
  }
  if type == none or not (upper(type) in ("ENCODE", "DECODE", "CRYPTANALYSIS")) {
    return (rng, error("Homophonic type must be specified (ENCODE, DECODE, or CRYPTANALYSIS)"))
  }
  type = upper(type)
  if key == none {
    return (rng, error("Key must be specified for Homophonic cipher"))
  }
  key = answerize(key).replace("J", "I")
  if key.len() != 4 or strip_repeats(key).len() != 4 {
    return (rng, error("Homophonic key must contain four unique letters (I/J share a value)"))
  }
  let crib_start = 0
  if type == "CRYPTANALYSIS" {
    if crib == none {
      return (rng, error("Crib must be specified for Homophonic cryptanalysis"))
    }
    crib = answerize(crib).replace("J", "I")
    if crib == "" or not plaintext.contains(crib) {
      return (rng, error("Crib must be a nonempty substring of the plaintext"))
    }
    crib_start = plaintext.position(crib)
  }
  if alphabets == "" { alphabets = none }
  if alphabets != none {
    if type != "CRYPTANALYSIS" {
      return (rng, error("Crib alphabet count is only used for Homophonic cryptanalysis"))
    }
    if str(alphabets).match(regex("^[1-4]$")) == none {
      return (rng, error("Crib alphabet count must be an integer from 1 to 4"))
    }
    alphabets = int(alphabets)
    if crib.len() < alphabets {
      return (rng, error("Crib must have at least one letter per revealed alphabet"))
    }
  }
  let mapping = homophonic_mapping(key)
  let ciphertext = ()
  (rng, ciphertext) = homophonic_encode(
    rng, plaintext, mapping,
    crib_start: crib_start,
    crib_length: if type == "CRYPTANALYSIS" { crib.len() } else { 0 },
    alphabets: alphabets,
  )
  if questiontext == none or questiontext == "" {
    if type == "CRYPTANALYSIS" {
      questiontext = "Solve this *Homophonic* cipher using the partial decryption provided below."
    } else if type == "ENCODE" {
      questiontext = "Encode this *plaintext* using the *Homophonic* cipher with the key *" + key + "*. Choose any of the four corresponding values for each letter."
    } else {
      questiontext = "Decode this *ciphertext* using the *Homophonic* cipher with the key *" + key + "*."
    }
    questiontext += " I and J share a value."
  }
  if bonus {
    questiontext += "* ★ This is a special bonus question.*"
  }
  let disp = box()[
    (#value points) #eval(questiontext, mode: "markup")
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)
    #box(width: 100%)[
      #set align(left)
      #set par(leading: 3em, spacing: 3em)
      #{
        if type == "ENCODE" {
          blockify(plaintext, 5).join(" ")
        } else {
          for chunk in ciphertext.chunks(5) {
            box(chunk.map(str).join(" "))
            h(1.5em)
          }
        }
      }
      #if type == "CRYPTANALYSIS" [
        #set par(leading: 0.5em, spacing: 1em)
        #set text(size: 12pt)
        Partial decryption (starting at ciphertext value #(crib_start + 1)):\
        #{
          for chunk in ciphertext.slice(crib_start, crib_start + crib.len()).zip(crib.clusters()).chunks(5) {
            box(table(
              columns: (auto,) * chunk.len(),
              align: center,
              ..chunk.map(it => str(it.at(0))),
              ..chunk.map(it => it.at(1)),
            ))
            h(0.5em)
          }
        }
      ]
    ]
  ]
  return (rng, disp)
}
