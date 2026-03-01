#import "baconian.typ": *
#import "hill.typ": *
#import "frac_morse.typ": *
#import "utils.typ": *
#import "substitution.typ": *
#import "cryptarithm.typ": *
#import "porta.typ": *
#import "@preview/suiji:0.5.1": *
#import "nihilist.typ": *
#import "columnar.typ": *
#import "checkboard.typ": *


#let min_height(h, body) = layout(
  available => {
    let size = measure(body, ..available)
    let args = if size.height < h * available.height { (height: h) } else { (height: size.height + 5%) }
    box(..args, body)
  },
)

#let blank_page() = box(height: 100%)[
  #line(length: 100%)
  #set align(horizon + center)
  This page is intentionally left blank. You may use this page as scratch paper if you wish.
]

#let generate(file, title, div, image_file, date, authors, shuffle: false) = [#{
  [
    #set align(center)
    #set text(size: 20pt)
    = Codebusters #upper(div)
    == #title
    === #date.display("[day padding:none] [month repr:long] [year]")
    #{
      if image_file != none {
        image(image_file, width: 50%)
      }
    }
    #set align(left)
    #set text(size: 12pt)
    - You will have 50 minutes for this event
    - Only writing utensils, a four or five function calculator, and your brain are allowed.
    - You may use the space on the exam as scratch paper, but please make sure that your answers are clear. Either write your answers separately and #box()[#rect("box", inset: (right: 0.5em, left: 0.5em, top: 0em, bottom: 0em), outset: (top: 0.2em, bottom: 0.2em, right: -0.1em, left: -0.1em))] them, or write them directly over/under the ciphertext.
    - You may take apart the test as you wish; please staple the test back together *in order* as you hand it in at the end.
    - The first question is the *timed question*. If you solve the timed question in the first 10 minutes within two errors, you will receive a timed bonus. Raise your hand if you are done with the timed question and a volunteer will come over to check your answer and, if correct, record your time.
    - If you do not solve the timed question within 10 minutes, you may still solve the question and receive points for it. You will just not receive any bonus points.
    - Pages 3 and 4 of the exam are reference material. Page 5 is for scoring. *Do not write anything on the scoring page* besides your team number!
    - If possible, please write your team number on each page (top right).
    #box(grid(
      columns: 2,
      rows: (1em,),
      [Team Name:], grid.cell(stroke: (bottom: black))[#h(80%)],
      gutter: 0.2em,
      align: horizon + center,
    ))
    #v(1.5em)
    #box(grid(
      columns: 2,
      rows: (1em,),
      [Team Number:], grid.cell(stroke: (bottom: black))[#h(10%)],
      gutter: 0.2em,
      align: horizon + center,
    ))
    #set align(center)
    *Written By:*
    #v(-0.8em)
    #line(length: 30%)
    #for author in authors {
      author
      v(-0.5em)
    }

  ]
  set page(
    header: [
      *Codebusters* #strong(upper(div)) - #strong(title)
      #h(1fr)
      #strong("Team # _____")
      #v(-0.5em)
    ],
    margin: (right: 10%, left: 10%, top: 5%),
  )
  blank_page()
  let rng = gen-rng-f(42)
  let disp = ""
  let data = csv(file, row-type: dictionary)
  if shuffle {
    let (rng, shuffled_data) = shuffle-f(rng, data.slice(1))
    data = (data.at(0),) + shuffled_data
  }
  [
    #line(length: 100%)
    = Scoring Table
    == Exam Score
    #{
      let non_timed = data.len() - 1 + 1
      let rows = calc.ceil(non_timed / 3) + 1
      let total_points = data.slice(1).map(it => int(it.at("Value"))).reduce((acc, curr) => acc + curr)
      grid(
        columns: (1fr,) * 3,
        table(
          columns: 3,
          rows: rows,
          align: horizon + center,
          table.header([Question], [Points], [Score]),
          ..range(1, rows)
            .map(it => {
              let bonus = if data.at(it).at("Bonus") == "TRUE" { sym.star.filled } else { "" }
              ([#bonus#it], [#data.at(it).at("Value")], [])
            })
            .flatten(),
        ),
        table(
          columns: 3,
          rows: rows,
          align: horizon + center,
          table.header([Question], [Points], [Score]),
          ..range(rows, 2 * rows - 1)
            .map(it => {
              let bonus = if data.at(it).at("Bonus") == "TRUE" { sym.star.filled } else { "" }
              ([#bonus#it], [#data.at(it).at("Value")], [])
            })
            .flatten(),
        ),
        table(
          columns: 3,
          rows: rows,
          align: horizon + center,
          table.header([Question], [Points], [Score]),
          ..range(2 * rows + 1, 3 * rows)
            .map(it => {
              if it < data.len() {
                let bonus = if data.at(it).at("Bonus") == "TRUE" { sym.star.filled } else { "" }
                return ([#bonus#it], [#data.at(it).at("Value")], [])
              } else if it < 3 * rows - 1 {
                return ([#sym.zws], [], [])
              } else {
                return ([Total], [#total_points], [])
              }
            })
            .flatten(),
        ),
      )
    }
    == Timed Question
    #set par(leading: 2em)
    #set text(size: 12pt)
    Question Score: #h(2em) 0 #h(1em) #data.at(0).at("Value") #h(1em) (Circle one) \
    #box(grid(
      columns: 2,
      rows: (1em, auto),
      [Time:], grid.cell(stroke: (bottom: black))[#h(6em)],
      column-gutter: 0.2em,
      [],
      [
        #set text(size: 6pt)
        minutes : seconds
      ],
      align: horizon + center,
      row-gutter: 0.2em,
    ))
    \
    #box(grid(
      columns: 4,
      rows: (1em, auto),
      [Timed Bonus: $(600-$], grid.cell(stroke: (bottom: black))[#h(6em)],
      column-gutter: 0.2em,
      [$) times 2=$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [],
      [
        #set text(size: 6pt)
        time in seconds
      ],
      [],
      [
        #set text(size: 6pt)
        timed bonus
      ],
      align: horizon + center,
      row-gutter: 0.2em,
    ))
    \
    #box(grid(
      columns: 6,
      rows: (1em, auto),
      [Total TQ Score: ], grid.cell(stroke: (bottom: black))[#h(6em)],
      column-gutter: 0.2em,
      [$+$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [$=$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [],
      [
        #set text(size: 6pt)
        question score
      ],
      [],
      [
        #set text(size: 6pt)
        timed bonus
      ],
      [],
      [
        #set text(size: 6pt)
        total TQ score
      ],
      align: horizon + center,
      row-gutter: 0.2em,
    ))
    == Special Bonus
    #set par(leading: 1em)
    Circle one. Special bonus is only awarded for solving the question for full score. Special bonus questions: #data.enumerate().filter(it => it.at(1).at("Bonus") == "TRUE").map(it => str(it.at(0))).join(", ")
    #table(
      columns: (1fr,) * 5,
      align: horizon + center,
      "Correct", "0", "1", "2", "3",
      "Points", "0 points", "150 points", "400 points", "700 points",
    )
    == Total Score
    #box(grid(
      columns: 8,
      rows: (1em, auto),
      [Final Score: ], grid.cell(stroke: (bottom: black))[#h(6em)],
      column-gutter: 0.2em,
      [$+$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [$+$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [$=$],
      grid.cell(stroke: (bottom: black))[#h(6em)],
      [],
      [
        #set text(size: 6pt)
        Exam Score Total
      ],
      [],
      [
        #set text(size: 6pt)
        TQ Total
      ],
      [],
      [
        #set text(size: 6pt)
        Special Bonus
      ],
      align: horizon + center,
      row-gutter: 0.2em,
    ))
    \
    #box(grid(
      columns: 2,
      rows: (1em,),
      [Rank:], grid.cell(stroke: (bottom: black))[#h(2em)],
      gutter: 0.2em,
      align: horizon + center,
    ))
    #v(100%)
  ]
  blank_page()
  set page(
    footer: context [
      #line(length: 100%)

      #h(1fr)
      *Page* #strong(counter(page).display("1 of 1", both: true))
    ],
  )
  counter(page).update(1)
  for (index, question) in data.enumerate() {
    box()[
      #line(length: 100%)
      #{
        if question.at("#") == "T" {
          let (rng, disp) = aristocrat(
            rng,
            question.at("Plaintext"),
            question.at("Type"),
            question.at("Value"),
            key: question.at("Key1"),
            k: question.at("Key3"),
            shift: question.at("Key2"),
            timed: true,
          )
          min_height(40%)[#disp]
          v(100%)
        } else if question.at("Cipher") == "ARISTOCRAT" {
          let (rng, disp) = aristocrat(
            rng,
            question.at("Plaintext"),
            question.at("Type"),
            question.at("Value"),
            key: question.at("Key1"),
            k: question.at("Key3"),
            shift: question.at("Key2"),
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "PORTA" {
          disp = porta(
            question.at("Plaintext"),
            question.at("Key1"),
            question.at("Value"),
            question.at("Type"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "COLUMNAR" {
          let (rng, disp) = columnar(
            rng,
            question.at("Plaintext"),
            int(question.at("Key1")),
            question.at("Key2"),
            question.at("Value"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "NIHILIST" {
          let disp = nihilist(
            question.at("Plaintext"),
            question.at("Key1"),
            question.at("Key2"),
            question.at("Value"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "CHECKERBOARD" {
          let (rng, disp) = checkerboard(
            question.at("Plaintext"),
            question.at("Key1"),
            question.at("Key2"),
            question.at("Key3"),
            question.at("Value"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "CRYPTARITHM" {
          let disp = cryptarithm(
            question.at("Plaintext"),
            question.at("Key1", default: none),
            question.at("Value"),
            question.at("Key2", default: none),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "HILL" {
          let disp = hill(
            question.at("Plaintext"),
            question.at("Type"),
            question.at("Value"),
            question.at("Key1"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "FRACMORSE" {
          let disp = frac_morse(
            question.at("Plaintext"),
            question.at("Key1"),
            question.at("Key2"),
            question.at("Value"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "BACONIAN" {
          let (rng, disp) = baconian(
            rng,
            question.at("Plaintext"),
            question.at("Type"),
            question.at("Value"),
            a: question.at("Key1"),
            b: question.at("Key2"),
            amount: question.at("Key1"),
            crib: question.at("Key2"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "COLUMNAR" {
          let (rng, disp) = columnar(
            rng,
            question.at("Plaintext"),
            int(question.at("Key1")),
            question.at("Key2"),
            question.at("Value"),
            bonus: question.at("Bonus") == "TRUE",
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "XENOCRYPT" {
          let (rng, disp) = xenocrypt(
            rng,
            question.at("Plaintext"),
            question.at("Type"),
            key: question.at("Key1"),
            question.at("Value"),
            questiontext: question.at("Question Text", default: none),
            shift: question.at("Key2"),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "PATRISTOCRAT" {
          let (rng, disp) = patristocrat(
            rng,
            question.at("Plaintext"),
            question.at("Type"),
            question.at("Value"),
            key: question.at("Key1"),
            shift: question.at("Key2"),
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "AFFINE" {
          let disp = affine(
            question.at("Plaintext"),
            question.at("Value"),
            question.at("Key1"),
            question.at("Key2"),
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "ATBASH" {
          let disp = atbash(
            question.at("Plaintext"),
            question.at("Value"),
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else if question.at("Cipher") == "CAESAR" {
          let disp = caesar(
            question.at("Plaintext"),
            question.at("Value"),
            question.at("Key1"),
            questiontext: question.at("Question Text", default: none),
          )
          list(min_height(40%)[#disp], marker: strong(str(index) + "."))
        } else {
          list(min_height(40%)[#error("Unknown cipher type: " + question.at("Cipher"))], marker: strong(
            str(index) + ".",
          ))
        }
      }
    ]
  }
}]


#generate(
  "2026 Regionals ATX Codebusters B_C - Master Sheet - Invi Questions.csv",
  "UT Invitational",
  "B",
  "coverart.png",
  datetime(year: 2024, month: 10, day: 26),
  ("Klebb Chiang (UIUC '25)", "Rhea Shah (UT '26)",),
  shuffle: true,
)
