#let error(message) = {
  box(width: 100%, height: 10em, fill: red.transparentize(50%), stroke: red, radius: 5pt)[
    #set text(font: "Fira Code", size: 15pt, fill: red.darken(20%))
    #set align(horizon + center)
    *Error!*\
    #message
  ]
}