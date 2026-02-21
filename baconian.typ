#import "cipher_utils.typ" : *

#let baconian(plaintext, type, a: none, b:none, questiontext: none, value: 0) = {
  if type == none {
    error("Baconian type must be specified (encode or decode)")
  }
  let alphabet = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
  let rng = alphabet.clusters()
  let shuffledAlphabet = alphabet.clusters()
  if type == "SEQUENCE" or type == "LETTERS" {
    if a == none or b == none {
      error("Both A and B characters must be specified for " + type + " type")
      return
    }
    
  } else if type == "WORDS" {
  } else {
    error("Invalid Baconian type specified. Must be SEQUENCE, LETTERS, or WORDS.")
    return
  }
}

#baconian