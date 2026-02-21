#import "@preview/suiji:0.5.1": *

#let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
#let generate_rand_alphabet(rng) = {
  let shuffledAlphabet = ()
  let iden = false
  while not iden {
    (rng, shuffledAlphabet) = shuffle-f(rng, alphabet.clusters())
    iden = true
    for i in range(26) {
      if alphabet.at(i) == shuffledAlphabet.at(i) {
        iden = false
        break
      }
    }
  }
  return (rng, shuffledAlphabet)
}

#let strip_repeats(s) = {
  s.clusters().dedup().join("")
}

#let answerize(s) = {
  upper(s.replace(regex("[^A-Za-z]"), ""))
}


#let mod_inverse(a, m) = {
  let m0 = m
  let x0 = 0
  let x1 = 1
  if m == 1 {
    return 0
  }
  while a > 1 {
    let q = calc.floor(a / m)
    let t = m
    m = calc.rem(a, m)
    a = t
    t = x0
    x0 = x1 - q * x0
    x1 = t
  }
  if x1 < 0 {
    x1 += m0
  }
  return x1
}

#let conv_A0Z25(x) = {
  return str.from-unicode(calc.rem(x, 26) + 65)
}

#let conv_0A25Z(s) = {
  return str.to-unicode(s) - 65
}

#let string_A0Z25(s) = {
  return s.clusters().map(conv_0A25Z)
}

#let blockify(s, size) = {
  return str.clusters(s).chunks(size).map(it => it.join(""))
}

#let to_morse(s) = {
  let morse_code = (
    "A": ".-",
    "B": "-...",
    "C": "-.-.",
    "D": "-..",
    "E": ".",
    "F": "..-.",
    "G": "--.",
    "H": "....",
    "I": "..",
    "J": ".---",
    "K": "-.-",
    "L": ".-..",
    "M": "--",
    "N": "-.",
    "O": "---",
    "P": ".--.",
    "Q": "--.-",
    "R": ".-.",
    "S": "...",
    "T": "-",
    "U": "..-",
    "V": "...-",
    "W": ".--",
    "X": "-..-",
    "Y": "-.--",
    "Z": "--..",
  )
  return upper(s.replace(regex("[^A-Za-z ]"), "")).split(" ").filter(it => it != "").map(it => it.clusters().map(c => morse_code.at(c)).join("x")).join("xx")
}


#let generate_k_alphabet(key, shift) = {
  let circle_shift(s, shift) = { 
    let n = s.len()
    return s.clusters().enumerate().map(it => s.at(calc.rem(it.at(0) - shift, n))).join("")
  }

  let k_alphabet = strip_repeats(key) + alphabet.clusters().filter(it => not key.contains(it)).join("")
  k_alphabet = circle_shift(k_alphabet, shift)
  return k_alphabet
}

#let baconify(s) = {
  return answerize(s).clusters().map(it => {
    let a = conv_0A25Z(it)
    if (a >= 9) {
      a -= 1
    }
    if (a >= 20) {
      a -= 1
    }
    let binary = ""
    for i in range(5){
        binary += str(calc.rem(a, 2))
        a = calc.floor(a/2)
    }
    return binary.rev()
  }).join("")
}
