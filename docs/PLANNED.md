# Planned modules

Modules that are planned and not yet written. A module is created when its first
declaration exists; until then its plan lives here: what goes in it, what it depends on
and which paper item it follows. Per-item status is in `PAPER_MAP.md`, decisions are in
`DESIGN.md`.

Layers, bottom up: problems (`TfnpLean.PureCircuit`, `TfnpLean.EndOfLine`, no dependency on
the frame), polynomial time, the frame (search problems, TFNP, reductions), classes
(`TfnpLean.PPAD` as the reduction closure of End-of-Line, D14 and D22), then results.

## `TfnpLean/PolyTime.lean`: Polynomial time

### What goes here

An interface for polynomial-time computation, so that "checking a solution is
fast" and "the reduction maps are fast" can be stated in `TfnpLean.TFNP` and
`TfnpLean.Reduction` before the machine model is chosen (`docs/DESIGN.md`, D5).
What stands behind the interface is open: a concrete machine model such as
CSLib's `Cslib.Turing.SingleTapeTM.PolyTimeComputable` on single-tape Turing
machines (composition is `Cslib.Turing.SingleTapeTM.PolyTimeComputable.comp`),
an abstract cost model, or polynomial time as an explicit hypothesis. The
encoding of instances and solutions as strings belongs to the concrete choice.

The class FP is not in CSLib; it is stated here against the interface.

### Dependencies

To be fixed with D5. Candidates in CSLib:
`Cslib.Computability.Machines.Turing.SingleTape.Deterministic`,
`Cslib.Foundations.Data.BitString`.

### Paper reference

