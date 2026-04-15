#let solve_cryptarithm(equation) = {
  // Parse equation
  equation = upper(equation).replace(regex("[^A-Za-z+\\-*/=]"), "")
  let matches = equation.match(regex("^[A-Z]+[+\\-*/][A-Z]+=[A-Z]+$"))
  if matches == none or matches.len() == 0 {
    return (none, "Invalid equation format")
  }

  let (left, right) = equation.split("=")
  let op_match = left.match(regex("[+\\-*/]"))
  if op_match == none or op_match.len() == 0 {
    return (none, "No operator found")
  }

  let operator = op_match.text
  let (word1, word2) = left.split(operator)

  // Rearrange for faster solving: A-B=C → B+C=A, A/B=C → B*C=A
  if operator == "-" {
    (word1, word2, right, operator) = (word2, right, word1, "+")
  } else if operator == "/" {
    (word1, word2, right, operator) = (word2, right, word1, "*")
  }

  // Validate equation structure
  if operator == "+" {
    let max_len = calc.max(word1.len(), word2.len())
    if right.len() < max_len or right.len() > max_len + 1 {
      return (none, "Invalid addition dimensions")
    }
  } else if operator == "*" {
    let exp_min = word1.len() + word2.len() - 1
    let exp_max = word1.len() + word2.len()
    if right.len() < exp_min or right.len() > exp_max {
      return (none, "Invalid multiplication dimensions")
    }
  }

  // Extract unique letters with smart ordering
  let all_chars = (word1 + word2 + right).clusters()
  let letters = all_chars.dedup()

  // OPTIMIZE: Reorder letters - solve operand letters first, especially first letters
  let ordered_letters = ()

  // First: operand first letters
  if word1.len() > 0 and word1.at(0) not in ordered_letters {
    ordered_letters.push(word1.at(0))
  }
  if word2.len() > 0 and word2.at(0) not in ordered_letters {
    ordered_letters.push(word2.at(0))
  }

  // Second: all other operand letters
  for ch in word1.clusters() {
    if ch not in ordered_letters {
      ordered_letters.push(ch)
    }
  }
  for ch in word2.clusters() {
    if ch not in ordered_letters {
      ordered_letters.push(ch)
    }
  }

  // Third: result letters
  for ch in right.clusters() {
    if ch not in ordered_letters {
      ordered_letters.push(ch)
    }
  }

  let letters = ordered_letters

  if letters.len() > 10 {
    return (none, "Too many unique letters")
  }

  // Cache word lengths for performance
  let w1_len = word1.len()
  let w2_len = word2.len()
  let r_len = right.len()

  // Cache word clusters
  let w1_chars = word1.clusters()
  let w2_chars = word2.clusters()
  let r_chars = right.clusters()

  // Identify first letters (can't be 0)
  let first_letters = ()
  if w1_len > 0 { first_letters.push(word1.at(0)) }
  if w2_len > 0 { first_letters.push(word2.at(0)) }
  if r_len > 0 { first_letters.push(right.at(0)) }
  first_letters = first_letters.dedup()

  // Helper: Convert word to number
  let word_to_num(word, mapping) = {
    let result = 0
    for ch in word.clusters() {
      let digit = mapping.at(ch, default: none)
      if digit == none { return none }
      result = result * 10 + digit
    }
    result
  }

  // Helper: Check if equation is satisfied
  let check_full(mapping, op) = {
    let v1 = word_to_num(word1, mapping)
    let v2 = word_to_num(word2, mapping)
    let vr = word_to_num(right, mapping)

    if v1 == none or v2 == none or vr == none { return false }

    if op == "+" { return v1 + v2 == vr } else if op == "*" { return v1 * v2 == vr } else { return false }
  }

  // Helper: Validate partial assignment for addition
  let validate_addition(mapping) = {
    let max_len = calc.max(word1.len(), word2.len(), right.len())

    // Track used digits from current mapping
    let used_digits = ()
    for (ch, d) in mapping.pairs() {
      used_digits.push(d)
    }

    let get_digit_options(letter, is_leading) = {
      if letter == none { return (0,) }
      if letter in mapping {
        let d = mapping.at(letter)
        if is_leading and d == 0 { return () }
        return (d,)
      }

      let digits = ()
      for d in range(10) {
        if used_digits.contains(d) { continue }
        if is_leading and d == 0 { continue }
        digits.push(d)
      }
      digits
    }

    let possible_carries = (0,)

    for i in range(max_len) {
      let i1 = word1.len() - 1 - i
      let i2 = word2.len() - 1 - i
      let i3 = right.len() - 1 - i

      let ch1 = if i1 >= 0 { word1.at(i1) } else { none }
      let ch2 = if i2 >= 0 { word2.at(i2) } else { none }
      let ch3 = if i3 >= 0 { right.at(i3) } else { none }

      let is_leading1 = i1 == 0
      let is_leading2 = i2 == 0
      let is_leading3 = i3 == 0

      let opts1 = get_digit_options(ch1, is_leading1)
      let opts2 = get_digit_options(ch2, is_leading2)
      let opts3 = get_digit_options(ch3, is_leading3)

      if opts1.len() == 0 or opts2.len() == 0 or opts3.len() == 0 {
        return false
      }

      let next_carries = ()

      for carry in possible_carries {
        for d1 in opts1 {
          for d2 in opts2 {
            // If both positions have the same letter (not none), digits must match
            if ch1 != none and ch2 != none and ch1 == ch2 and d1 != d2 { continue }
            // If different letters, digits must be different
            if ch1 != none and ch2 != none and ch1 != ch2 and d1 == d2 { continue }

            let sum = d1 + d2 + carry
            let digit = calc.rem(sum, 10)
            let carry_out = calc.quo(sum, 10)

            if not opts3.contains(digit) { continue }

            // Check ch3 consistency with ch1 and ch2
            if ch3 != none and ch1 != none and ch3 == ch1 and digit != d1 { continue }
            if ch3 != none and ch2 != none and ch3 == ch2 and digit != d2 { continue }
            if ch3 != none and ch1 != none and ch3 != ch1 and digit == d1 { continue }
            if ch3 != none and ch2 != none and ch3 != ch2 and digit == d2 { continue }

            if not next_carries.contains(carry_out) {
              next_carries.push(carry_out)
            }
          }
        }
      }

      if next_carries.len() == 0 { return false }
      possible_carries = next_carries
    }

    possible_carries.contains(0)
  }

  // Helper: Get min/max value for partially assigned word
  let get_bounds(word, mapping) = {
    let min_val = 0
    let max_val = 0
    let fully_assigned = true

    for i in range(word.len()) {
      let ch = word.at(i)
      min_val = min_val * 10
      max_val = max_val * 10

      if ch in mapping {
        let d = mapping.at(ch)
        min_val = min_val + d
        max_val = max_val + d
      } else {
        fully_assigned = false
        // First letter can't be 0
        if i == 0 and word.len() > 1 {
          min_val = min_val + 1
          max_val = max_val + 9
        } else {
          // min is 0 (already added), max is 9
          max_val = max_val + 9
        }
      }
    }

    (min: min_val, max: max_val, complete: fully_assigned)
  }

  // Helper: Validate partial assignment for multiplication (OPTIMIZED)
  let validate_multiplication(mapping) = {
    // Check no leading zeros first (fastest check)
    if word1.len() > 0 and word1.at(0) in mapping and mapping.at(word1.at(0)) == 0 { return false }
    if word2.len() > 0 and word2.at(0) in mapping and mapping.at(word2.at(0)) == 0 { return false }
    if right.len() > 0 and right.at(0) in mapping and mapping.at(right.at(0)) == 0 { return false }

    let v1 = word_to_num(word1, mapping)
    let v2 = word_to_num(word2, mapping)
    let vr = word_to_num(right, mapping)

    // If all complete, check exact equality
    if v1 != none and v2 != none and vr != none { return v1 * v2 == vr }

    // If both operands complete, validate against result
    if v1 != none and v2 != none {
      let prod = v1 * v2
      let prod_str = str(prod)
      if prod_str.len() != right.len() { return false }

      // Build reverse mapping for duplicate detection
      let used_digits = (:)
      for (ch, d) in mapping.pairs() {
        used_digits.insert(str(d), ch)
      }

      for i in range(right.len()) {
        let ch = right.at(i)
        let expected = int(prod_str.at(i))

        if ch in mapping {
          if mapping.at(ch) != expected { return false }
        } else {
          // Check no other letter already uses this digit
          if str(expected) in used_digits { return false }
        }
      }
      return true
    }

    // OPTIMIZATION: Range-based pruning
    let b1 = get_bounds(word1, mapping)
    let b2 = get_bounds(word2, mapping)
    let br = get_bounds(right, mapping)

    // Check if any possible product can match result range
    let min_prod = b1.min * b2.min
    let max_prod = b1.max * b2.max

    if max_prod < br.min or min_prod > br.max { return false }

    // OPTIMIZATION: Check units digit constraint with all partial products
    // For A*B=C, check: (A%10)*(B%10)%10 == C%10
    let get_last_digit(word, mapping) = {
      if word.len() == 0 { return none }
      let ch = word.at(word.len() - 1)
      if ch in mapping { return mapping.at(ch) } else { return none }
    }

    let d1_last = get_last_digit(word1, mapping)
    let d2_last = get_last_digit(word2, mapping)
    let dr_last = get_last_digit(right, mapping)

    if d1_last != none and d2_last != none and dr_last != none {
      if calc.rem(d1_last * d2_last, 10) != dr_last { return false }
    }

    // OPTIMIZATION: Partial product validation when one operand is complete
    if v1 != none and vr != none {
      // Check if result is divisible by v1 and quotient is in valid range
      if v1 != 0 {
        if calc.rem(vr, v1) != 0 { return false }
        let quotient = calc.quo(vr, v1)
        if quotient < b2.min or quotient > b2.max { return false }

        // If v2 partially assigned, check consistency
        let quotient_str = str(quotient)
        if quotient_str.len() != word2.len() { return false }

        for i in range(word2.len()) {
          let ch = word2.at(i)
          if ch in mapping {
            if mapping.at(ch) != int(quotient_str.at(i)) { return false }
          }
        }
      }
    }

    if v2 != none and vr != none {
      // Check if result is divisible by v2 and quotient is in valid range
      if v2 != 0 {
        if calc.rem(vr, v2) != 0 { return false }
        let quotient = calc.quo(vr, v2)
        if quotient < b1.min or quotient > b1.max { return false }

        // If v1 partially assigned, check consistency
        let quotient_str = str(quotient)
        if quotient_str.len() != word1.len() { return false }

        for i in range(word1.len()) {
          let ch = word1.at(i)
          if ch in mapping {
            if mapping.at(ch) != int(quotient_str.at(i)) { return false }
          }
        }
      }
    }

    // OPTIMIZATION: Check digit length constraint early
    // Product of n-digit and m-digit numbers is (n+m-1) or (n+m) digits
    if b1.complete and b2.complete {
      // Already handled above
    } else {
      // Check minimum digits: if both are at minimum with first digit 1, is it enough?
      let min_digits = word1.len() + word2.len() - 1
      let max_digits = word1.len() + word2.len()
      if right.len() < min_digits or right.len() > max_digits { return false }
    }

    true
  }

  // Validate constraint for current operator
  let is_valid(mapping) = {
    if operator == "+" { return validate_addition(mapping) } else if operator == "*" {
      return validate_multiplication(mapping)
    } else { return true }
  }

  // Main backtracking solver
  let backtrack(remaining, mapping, used, solutions) = {
    // Optimization: stop if we found 2+ solutions
    if solutions.len() >= 2 {
      return solutions
    }

    // Base case: all letters assigned
    if remaining.len() == 0 {
      if check_full(mapping, operator) {
        solutions.push(mapping)
      }
      return solutions
    }

    // OPTIMIZATION: Early deterministic assignment for multiplication
    if operator == "*" {
      let v1 = word_to_num(word1, mapping)
      let v2 = word_to_num(word2, mapping)

      if v1 != none and v2 != none {
        // Both operands known - compute product and validate result
        let prod = v1 * v2
        let prod_str = str(prod)

        if prod_str.len() != r_len {
          return solutions
        }

        // Deterministically assign result digits
        let new_mapping = mapping
        let new_used = used
        let valid = true

        for i in range(r_len) {
          let ch = right.at(i)
          let digit = int(prod_str.at(i))

          if ch in new_mapping {
            if new_mapping.at(ch) != digit {
              return solutions // Contradiction
            }
          } else {
            // Check digit not used by another letter
            if new_used.at(digit) {
              valid = false
              break
            }

            // Add assignment
            let updated_mapping = (:)
            for (k, v) in new_mapping.pairs() {
              updated_mapping.insert(k, v)
            }
            updated_mapping.insert(ch, digit)
            new_mapping = updated_mapping

            let updated_used = ()
            for j in range(10) {
              updated_used.push(new_used.at(j))
            }
            updated_used.at(digit) = true
            new_used = updated_used
          }
        }

        if not valid {
          return solutions
        }

        // Remove result letters from remaining
        let new_remaining = ()
        for ch in remaining {
          if ch not in new_mapping or (ch in mapping) {
            if ch not in new_mapping { new_remaining.push(ch) }
          }
        }

        if new_remaining.len() == 0 {
          if check_full(new_mapping, operator) {
            solutions.push(new_mapping)
          }
          return solutions
        }

        return backtrack(new_remaining, new_mapping, new_used, solutions)
      }
    }

    // OPTIMIZATION: MRV heuristic with better tie-breaking
    // Choose letter with fewest available digits, prefer operand letters
    let best_letter = none
    let best_idx = 0
    let min_count = 11

    for i in range(remaining.len()) {
      let letter = remaining.at(i)
      let cannot_be_zero = letter in first_letters

      // Count available digits
      let count = 0
      for j in range(10) {
        if not used.at(j) and (j > 0 or not cannot_be_zero) {
          count = count + 1
        }
      }

      if count == 0 { return solutions }

      // Prefer letters with fewer choices, break ties with position priority
      let is_in_operand = (
        w1_chars.contains(letter) or w2_chars.contains(letter)
      )

      // Adjust count for better selection (operands first)
      let adjusted_count = if is_in_operand { count } else { count + 0.5 }

      if adjusted_count < min_count {
        min_count = adjusted_count
        best_letter = letter
        best_idx = i
      }
    }

    let letter = best_letter
    let cannot_be_zero = letter in first_letters

    let new_remaining = ()
    for i in range(remaining.len()) {
      if i != best_idx { new_remaining.push(remaining.at(i)) }
    }

    // OPTIMIZATION: Smart digit ordering for multiplication
    let digit_order = (5, 3, 7, 2, 8, 4, 6, 1, 9, 0)

    // For multiplication, if assigning last digit of operand, prioritize by units constraint
    if operator == "*" {
      let is_last_of_operand = (
        (word1.len() > 0 and letter == word1.at(word1.len() - 1))
          or (word2.len() > 0 and letter == word2.at(word2.len() - 1))
      )

      if is_last_of_operand {
        // Get other operand's last digit if known
        let w1_last = if word1.len() > 0 { word1.at(word1.len() - 1) } else { none }
        let w2_last = if word2.len() > 0 { word2.at(word2.len() - 1) } else { none }
        let r_last = if right.len() > 0 { right.at(right.len() - 1) } else { none }

        let other_last = none
        if letter == w1_last and w2_last != none and w2_last in mapping {
          other_last = mapping.at(w2_last)
        } else if letter == w2_last and w1_last != none and w1_last in mapping {
          other_last = mapping.at(w1_last)
        }

        // If we know result's last digit and other operand's last, prioritize digits that work
        if r_last != none and r_last in mapping and other_last != none {
          let target = mapping.at(r_last)
          let priority = ()
          let others = ()

          for d in range(10) {
            if calc.rem(d * other_last, 10) == target {
              priority.push(d)
            } else {
              others.push(d)
            }
          }

          digit_order = priority + others
        }
      }

      // For first digits in multiplication, avoid small values
      if letter in first_letters {
        digit_order = (9, 8, 7, 6, 5, 4, 3, 2, 1)
      }
    }

    let start = if cannot_be_zero { 1 } else { 0 }

    for digit in digit_order {
      if digit < start { continue }
      if used.at(digit) { continue }

      // Stop if we found 2+ solutions
      if solutions.len() >= 2 {
        return solutions
      }

      let new_mapping = (:)
      for (k, v) in mapping.pairs() {
        new_mapping.insert(k, v)
      }
      new_mapping.insert(letter, digit)

      let new_used = ()
      for j in range(10) {
        new_used.push(used.at(j))
      }
      new_used.at(digit) = true

      if is_valid(new_mapping) {
        solutions = backtrack(new_remaining, new_mapping, new_used, solutions)
      }
    }

    return solutions
  }

  let results = backtrack(letters, (:), (false,) * 10, ())

  if results.len() == 0 {
    return (none, "No solution found")
  } else if results.len() > 1 {
    return (none, "Multiple solutions found")
  } else {
    return (results.at(0), none)
  }
}
