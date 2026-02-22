#import "cipher_utils.typ": *
#import "utils.typ" : *

#let hill(plaintext, type, value, key, questiontext: none, bonus : false) = {
  if not (upper(type) == "ENCODE" or upper(type) == "DECODE") {
    return error("Hill cipher type must be specified (ENCODE or DECODE)")
  }
  if key == none {
    return error("Key must be specified for Hill cipher")
  }
  if not (key.len() == 4 or key.len() == 9) {
    return error("Key must be 4 or 9 characters long for Hill cipher")
  }
  if questiontext == none {
    if upper(type) == "ENCODE" {
      questiontext = "Encode this Hill cipher. The key is " + strong(key) + "."
    } else {
      questiontext = "Decode this Hill cipher. The key is " + strong(key) + "."
    }
  }
  if bonus {
    questiontext += strong(" ★ This is a special bonus question.")
  }
  if (upper(type) == "ENCODE") {
    return error("Encode not implemented yet for Hill cipher")
  }
  let n = int(calc.sqrt(key.len()))
  let key_matrix = key.clusters().chunks(n)
  let matrix = key_matrix.map(it => it.map(c => conv_0A25Z(c)))
  plaintext = upper(plaintext).replace(regex("[^A-Z]"), "")

  // find determinant of matrix
  let det = 0
  if n == 2 {
    det = matrix.at(0).at(0) * matrix.at(1).at(1) - matrix.at(0).at(1) * matrix.at(1).at(0)
  } else if n == 3 {
    det = matrix.at(0).at(0) * (matrix.at(1).at(1) * matrix.at(2).at(2) - matrix.at(1).at(2) * matrix.at(2).at(1)) - matrix.at(0).at(1) * (matrix.at(1).at(0) * matrix.at(2).at(2) - matrix.at(1).at(2) * matrix.at(2).at(0)) + matrix.at(0).at(2) * (matrix.at(1).at(0) * matrix.at(2).at(1) - matrix.at(1).at(1) * matrix.at(2).at(0))
  }

  det = calc.rem(26 + calc.rem(det, 26), 26)
  if calc.gcd(det, 26) != 1 {
    return error("Key matrix is not invertible mod 26, determinant is " + str(det))
  }

  //find inverse matrix if n == 3
  let inverse_matrix = ()
  if n == 3 {
    //find inverse matrix of n by n (n = 3), you are given the determinant and it is guaranteed to be coprime to 26, it is also already mod 26. do not use cofactors, use the formula for the inverse of a 3x3 matrix and then take everything mod 26
    let det_inv = mod_inverse(det, 26)
    inverse_matrix = (
      (
        (matrix.at(1).at(1) * matrix.at(2).at(2) - matrix.at(1).at(2) * matrix.at(2).at(1)) * det_inv,
        (matrix.at(0).at(2) * matrix.at(2).at(1) - matrix.at(0).at(1) * matrix.at(2).at(2)) * det_inv,
        (matrix.at(0).at(1) * matrix.at(1).at(2) - matrix.at(0).at(2) * matrix.at(1).at(1)) * det_inv
      ),
      (
        (matrix.at(1).at(2) * matrix.at(2).at(0) - matrix.at(1).at(0) * matrix.at(2).at(2)) * det_inv,
        (matrix.at(0).at(0) * matrix.at(2).at(2) - matrix.at(0).at(2) * matrix.at(2).at(0)) * det_inv,
        (matrix.at(0).at(2) * matrix.at(1).at(0) - matrix.at(0).at(0) * matrix.at(1).at(2)) * det_inv
      ),
      (
        (matrix.at(1).at(0) * matrix.at(2).at(1) - matrix.at(1).at(1) * matrix.at(2).at(0)) * det_inv,
        (matrix.at(0).at(1) * matrix.at(2).at(0) - matrix.at(0).at(0) * matrix.at(2).at(1)) * det_inv,
        (matrix.at(0).at(0) * matrix.at(1).at(1) - matrix.at(0).at(1) * matrix.at(1).at(0)) * det_inv
      )
    )
    inverse_matrix = inverse_matrix.map(it => it.map(c => calc.rem-euclid(c, 26)))
    
  }
  plaintext = plaintext + "Z" * calc.rem(n - calc.rem(plaintext.clusters().len(), n), n)
  let numbered_plaintext = string_A0Z25(plaintext)
  let numbered_ciphertext = ()
  for chunk in numbered_plaintext.chunks(n) {
    let vector = chunk
    // code matrix mult
    let result = ()
    for i in range(n) {
      let sum = 0
      for j in range(n) {
        sum += matrix.at(i).at(j) * vector.at(j)
      }
      numbered_ciphertext.push(calc.rem(sum, 26))
    }
  }
  let ciphertext = numbered_ciphertext.map(it => conv_A0Z25(it)).join("")
  box()[
    (#value points) #questiontext
    \
    #set text(font: "Fira Code", size: 14pt)
    #set align(center)

    #box(width: 100%, height:40%)[
      #set align(left)
      #set par(leading: 3em, spacing: 3em)
      
      #block(below: 2em)[=
        $ #math.mat(..key_matrix) equiv #math.mat(..matrix) #{
          if n == 3 [
            $ #h(1em) #math.mat(..matrix)^(-1) equiv #math.mat(..inverse_matrix) $
          ]
        }$
      ]
      #set text(font: ("Fira Code"), size: 15pt)


      #ciphertext
    ]
  ]
}