* [S. Arora, B. Barak, *Computational Complexity: A Modern Approach*,
  Chapter 1][AroraBarak09] for the machine model (CSLib's reference).
* [MP91, Section 1] for FP as the class of search problems solvable in
  polynomial time.

## `TfnpLean/SearchProblem.lean`: Search problems

### What goes here

The general notion of a search problem: an instance type, a solution type, and
a relation saying which solutions count for which instance. The frame does not
import any problem: the statement that Pure-Circuit or End-of-Line is a search
problem lives in a module that imports both the frame and the problem. Pure-Circuit
is the first case and the test that the general shape fits a concrete problem.

Totality (every instance has a solution) is a property of a search problem and
is stated here; the complexity conditions of TFNP are in `TfnpLean.TFNP`.

### Dependencies

Mathlib.

### Paper reference

* [N. Megiddo, C. H. Papadimitriou, *On total functions, existence theorems
  and computational complexity*, TCS 81(2), 1991, Section 1][MP91].
* [C. H. Papadimitriou, *On the complexity of the parity argument and other
  inefficient proofs of existence*, JCSS 48(3), 1994, Section 1][Pap94].

## `TfnpLean/TFNP.lean`: TFNP

### What goes here

The class TFNP: search problems where (1) a solution always exists, (2)
solutions are polynomially short in the instance, and (3) checking a proposed
solution is polynomial time. Conditions (2) and (3) use `TfnpLean.PolyTime`;
condition (1) is totality from `TfnpLean.SearchProblem`.

### Dependencies

`TfnpLean.SearchProblem`, `TfnpLean.PolyTime`.

### Paper reference

* [MP91, Section 1] (TFNP, written there as "the class of total NP search
  problems").
* [Pap94, Section 1].
* [P. W. Goldberg, C. H. Papadimitriou, *Towards a unified complexity theory
  of total functions*, JCSS 94, 2018][GP18] for the modern view.

## `TfnpLean/Reduction.lean`: Reductions

### What goes here

Polynomial-time reductions between search problems: a map `f` from instances of
A to instances of B and a map `g` from solutions of B back to solutions of A,
both polynomial time (`TfnpLean.PolyTime`), such that a solution of the
translated instance maps back to a solution of the original instance.
Reductions compose and the identity is a reduction; both are sanity theorems
that test the definition. The closure of a problem under reductions is the one
construction that PPAD (from End-of-Line) and PLS (from Localopt) are built from
(`docs/DESIGN.md`, D14).

The first reductions to be stated are the ones between Pure-Circuit gate-set
variants, [DFHM24, Corollary 2.2]; their statements live in
`TfnpLean.Results.PureCircuitVariants`.

### Dependencies

`TfnpLean.SearchProblem`, `TfnpLean.PolyTime`.

### Paper reference

* [Pap94, Section 2] (reductions between search problems).
* [MP91, Section 1].

## `TfnpLean/Results/PureCircuitVariants.lean`: Result: Pure-Circuit gate-set variants reduce to each other

The first reductions in the library stay inside Pure-Circuit: the gate sets of
[DFHM24, Corollary 2.2] (PURIFY with NOR or NAND; PURIFY and NOT with OR or AND)
each reduce to and from `norPurify`, the gate set of Definition 1. All of them are
`Instance S n` for a gate set `S` (`docs/DESIGN.md`, D3), so a reduction maps
`Instance S n` to `Instance S' m`. The gate sets of the corollary are named here,
together with the statements.

The proof in the paper simulates NOR by the other gate sets (NOT from PURIFY plus
NAND, OR from NOT plus AND by De Morgan, and so on). The two gadgets the proof
uses are checked in `TfnpLean/Tests/PureCircuit.lean`.

### Dependencies

`TfnpLean.Reduction`, `TfnpLean.PureCircuit`.

### Paper reference

* [DFHM24, Section 2.1, Corollary 2.2].

## `TfnpLean/Results/PureCircuitInPPAD.lean`: Result: Pure-Circuit is in PPAD

Membership of Pure-Circuit in PPAD, the easy half of [DFHM24, Theorem 2.1].
In the paper it follows either from the reductions of Section 4 to problems
known to be in PPAD, or directly by reducing to a Brouwer fixed-point problem
(Section 2, discussion after Theorem 2.1). Either way a fixed-point theorem or
another PPAD problem is needed. The planned route is through ε-GCircuit, see
"The chain" below; how much of it is proved and how much cited is open.

PPAD-hardness, the other half of Theorem 2.1, is stated in
`TfnpLean.Results.PureCircuitPPADHard`.

### Dependencies

`TfnpLean.PPAD` (the class), `TfnpLean.EndOfLine`, `TfnpLean.PureCircuit`.

### Paper reference

* [DFHM24, Theorem 2.1 and the discussion following it; Section 3.1 for
  StrongSperner].

## `TfnpLean/Results/PureCircuitPPADHard.lean`: Result: Pure-Circuit is PPAD-hard

(`docs/DESIGN.md`, D6, to revise.)

PPAD-hardness of Pure-Circuit, the hard half of [DFHM24, Theorem 2.1]: every
problem in PPAD reduces to Pure-Circuit. Together with
`TfnpLean.Results.PureCircuitInPPAD` this states PPAD-completeness. The
proof is in scope since 2026-11-04: it composes the hardness steps of "The
chain" below.

### Dependencies

`TfnpLean.PPAD` (the class), `TfnpLean.EndOfLine`, `TfnpLean.PureCircuit`.

### Paper reference

* [DFHM24, Theorem 2.1; Section 3, Definition 2 (StrongSperner)].

## `TfnpLean/Results/CircuitEvalPolyTime.lean`: Result: Boolean circuits evaluate in polynomial time

and D13.

Evaluating a circuit on an input is polynomial time in the size of the circuit
plus the input. This is the fact that makes End-of-Line (and so PPAD) a member
of TFNP: a proposed solution is checked by evaluating the two circuits a
constant number of times. With a concrete machine model (D5) it is a theorem
and a lot of machine work, not conceptually hard; with an abstract model it may
be part of what the interface provides.

### Dependencies

`TfnpLean.PolyTime`, the circuit model (D13).

### Paper reference

* [AroraBarak09, Section 6.1] (circuit evaluation), CSLib
  `Cslib.Computability.Circuit` for the circuit model.

## `TfnpLean/Results/PPADSubsetTFNP.lean`: Result: PPAD is contained in TFNP

End-of-Line is in TFNP (totality from `EndOfLineTotal`, polynomial-time
checking from `CircuitEvalPolyTime`, short solutions by construction), and
TFNP is closed under polynomial-time reductions, so every problem in PPAD is in
TFNP.

### Dependencies

`TfnpLean.TFNP`, `TfnpLean.Results.EndOfLineTotal`,
`TfnpLean.Results.CircuitEvalPolyTime`.

### Paper reference

* [Pap94, Section 2].

## The chain: StrongSperner, ε-GCircuit and the reductions between the problems

No module names yet; each problem gets its own module (D22) when its first
declaration exists.

Problems:

* StrongSperner [DFHM24, Section 3.1, Definition 2, p. 10].
* 2D Sperner. Open: its own definition after [CD06], or StrongSperner with
  `N = 2` and a large grid as in [DFHM24, Remark 3, p. 11].
* ε-GCircuit [DFHM24, Definition 3, from CDT09].

Hardness, one statement per step:

* End-of-Line reduces to 2D Sperner [DFHM24, Remark 3; CD06].
* 2D Sperner reduces to StrongSperner, by snake embedding [DFHM24, Remark 3;
  CDT09].
* StrongSperner reduces to Pure-Circuit [DFHM24, Section 3.2, Lemmas 3.2 to
  3.6].

Membership:

* Pure-Circuit reduces to ε-GCircuit [DFHM24, Section 4.1].
* ε-GCircuit is in PPAD [CDT09, Lemma 5.7; Pap94]. Proved or cited: open.

### Dependencies

`TfnpLean.Reduction`, `TfnpLean.PPAD`, `TfnpLean.EndOfLine`,
`TfnpLean.PureCircuit`; polynomial time (D5) for every reduction.

## `TfnpLean/Validation/SparseWinLose.lean`: Validation: sparse win-lose bimatrix games

Stretch: an application of Pure-Circuit, after the chain. An existing result restated in the library's terms: the main theorem of
Batziou, Fearnley, Ghosh and Savani [BFGS26] on approximate Nash equilibria of
3-sparse win-lose bimatrix games, written with library primitives only.
Needing a primitive the library does not have shows a gap in the library.

### Dependencies

`TfnpLean.PPAD`.

### Paper reference

* [E. Batziou, J. Fearnley, A. Ghosh, R. Savani, *The Complexity of Sparse
  Win-Lose Bimatrix Games*, arXiv:2602.18380][BFGS26].
