# Design decisions

One entry per decision: the question, the decision (or OPEN), the paper
reference, how it is encoded, the rejected options, why, and the date.
Nothing in the library changes shape without an entry here. Decisions
marked "open", "proposed" or "to confirm" are waiting for the supervisor.
A revised decision keeps its number and records what it replaced.

## D1. Base: CSLib on top of Mathlib

- **Question:** Which library does TfnpLean build on?
- **Date:** 2026-10-08
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
  (`Cslib.Turing.SingleTapeTM.PolyTimeComputable`) and is reviewed and hosted by the Lean
  organisation. Contributing back is a possible end goal, which fixes
  conventions now: module system, copyright headers, namespace style.

## D2. Pure-Circuit is a constraint problem, not a CSLib circuit

- **Question:** Is a Pure-Circuit instance a CSLib circuit?
- **Date:** 2026-10-08
- **Decision:** model a Pure-Circuit instance as a finite node set with gate
  constraints (NOR: two inputs, one output; PURIFY: one input, two outputs)
  where every node is the output of exactly one gate, and a solution as an
  assignment of `0`, `1` or `⊥` to nodes satisfying every gate's relation.
- **Paper reference:** Deligkas, Fearnley, Hollender, Melissourgos,
  Definition 1; Appendix A.1 for why the gate rules cannot be weakened.
- **Encoding:** D7 to D12. Whether End-of-Line and Localopt share this
  core is D13.
- **Rejected:** reusing `Cslib.Circuits.Circuit`. CSLib circuits are
  acyclic straight-line programs with a topological order, functional gate
  semantics and designated outputs. Pure-Circuit allows cycles, its gates
  are relations with free outputs on garbage, and PURIFY has two outputs.
  Forcing it into the circuit model would need either a cyclic variant of
  CSLib's `Program` or a relational interpretation, both further from the
  paper.
- **Why:** the definition stands on its own and only needs basic maths. A definition that reads like Definition 1 is easier to check
  against the paper, which is the central deliverable.

## D3. All gates of Section 2.1 in one gate type; the gate set is a parameter of the instance

- **Question:** How are the gates of Section 2.1 and the gate sets of Corollary 2.2 represented?
- **Date:** 2026-10-15 (until then: NOR and PURIFY only, variants to confirm)
- **Decision:** `Gate n` has a constructor for each of the seven gates
  (COPY, NOT, OR, AND, NAND, NOR, PURIFY). `Instance S n` takes a gate set
  `S : Finset GateType` and requires every gate to have a type in `S`.
  Pure-Circuit as in Definition 1 is `S = {NOR, PURIFY}`; the choices of
  Corollary 2.2 are further values of `S`. Each gate set used in a statement
  is a named `Finset GateType`: `norPurify` for Definition 1; the sets of
  Corollary 2.2 are named together with their statements in
  `Results/PureCircuitVariants.lean`.
- **Paper reference:** Definition 1, Section 2.1 ("More gates"), Corollary 2.2
  ("for any of the following choices of gate types"), Corollary 2.3.
- **Encoding:** `GateType` is a label with one constructor per gate,
  `Gate.type` maps a gate to its label, and the instance field `allowed`
  (D10) restricts the gates. The gates are defined together with
  Definition 1, so `TfnpLean/PureCircuit.lean` is frozen once; the
  reductions between the variants come with the reductions.
- **Rejected:** separate problem definitions per gate set (repeats the
  instance conditions for every variant, and the reductions of Corollary 2.2
  would map between unrelated types); an unrestricted `Instance n` with a
  separate predicate "uses only gates from `S`" (every later definition
  would have to remember it, against D10); the seven-gate instance as the
  main object (not what the paper calls Pure-Circuit; the main object is
  the instance over `{NOR, PURIFY}`); adding the gates with the reductions (the
  instance type changes, so the frozen file would have to be unfrozen);
  `S` written as a literal at each use (`{NOR, PURIFY}` and `{PURIFY, NOR}`
  are equal sets but not definitionally equal terms, so the two instance
  types would need a cast between them).
