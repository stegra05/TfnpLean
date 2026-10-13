import Mathlib.Data.Fintype.Basic

/-! A simple test file for Lean -/

def price (items : ℕ) : ℕ := 2 * items + 1

#check price
#eval price 3

def bill (perItem items : ℕ) : ℕ := perItem * items

#check bill
#check @bill
#check bill 3
#eval bill 3 4

def firstOr {α : Type} (fallback : α) : List α → α
  | [] => fallback
  | x :: _ => x

#check @firstOr
#eval firstOr "nobody" []
#eval firstOr 0 [5, 7, 8]
