# Design decisions

One entry per decision: what was decided, the paper reference, how it is
encoded, the rejected alternative, and why. Nothing in the library changes
shape without an entry here. Decisions marked "to confirm" are waiting for
the supervisor.

## D1. Base: CSLib on top of Mathlib

- **Decision:** depend on CSLib (leanprover/cslib), pinned to commit
  `cd48dc2a` of 2026-10-08. Mathlib comes in transitively through CSLib's
  own pin (v4.35.0-rc4), so it is not required separately.
- **Paper reference:** CSLib paper, arXiv:2602.04846.
- **Encoding:** `[[require]] name = "cslib"` with a git URL and a fixed
  `rev` in `lakefile.toml`; `lean-toolchain` copied from CSLib.
- **Rejected:** complexitylib as base. It already has FNP and TFNP over
  `List Bool` relations and a full machine model, but it is mainly one
  author and not community reviewed. It stays a reference for shapes.
  Also rejected: Mathlib only, which would mean writing a machine model.
- **Why:** CSLib has circuits, Turing machines and polynomial time
  (`Cslib.PolyTimeComputable`) and is reviewed and hosted by the Lean
  organisation. Contributing back is a possible end goal, which fixes
  conventions now: module system, copyright headers, namespace style.

## D2. Pure-Circuit is a constraint problem, not a CSLib circuit

- **Decision:** model a Pure-Circuit instance as a finite node set with gate
  constraints (NOR: two inputs, one output; PURIFY: one input, two outputs)
  where every node is the output of exactly one gate, and a solution as an
  assignment of `0`, `1` or `⊥` to nodes satisfying every gate's relation.
- **Paper reference:** Deligkas, Fearnley, Hollender, Melissourgos,
  Definition 1; Appendix A.1 for why the gate rules cannot be weakened.
- **Encoding:** to be written with the author (step 1). Open sub-choices
  are listed under "Open" below.
- **Rejected:** reusing `Cslib.Circuits.Circuit`. CSLib circuits are
  acyclic straight-line programs with a topological order, functional gate
  semantics and designated outputs. Pure-Circuit allows cycles, its gates
  are relations with free outputs on garbage, and PURIFY has two outputs.
  Forcing it into the circuit model would need either a cyclic variant of
  CSLib's `Program` or a relational interpretation, both further from the
  paper.
- **Why:** the project plan: the definition stands on its own and only needs basic
  maths. A definition that reads like Definition 1 is easier to check
  against the paper, which is the central deliverable.

## D3. All gates of Section 2.1 in one gate type; the gate set is a parameter of the instance

- **Decision:** `Gate n` has a constructor for each of the seven gates
  (COPY, NOT, OR, AND, NAND, NOR, PURIFY). `Instance S n` takes a gate set
  `S : Finset GateType` and requires every gate to have a type in `S`.
  Pure-Circuit as in Definition 1 is `S = {NOR, PURIFY}`; the choices of
  Corollary 2.2 are further values of `S`. Each gate set used in a statement
  is a named `Finset GateType`: `norPurify` for Definition 1; the sets of
  Corollary 2.2 are named together with their statements in step 5.
- **Paper reference:** Definition 1, Section 2.1 ("More gates"), Corollary 2.2
  ("for any of the following choices of gate types"), Corollary 2.3.
- **Encoding:** `GateType` is a label with one constructor per gate,
  `Gate.type` maps a gate to its label, and the instance field `allowed`
  (D10) restricts the gates. The gates are defined in step 1 together with
  Definition 1, so `TfnpLean/PureCircuit.lean` is frozen once; the
  reductions between the variants stay in step 5.
- **Rejected:** separate problem definitions per gate set (repeats the
  instance conditions for every variant, and the reductions of Corollary 2.2
  would map between unrelated types); an unrestricted `Instance n` with a
  separate predicate "uses only gates from `S`" (every later definition
  would have to remember it, against D10); the seven-gate instance as the
  main object (not what the paper calls Pure-Circuit; the main object is
  the instance over `{NOR, PURIFY}`); adding the gates in step 5 (the
  instance type changes, so the frozen file would have to be unfrozen);
  `S` written as a literal at each use (`{NOR, PURIFY}` and `{PURIFY, NOR}`
  are equal sets but not the same term, so the instance types would differ).
- **Why:** Corollary 2.2 treats the gate set as a parameter of one problem,
  and so does the encoding. The instance conditions are written once, and a
  reduction between variants maps `Instance S n` to `Instance S' m`. The
  must-fail tests stay sharp because every test fixes its gate set.

## D4. Lean module system and CSLib file conventions

- **Decision:** every file starts with the CSLib copyright header, `module`,
  and `public import` lines; module docstrings use CSLib's `/-! # ... -/`
  style with a References section.