- **Why:** Corollary 2.2 treats the gate set as a parameter of one problem,
  and so does the encoding. The instance conditions are written once, and a
  reduction between variants maps `Instance S n` to `Instance S' m`. The
  must-fail tests stay sharp because every test fixes its gate set.

## D4. Lean module system and CSLib file conventions

- **Question:** Which file conventions does the library follow?
- **Date:** 2026-10-08
- **Decision:** every file starts with the CSLib copyright header, `module`,
  and `public import` lines; module docstrings use CSLib's `/-! # ... -/`
  style with a References section.
- **Paper reference:** none; CSLib `CONTRIBUTING.md` and `AGENTS.md`.
- **Encoding:** header, `module`, `weak.linter.mathlibStandardSet = true`
  in `lakefile.toml`.
- **Rejected:** `allowNonModules = true` without `module` headers.
- **Why:** Mathlib and CSLib require the module system; adopting it now
  avoids a rewrite if the library is contributed.

## D5. Polynomial time behind an interface (open)

- **Question:** What does "polynomial time" mean in FP, TFNP, reductions
  and the classes?
- **Date:** 2026-10-15 (first decided 2026-10-08)
- **Options:** (a) a concrete machine model, such as
  `Cslib.Turing.SingleTapeTM.PolyTimeComputable` on CSLib's single-tape machines or Mathlib's
  Turing-machine polynomial time; (b) an abstract cost model; (c) polynomial
  time as an explicit hypothesis of each statement.
- **Decision:** search problems, reductions and classes are defined against
  an abstract interface, so that they do not wait for the choice. Which of
  (a) to (c) stands behind it is OPEN, to settle with the supervisor.
- **Paper reference:** Megiddo and Papadimitriou 1991 (FP); CSLib's
  reference is Arora and Barak, Chapter 1.
- **Rejected:** fixing (a) before the classes are written (every class
  would wait on the encodings of gate lists and circuits as tapes).
- **Why:** every class sits above this layer. The options trade
  faithfulness against effort: (a) is closest to the papers but the
  encodings are machine work; (b) and (c) are cheaper but move part of the
  meaning into an assumption that has to be stated honestly.
- **History:** until 2026-10-15 the decision was (a) with (b) rejected;
  reopened because it blocked the classes.
  On 2026-10-15 the `PolyTime.lean` docstring and this file were corrected to
  the real name `Cslib.Turing.SingleTapeTM.PolyTimeComputable`, and the
  `PPAD.lean` docstring to DGP05 Section 3, p. 3 (citations only; files
  unlocked for the edit and locked again).

## D6. Hardness is stated, not proved (proposed, to confirm)

- **Question:** Is PPAD-hardness of Pure-Circuit part of the library?
- **Date:** 2026-10-08
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

- **Question:** How are the node values `0`, `1`, `⊥` encoded?
- **Date:** by 2026-10-13
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

- **Question:** What is the node set of an instance?
- **Date:** by 2026-10-13, amended 2026-10-15 (gate set `S`)
- **Decision:** the node set is `Fin n`; an instance has type `Instance S n`
  (gate set `S`, D3) and an assignment has type `Fin n → Value`.
- **Paper reference:** DFHM24, Definition 1 (`V = [n]`).
- **Encoding:** `Gate n` and `Instance S n` are indexed by `n : ℕ`. Lean counts
  from `0`, the paper from `1`; nodes are shifted by one.
- **Rejected:** any type `V` with `[Fintype V] [DecidableEq V]`. More general,
  but the paper fixes `[n]`, and encoding instances for polynomial time
  (D5) needs a numbering of the nodes anyway.
- **Why:** literal match with the paper, and `decide` checks small instances
  directly. The search-problem layer bundles the size as `Σ n, Instance S n`,
  with `S` fixed per problem.

## D9. A gate is an inductive with one constructor per type; an instance's gates are a `Finset`

- **Question:** How are a gate and the gates of an instance encoded?
- **Date:** by 2026-10-13, amended 2026-10-15 (Section 2.1 gates)
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

