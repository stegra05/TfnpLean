import TfnpLean
import Lean

/-!
# Axiom audit

Fails if any declaration defined in a `TfnpLean.*` module depends on an axiom
other than `propext`, `Classical.choice` and `Quot.sound`. `sorryAx` counts as
a non-standard axiom, so a `sorry` in a definition fails here while a `sorry`
in a theorem is reported by the sorry census instead.

Run with `lake env lean scripts/AxiomAudit.lean`.
-/

open Lean Elab Command

run_cmd do
  let env ← getEnv
  let allowed : Array Name := #[``propext, ``Classical.choice, ``Quot.sound]
  let mut checked : Nat := 0
  let mut bad : Array String := #[]
  for (c, _) in env.constants.map₁.toList do
    if c.isInternal then continue
    let some idx := env.getModuleIdxFor? c | continue
    let modName := env.header.moduleNames[idx.toNat]!
    unless (`TfnpLean).isPrefixOf modName do continue
    checked := checked + 1
    let axioms ← liftCoreM (collectAxioms c)
    let extra := axioms.filter (fun a => !allowed.contains a)
    if !extra.isEmpty then bad := bad.push s!"{c}: {extra}"
  logInfo m!"axiom audit: {checked} declarations checked"
  unless bad.isEmpty do
    throwError m!"declarations with non-standard axioms:\n{"\n".intercalate bad.toList}"