- **Paper reference:** none; CSLib `CONTRIBUTING.md` and `AGENTS.md`.
- **Encoding:** header, `module`, `weak.linter.mathlibStandardSet = true`
  in `lakefile.toml`.
- **Rejected:** `allowNonModules = true` without `module` headers.
- **Why:** Mathlib and CSLib require the module system; adopting it now
  avoids a rewrite if the library is contributed.

## D5. Polynomial time comes from CSLib's single-tape machines

- **Decision:** "fast" in TFNP and in reductions means
  `Cslib.PolyTimeComputable` from
  `Cslib.Computability.Machines.Turing.SingleTape.Deterministic`.
- **Paper reference:** Megiddo and Papadimitriou 1991 (FP); CSLib's
  reference is Arora and Barak, Chapter 1.
- **Encoding:** step 3 wraps `PolyTimeComputable` for the encodings of
  instances and solutions; FP is defined on top of it since CSLib has no
  class FP.
- **Rejected:** an abstract "cost model" typeclass to be instantiated
  later, and complexitylib's `P`/`FP`.
- **Why:** build step 3 of the project plan; one concrete notion keeps statements honest.
  Risk: encodings of structured instances (gate lists, circuits) as tapes
  are machine work; the results band budgets for that.

## D6. Hardness is stated, not proved (proposed, to confirm)

- **Decision:** state PPAD-hardness of Pure-Circuit as a theorem next to
  membership, so that PPAD-completeness (Theorem 2.1) is fully stated. It
  stays unproven and is marked as such.
- **Paper reference:** Theorem 2.1; Section 3 for the StrongSperner proof.
- **Encoding:** a theorem with `sorry` in
  `TfnpLean.Results.PureCircuitPPADHard`, counted by the sorry census.
- **Rejected:** leaving hardness out of the library. The library's scope is
  model plus theorem statements; getting the hardness statement right
  (direction of the reduction, which class) is part of that work.
- **Why:** stating it checks that PPAD, reductions and Pure-Circuit fit
  together in the direction the paper uses. Proving it needs the
  StrongSperner construction, which is beyond the thesis.

## D7. Node values are a three-constructor inductive

- **Decision:** `PureCircuit.Value` with constructors `zero`, `one`, `bot`,
  and `Value.IsPure` for the paper's `x ∈ {0, 1}`.
- **Paper reference:** DFHM24, Definition 1 (`x : V → {0, 1, ⊥}`).
- **Encoding:** `inductive Value` deriving `DecidableEq`; the `Fintype`
  instance is written by hand because the `Fintype` deriving handler fails
  on the pinned toolchain.
- **Rejected:** `Option Bool` with `none` as `⊥`. It gives every instance for
  free, but it does not read like the paper, and Mathlib treats `none` as a
  bottom element (`WithBot`), suggesting an order that Definition 1 does not
  have.
- **Why:** the side-by-side check (CHECKING.md, step 1) compares clause by
  clause; `x u = .bot` maps to `x[u] = ⊥` without translation.

## D8. Nodes are `Fin n`, with `n` a parameter of the instance type

- **Decision:** the node set is `Fin n`; an instance has type `Instance S n`
  (gate set `S`, D3) and an assignment has type `Fin n → Value`.
- **Paper reference:** DFHM24, Definition 1 (`V = [n]`).
- **Encoding:** `Gate n` and `Instance S n` are indexed by `n : ℕ`. Lean counts
  from `0`, the paper from `1`; nodes are shifted by one.
- **Rejected:** any type `V` with `[Fintype V] [DecidableEq V]`. More general,
  but the paper fixes `[n]`, and encoding instances for polynomial time
  (step 3) needs a numbering of the nodes anyway.
- **Why:** literal match with the paper, and `decide` checks small instances
  directly. The search-problem step bundles the size as `Σ n, Instance S n`,
  with `S` fixed per problem.

## D9. A gate is an inductive with one constructor per type; an instance's gates are a `Finset`

- **Decision:** `Gate n` has constructors `nor (u v w)` and `purify (u v w)`
  for Definition 1, and `copy (u v)`, `not (u v)`, `or (u v w)`,
  `and (u v w)`, `nand (u v w)` for Section 2.1 (D3, D12); an instance holds
  `gates : Finset (Gate n)`.