- **Question:** Where do the conditions on a valid instance live?
- **Date:** 2026-10-13, amended 2026-10-15 (`allowed`)
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

- **Question:** How are the gate constraints written?
- **Date:** by 2026-10-13, amended 2026-10-15 (Section 2.1 gates)
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
  Appendix A.1 is applied to these definitions, and MF3 fails when OR, AND
  or NAND is relaxed the same way.

## D12. COPY and NOT are gates on two nodes

- **Question:** How many nodes do COPY and NOT have, and must they differ?
- **Date:** 2026-10-15
- **Decision:** `copy (u v)` and `not (u v)` with input `u` and output `v`;
  `outputs` is `{v}` and `Distinct` is `u ≠ v`.
- **Paper reference:** DFHM24, Section 2.1 (`g = (T, u, v)` for COPY and
  NOT); Definition 1 ("u, v, w ∈ V are distinct nodes").
- **Encoding:** two constructor arguments instead of three, the node names
  as in the paper. `u ≠ v` is our reading: the paper requires distinct nodes
  in Definition 1, and Section 2.1 defines the further gates without
  restating it. Remark 2 treats distinct NOR/NAND inputs as part of the
  definition, which supports carrying the requirement over to every gate.
- **Rejected:** three nodes with an unused `w` (not in the paper, and `w`
  would need a dummy node that is the output of no gate); NOT as
  `NOR(u, u → v)` (Remark 2: repeated inputs change the definition, and D10
  requires distinct nodes); allowing `u = v` for COPY and NOT.
- **Why:** literal match with the paper's `(T, u, v)`. With `u = v`, NOT
  would force `x[u] = ⊥` and COPY would constrain nothing; a gate that pins
  a node to garbage is not among the paper's gates. To confirm with the
  supervisor.

## D13. Separate circuit types: Pure-Circuit constraints, CSLib circuits for End-of-Line (proposed)

- **Question:** Do the three canonical problems share one circuit type?
- **Date:** 2026-10-15
- **Options:** (a) one core, generic in value domain and gate set, used by
  all three; (b) a separate type per problem; (c) the constraint model of
  D2 for Pure-Circuit and CSLib's `Cslib.Circuits.Circuit` for End-of-Line
  and Localopt.
- **Decision:** (c), proposed (2026-10-27, to confirm with the
  supervisor on 2026-10-28). Pure-Circuit keeps the constraint type of D2;
  End-of-Line's `S` and `P` are `Cslib.Circuits.Circuit` over the Boolean
  signature (D19); Localopt is expected to follow End-of-Line.
