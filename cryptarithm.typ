#import "utils.typ": *
#import "cryptarithm_solver.typ": *

#let cryptarithm(equation, mapping, value, answer, bonus: false, questiontext: none) = {
  // Parse equation
  equation = upper(equation).replace(regex("[^A-Za-z+\\-*/=]"), "")
  let matches = equation.match(regex("^[A-Z]+[+\\-*/][A-Z]+=[A-Z]+$"))
  if matches == none or matches.len() == 0 {
    return error("Invalid equation format. Equation must be in the form WORD1+WORD2=RESULT, WORD1-WORD2=RESULT, WORD1*WORD2=RESULT, or WORD1/WORD2=RESULT with only letters and operators.")
  }

  let (left_eq, right_eq) = equation.split("=")
  let op_match = left_eq.match(regex("[+\\-*/]"))
  if op_match == none or op_match.len() == 0 {
    return error("No operator found")
  }

  let operator = op_match.text
  let (word1, word2) = left_eq.split(operator)

  let solution = mapping
  if mapping == none or mapping == "" {
    let error_msg = none
    (solution, error_msg) = solve_cryptarithm(equation)
    if solution == none {
      return error(error_msg)
    }
  } else {
    if (word1 + word2 + right_eq).clusters().dedup().any(it => it not in mapping) {
      return error("Mapping does not cover all letters in the equation")
    } else {
      solution = solution.clusters().enumerate().map(it => (it.at(1), int(str(it.at(0))))).to-dict()
      let a = int(word1.clusters().map(it => str(solution.at(it))).join(""))
      let b = int(word2.clusters().map(it => str(solution.at(it))).join(""))
      let r = int(right_eq.clusters().map(it => str(solution.at(it))).join(""))
      let valid = false
      if operator == "+" {
        valid = (a + b == r)
      } else if operator == "-" {
        valid = (a - b == r)
      } else if operator == "*" {
        valid = (a * b == r)
      } else if operator == "/" {
        valid = (b != 0 and a / b == r)
      }
      if not valid {
        return error("Provided mapping does not satisfy the equation")
      }
    }
  }
  if answer.replace(" ", "") == "" {
    return error("Answer cannot be empty")
  }
  if not upper(answer).replace(" ", "").clusters().all(it => it in solution) {
    return error("Answer contains letters not in the solution")
  }
  if questiontext == none {
    questiontext = (
      "Solve this "
        + strong("cryptarithm")
        + ". What do the values "
        + strong(answer.clusters().map(it => if it != " " { str(solution.at(it)) }).join(""))
        + " decode to?"
    )
  }

  if bonus {
    questiontext += strong(" ★ This is a special bonus question.")
  }

  let display_equation(word1, word2, operator, result, ..intermediates) = {
    if operator != "/" {
      intermediates = intermediates.pos().enumerate().map(it => upper(it.at(1)) + " " * it.at(0))
      word2 = operator + " " + word2
      let max_width = (word1, word2, result, ..intermediates)
        .map(it => it.len())
        .reduce((acc, curr) => calc.max(acc, curr))
      return [
        #set text(font: "Fira Code", size: 15pt, tracking: 0.5em)
        #context {
          box(width: max_width * measure()[A].width.pt() * 1pt + (max_width - 1) * 0.5em)[
            #set align(right)
            #word1

            #word2
            #{
              if intermediates.len() > 0 {
                v(-1em)
                line(length: 100%)
                v(-1em)
                for inter in intermediates {
                  [  #inter

                  ]
                }
              }
            }
            #v(-1em)
            #line(length: 100%)
            #v(-1em)
            #result
          ]
        }
      ]
    } else {
      intermediates = intermediates.pos().map(it => " " * (word2.len() + it.at(0) - it.at(1).len() + 1) + upper(it.at(1)) + " " * (word1.len() - it.at(0) - 1))
      let columns = (word1 + word2).len()
      [
        #set text(font: "Fira Code", size: 15pt)
        #grid(columns: (auto,) * columns, align: horizon + right, inset: (left: 0.25em, right: 0.25em, top: 0.5em, bottom: 0.5em), 
        ..(" " * (columns - result.len()) + result).clusters(),
        ..word2.clusters(),
        grid.cell(word1.at(0), stroke: (left: black, top: black)),
        ..word1.slice(1).clusters().map(it => grid.cell(it, stroke: (top: black))),
        ..intermediates.at(0).clusters().map(it => {
          if it != " " {
            grid.cell(it, stroke: (bottom: black))
          } else {
            " "
          }
        }),
        ..intermediates.slice(1).chunks(2).map(it => {
          let start = -1
          let end = -1
          for (i, char) in it.at(0).clusters().enumerate() {
            if char != " " and start == -1{
              start = i
            }
          }
          let result = it.at(0).clusters()
          for (i, char) in it.at(1).clusters().enumerate() {
            if i == start or char != " "{
              result.push(grid.cell(char, stroke: (bottom: black)))
            } else {
              result.push(" ")
            }
          }
          return result          
        }).flatten(),
        ..(([],) * (columns - 1)), str(0)
        
        
        )
      ]
    }
  }

  let intermediates = ()
  let rev_solution = solution.pairs().map(it => (str(it.at(1)), it.at(0))).to-dict()
  if operator == "*" {
    let a = int(word1.clusters().map(it => str(solution.at(it))).join(""))
    let b = int(word2.clusters().map(it => str(solution.at(it))).join(""))
    let partials = ()
    for i in range(word2.len()) {
      let digit = int(str(b).at(str(b).len() - 1 - i))
      if a * digit != 0 {
        partials.push(str(a * digit).clusters().map(it => rev_solution.at(it)).join(""))
      } else {
        partials.push(rev_solution.at(str(digit)) * word1.len())
      }
    }
    intermediates = partials
  } else if operator == "/" {
    let curr = 0
    let dividend = int(word2.clusters().map(it => str(solution.at(it))).join(""))
    for (i, char) in word1.clusters().enumerate() {
      curr = curr * 10 + solution.at(char)
      if curr >= dividend {
        if (intermediates.len() > 0) {
          intermediates.push((i , str(curr).clusters().map(it => rev_solution.at(it)).join("")))
        }
        let digit = calc.quo(curr, dividend)
        intermediates.push((i, str(digit * dividend).clusters().map(it => rev_solution.at(it)).join("")))
        curr = curr - digit * dividend
      }
    }
  }

  box()[
    (#value points) #questiontext
    #set align(left)
    #display_equation(word1, word2, operator, right_eq, ..intermediates)
  ]
}