- **Paper reference:** DFHM24, Definition 1 (`g = (T, u, v, w)`, "a set G of
  gate-constraints").
- **Encoding:** the type `T` is the constructor; the node names `u`, `v`, `w`
  and their roles (NOR: inputs `u`, `v`, output `w`; PURIFY: input `u`,
  outputs `v`, `w`) follow the paper. `Gate.outputs` lists the output nodes.
  `Gate.type : Gate n → GateType` labels a gate for gate sets (D3); the
  semantics still match on the gate itself. `GateType` repeats the seven
  names, but `Gate.type` is an exhaustive match, so a gate without a label
  does not compile.
- **Rejected:** a structure `(T, u, v, w)` with a `GateType` field
  (literal, but the semantics would match on a field instead of the gate,
  and COPY and NOT have only two nodes);
  role names `in₁ in₂ out` and `input out₁ out₂` (self-explaining, but the
  side-by-side would need a renaming); `List (Gate n)` (order and duplicates
  have no meaning in the paper).
- **Why:** usual Lean style for tagged data; a variant gate (Corollary 2.2)
  is one more constructor.

## D10. The instance conditions are proof fields of `Instance`

- **Decision:** `Instance S n` is a structure with `gates`, `allowed : ∀ g ∈
  gates, g.type ∈ S`, `distinct : ∀ g ∈ gates, g.Distinct` and
  `output_unique : OutputUnique gates`, where
  `OutputUnique G := ∀ i, ∃! g, g ∈ G ∧ i ∈ g.outputs`.
- **Paper reference:** DFHM24, Definition 1 ("u, v, w ∈ V are distinct
  nodes", "each node is the output of exactly one gate"); Remark 2 (allowing
  `u = v` changes the definition); Corollary 2.2 for the gate set.
- **Encoding:** `∃!` copies "exactly one". A `Decidable` instance proves it
  equivalent to "the number of gates with output `i` is 1", so `decide`
  checks instances. Distinctness is a predicate on gates, required by the
  instance, not built into `Gate`. The node variable is `i`, because `x`
  names the assignment throughout, as in the paper.
- **Rejected:** a separate `Instance.IsValid` predicate (every later
  definition would have to remember it); the count as the definition (one
  step away from the paper's wording); distinctness inside each gate
  constructor (every gate in a test would need a proof); dropping
  distinctness (Remark 2; and `PURIFY(u → v, v)` would force a pure output on
  garbage input, a stronger gate); a function from nodes to their defining
  gate (PURIFY defines two nodes, so the function needs its own consistency
  condition).
- **Why:** an invalid instance cannot be built. "At most one" is needed for
  totality: `Tests.doubleOutput`, where a node is the output of two gates,
  has no satisfying assignment. "Exactly one" is the shape the paper's
  reductions use: the GCircuit definition (Section 4.1) has the same
  condition, and the game reductions (Section 4.2) treat each node as a
  player governed by its one gate.

## D11. Gate semantics are the paper's implications, PURIFY unconditional

- **Decision:** `Gate.Satisfied g x` is the conjunction of the paper's
  clauses for the gate's type, written as in the paper's left column.
- **Paper reference:** DFHM24, Definition 1, gate constraints for NOR and
  PURIFY; Section 2.1 for COPY, NOT, OR, AND, NAND, which follow the same
  rule.
- **Encoding:** NOR: `x u = 0 ∧ x v = 0 → x w = 1` and `x u = 1 ∨ x v = 1 →
  x w = 0`. PURIFY: `(x v).IsPure ∨ (x w).IsPure` and `(x u).IsPure → x v =
  x u ∧ x w = x u`. Cases no implication names leave the output free.
- **Rejected:** the truth tables of the right column as a `match` (more
  cases, a forgotten row goes unnoticed); PURIFY's first clause guarded by
  `x u = ⊥` (equivalent, proved in the tests, but not the paper's wording).
- **Why:** one Lean clause per paper clause for the side-by-side check. The
  must-fail tests MF1 and MF2 fail when either of the two relaxations of
  Appendix A.1 is applied to these definitions.

## D12. COPY and NOT are gates on two nodes

- **Decision:** `copy (u v)` and `not (u v)` with input `u` and output `v`;
  `outputs` is `{v}` and `Distinct` is `u ≠ v`.
- **Paper reference:** DFHM24, Section 2.1 (`g = (T, u, v)` for COPY and
  NOT); Remark 2.
- **Encoding:** two constructor arguments instead of three, the node names
  as in the paper.
- **Rejected:** three nodes with an unused `w` (not in the paper, and `w`
  would need a dummy node that is the output of no gate); NOT as
  `NOR(u, u → v)` (Remark 2: repeated inputs change the definition, and D10
  requires distinct nodes).
- **Why:** literal match with the paper's `(T, u, v)`. Requiring `u ≠ v`
  keeps the rule that a gate never reads its own output.

## Open

- Namespace: `TfnpLean` for now; a CSLib contribution would use `Cslib`.
- Fixed-point theorem for Pure-Circuit in PPAD: in scope or a marked
  assumption.
- Validation: an existing problem counts as validated when it can be
  written down with the definitions, or only when it is proven to be in the
  class (`Validation/SparseWinLose.lean`).
- Cake cutting is studied in a query model; how it fits a library of
  input-based search problems (`Validation/CakeCutting.lean`).