- **Paper reference:** DFHM24, Definition 1 (constraints on a possibly
  cyclic graph over `{0, 1, ⊥}`, solved by an assignment); Pap94 and DGP05
  Section 3, p. 3 (End-of-Line's `S` and `P` as Boolean circuits that are
  evaluated); FGHS (arXiv:2011.01929) Definition 2 (Localopt's circuits).
- **Why:** with (b), three circuit types drift apart and every reduction
  between the problems translates between them. Against (a): a CSLib
  `Circuit` is an acyclic straight-line program that is evaluated
  (`Circuit.eval`, `Program.trace`); a Pure-Circuit instance is a set of
  constraints on a possibly cyclic graph, solved by an assignment. One type
  for both would either forbid Pure-Circuit's cycles or give End-of-Line a
  circuit it cannot evaluate. Reductions between the two problems translate
  anyway, because the objects differ in the papers too (DFHM24 Definition 1
  versus DGP09 "two circuits S and P"). With (c), End-of-Line reuses CSLib's
  evaluation, composition (`Circuit.comp`, `Circuit.append`) and
  completeness of the basis instead of a second circuit library.
- **History:** until 2026-10-27 OPEN with (a) proposed.

## D14. Classes are reduction closures of their canonical problems (proposed)

- **Question:** How are PPAD and PLS defined?
- **Date:** 2026-10-15
- **Decision:** one generic construction, the closure of a problem under
  the library's reductions, gives PPAD from End-of-Line and PLS from
  Localopt.
- **Paper reference:** Pap94 (PPAD); FGHS Section 3.1 ("the set of all
  TFNP problems that reduce to the problem Localopt").
- **Rejected:** one bespoke definition per class (repeats the construction,
  and the classes could differ in how membership is stated); PLS through the
  three algorithms of Johnson, Papadimitriou and Yannakakis 1988 (equivalent,
  but a second shape next to PPAD's).
- **Why:** if PLS does not fit the construction PPAD used, the abstraction
  is wrong, and that shows early.

## D15. One variant per problem, cited by page

- **Question:** Which variant of each canonical problem does the library define?
- **Date:** 2026-10-15
- **Decision:** each canonical problem has exactly one Lean definition,
  following one paper's variant, cited with section and page. Other
  variants (for example whether `0^n` must be a source or counts as a
  solution when it is not) are separate definitions related by reductions,
  if needed at all.
  End-of-Line (2026-10-27, to confirm 2026-10-28): DGP09, SIAM J. Comput.
  39(1), Section 3.1, p. 202 (the same text as DGP05, ECCC TR05-115,
  Section 3, p. 3). Rejected for End-of-Line: Pap94 Section 2, p. 506
  (a machine returning a (predecessor, successor) pair, solutions are
  degree-one vertices; further from circuits); FGHS Definition 1, p. 13
  (the same definition on `[2^n]` numbered from 1; an encoding, not a
  different reading); "sinks only", which defines PPADS, not PPAD (DGP09
  p. 202).
- **Rejected:** a definition that merges variants, or one that follows no
  single text.
- **Why:** the variants that define the same class are still different
  Lean definitions, and the side-by-side check (`CHECKING.md`) needs one
  text to compare with. (Not every variant defines the same class: sinks
  only gives PPADS.) DGP09 is the formulation later papers use (FGHS copies
  it), and its solution condition is checked by two circuit evaluations.

## D16. End-of-Line vertices are `Fin n → Bool`

- **Question:** What is the vertex set of an End-of-Line instance?
- **Date:** 2026-10-27
- **Decision:** `EndOfLine.Vertex n := Fin n → Bool`, the paper's `{0, 1}^n`,
  with `EndOfLine.zeros : Vertex n := fun _ => false` for `0^n`.
- **Paper reference:** DGP09, Section 3.1, p. 202 ("each with n input bits
  and n output bits", "x ∈ {0,1}^n").
- **Encoding:** the input and output type of a CSLib `Circuit σ n n` under an
  interpretation in `Bool` is `Fin n → Bool`, so `S.eval` and `P.eval` act on
  vertices without conversion. `DecidableEq` and `Fintype` are inherited;
  `2^n` appears only as `Fintype.card (Vertex n)` in the totality argument,
  never in the definition.
- **Rejected:** `BitVec n` (readable literals, but every circuit call needs a
  conversion in both directions); `Fin (2^n)` (FGHS's `[2^n]`, a numbering
  the paper does not use, and again a conversion to bits).
- **Why:** the composite `P(S(x))` forces one type for the output of `S`, the
  input of `P` and the vertices; taking the circuits' own type makes the
  side-by-side table literal.

## D17. The End-of-Line solution condition is the paper's formula, on functions

- **Question:** Where and how is "x is a solution" written?
- **Date:** 2026-10-27
- **Decision:** two layers. `EndOfLine.IsSolution (S P : Vertex n → Vertex n)
  (x : Vertex n) : Prop := P (S x) ≠ x ∨ (S (P x) ≠ x ∧ x ≠ zeros)` is stated
  on plain functions, as the paper writes it. `Instance.IsSolution` applies
  it to `S.eval` and `P.eval`. The graph reading is defined alongside, not
  instead: `Edge S P x y := S x = y ∧ P y = x`, `IsSink`, `IsSource`, and
  the bridge `IsSolution S P x ↔ IsSink S P x ∨ (IsSource S P x ∧ x ≠ zeros)`
  is a statement in `Results/` (D6 style: stated, proved when asked).
- **Paper reference:** DGP09, Section 3.1, p. 202: the definition ("find an
  input x such that P(S(x)) ≠ x or S(P(x)) ≠ x ≠ 0^n") and the next
  paragraph ("Intuitively ... an edge from x to y whenever both y = S(x) and
  x = P(y)"; "We seek either a sink, or a source other than 0^n").
- **Rejected:** the condition written only inside `Instance` on the circuit
  evaluations (every hand example and the totality argument would then need
  CSLib circuits computing the example tables); defining a solution as "sink
  or source ≠ 0^n" with the formula as a theorem (reads well, but puts the
  paper's definition one unproved theorem away from the Lean definition).
- **Why:** the formula is the paper's definition, so the side-by-side table
  has no divergence row; the edge vocabulary is what the walkthrough uses to
  explain it; the function layer is where examples are checked by `decide`
  and where reductions argue about what their circuits compute. `≠ 0^n`
  stays in the second clause: the instance condition (D18) makes `0^n` a
  source in every instance, so without it `0^n` would always be a solution.

## D18. The condition on `0^n` is a proof field of `Instance` (proposed)

- **Question:** How is "such that P(0^n) = 0^n ≠ S(0^n)" enforced?
- **Date:** 2026-10-27, to confirm with the supervisor on 2026-10-28
- **Decision:** `Instance n` has a field `source : P.eval i zeros = zeros ∧
  S.eval i zeros ≠ zeros` (with `i` the Boolean interpretation), in the
  style of D10.
- **Paper reference:** DGP09, Section 3.1, p. 202 ("such that
  P(0^n) = 0^n ≠ S(0^n)").
- **Rejected:** no field, with a third clause making `0^n` a solution when
  the condition fails ("violations count as solutions"; every pair of
  circuits becomes an instance, but the clause is not in DGP09's text and
  needs a source of its own); enforcing the condition by a circuit
  construction wrapping any pair `(S, P)` (FGHS p. 13, "can be enforced
  syntactically"; a construction with a correctness proof before the first
  instance exists).
- **Why:** it is the paper's "such that", an invalid instance cannot be
  built, and totality is a clean theorem over all instances. The price is
  that a reduction to End-of-Line must produce the proof, which is two
  circuit evaluations. If the TFNP layer later requires every string to be
  an instance, the switch to the rejected first option is local to this
  entry and to `Instance`.

## D19. End-of-Line circuits are CSLib Boolean circuits, `n` a type parameter

- **Question:** What are `S` and `P`, and where does the definition live?
- **Date:** 2026-10-27
- **Decision:** `S P : Cslib.Circuits.Circuit Cslib.Circuits.Boolean.signature
  n n`, evaluated with `Cslib.Circuits.Boolean.interpretation` (constants,
  NOT, AND, OR). `Instance n` is indexed by `n : ℕ` as in D8. The definitions
  live in `TfnpLean/PPAD.lean`, namespace `TfnpLean.EndOfLine`, next to the
  planned PPAD (D14), which waits on reductions and D5.
- **Paper reference:** DGP09, Section 3.1, p. 202 ("two circuits S and P");
  the basis is not fixed there. Arora and Barak, Section 6.1 (the standard
  Boolean circuit model, which CSLib cites).
- **Rejected:** a generic signature `σ` with an interpretation in `Bool` as a
  parameter of `Instance` (generality without a use); `n` as a field (the
  vertex type depends on it); a separate `EndOfLine.lean` (the plan keeps
  End-of-Line and PPAD together; split when PPAD arrives if the file grows).
- **Why:** the basis does not change which `x` are solutions (D17 depends
  only on the functions computed), and it is complete, so every function on
  `n` bits has a circuit; a change of complete basis changes sizes by a
  constant factor, which the polynomial-time layer (D5) tolerates. Not a
  divergence from the paper, but a choice, so it is logged.

## Open

- Namespace: `TfnpLean` for now; a CSLib contribution would use `Cslib`.
- Polynomial time (D5).
- The circuit core (D13) and the `0^n` condition (D18): proposed, supervisor
  review 2026-10-28.
- Which text Localopt follows (D15).
