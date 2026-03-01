#import "cipher_utils.typ" : *
#import "utils.typ" : *

#let porta(plaintext, key, value, type, bonus : false, questiontext: none) = {
  if plaintext.replace(" ", "") == "" {
    return error("Plaintext cannot be empty")
  }
  if key.replace(" ", "") == "" {
    return error("Key cannot be empty")
  }
  if type != "ENCODE" and type != "DECODE" {
    return error("Type must be either ENCODE or DECODE")
  }
  key = upper(key).replace(regex("[^A-Za-z]"), "")
  let ciphertext = "!"
  let ciphertext = upper(plaintext).replace(regex("[^A-Z]"), "").clusters().enumerate().map(it => {
    let i = conv_0A25Z(it.at(1))
    let k = calc.quo(conv_0A25Z(key.at(calc.rem(it.at(0), key.len()))), 2)
    if i < 13 {
      return conv_A0Z25(13 + calc.rem(k + i, 13))
    } else {
      return conv_A0Z25(calc.rem(i - k, 13))
    }
  }).chunks(5).map(it => it.join("")).join(" ")
  if questiontext == none {
    if type == "ENCODE" {
      questiontext = "Encode "
    } else {
      questiontext = "Decode "
    }
    questiontext += ( "this "
        + strong("plaintext")
        + " using the "
        + strong("Porta")
        + " cipher with the key "
        + strong(key)
        + ". What is the resulting ciphertext?" )
  }

  if bonus {
    questiontext += strong(" ★ This is a special bonus question.")
  }

  [ 
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set par(leading: 3em, spacing: 1em)
    #set align(center)
    #{ 
      if type == "ENCODE" {
        box(width: 100%)[ 
          #set align(left)
          #upper(plaintext).replace(regex("[^A-Z]"), "").clusters().chunks(5).map(it => it.join("")).join(" ")
          ]
      } else {
        box(width: 100%)[ 
          #set align(left)
          #ciphertext 
          
          ]
      }
    }
  ]

}