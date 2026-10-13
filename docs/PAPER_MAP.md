# Paper map

Paper item to Lean declaration to status. Status values, in order:
`planned` (docstring only), `on paper` (written next to the paper, examples
by hand), `drafted` (Lean exists, tests exist), `checked` (four-step check
done by me), `reviewed` (walked through with the supervisor; file frozen with
`scripts/freeze.py`). For theorems the proof state is noted after a comma:
`sorry` or `proved`. `scripts/check_paper_map.py` enforces that `checked`
and `reviewed` rows name a declaration that appears in `TfnpLean/Tests/`.

Paper keys: DFHM24 = Pure-Circuit (arXiv:2209.15149), MP91 = Megiddo and
Papadimitriou 1991, Pap94 = Papadimitriou 1994, DGP05 = Daskalakis, Goldberg,
Papadimitriou ECCC TR05-115, BFGS26 = Batziou, Fearnley, Ghosh, Savani
(arXiv:2602.18380), HR23 = Hollender and Rubinstein, four-agent envy-free
cake cutting.

| Paper item | Lean declaration | File | Status |
|---|---|---|---|
| DFHM24 Def. 1: node values 0, 1, ⊥ | `TfnpLean.PureCircuit.Value` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: gate (NOR, PURIFY) | `TfnpLean.PureCircuit.Gate` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: instance, every node output of exactly one gate | `TfnpLean.PureCircuit.Instance` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: NOR satisfied | `TfnpLean.PureCircuit.Gate.Satisfied` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: PURIFY satisfied | `TfnpLean.PureCircuit.Gate.Satisfied` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: solution | `TfnpLean.PureCircuit.Instance.IsSolution` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 §2.1: gates COPY, NOT, OR, AND, NAND | | `TfnpLean/PureCircuit.lean` | planned |
| DFHM24 Cor. 2.2: variants reduce to NOR + PURIFY | | `TfnpLean/Results/PureCircuitVariants.lean` | planned |
| DFHM24 Thm. 2.1: Pure-Circuit in PPAD | | `TfnpLean/Results/PureCircuitInPPAD.lean` | planned, scope open |
| DFHM24 Thm. 2.1: Pure-Circuit PPAD-hard (statement only) | | `TfnpLean/Results/PureCircuitPPADHard.lean` | planned, proposed, to confirm; proof out of scope |
| DFHM24 Cor. 2.3: structural restrictions | | | out of scope |
| DFHM24 Def. 2: StrongSperner | | | out of scope (only needed for the hardness proof) |
| DFHM24 App. A.1: all-garbage not a solution with PURIFY | `TfnpLean.PureCircuit.Tests.norCycle` | `TfnpLean/Tests/PureCircuit.lean` | drafted (MF1) |
| MP91 §1: search problem | | `TfnpLean/SearchProblem.lean` | planned |
| MP91 §1: total search problem | | `TfnpLean/SearchProblem.lean` | planned |
| MP91 §1: FP | | `TfnpLean/PolyTime.lean` | planned |
| MP91 §1: TFNP | | `TfnpLean/TFNP.lean` | planned |
| Pap94 §2: polynomial-time reduction | | `TfnpLean/Reduction.lean` | planned |
| Pap94 §2, DGP05 §2: End-of-Line | | `TfnpLean/PPAD.lean` | planned |
| Pap94 §2: PPAD, PPAD-hard, PPAD-complete | | `TfnpLean/PPAD.lean` | planned |
| Pap94 §2: End-of-Line is total | | `TfnpLean/Results/EndOfLineTotal.lean` | planned |
| Folklore: circuit evaluation in polynomial time | | `TfnpLean/Results/CircuitEvalPolyTime.lean` | planned |
| Pap94: PPAD ⊆ TFNP | | `TfnpLean/Results/PPADSubsetTFNP.lean` | planned |
| BFGS26: sparse win-lose equilibrium problem | | `TfnpLean/Validation/SparseWinLose.lean` | planned, meaning of validation open |
| HR23: envy-free cake cutting | | `TfnpLean/Validation/CakeCutting.lean` | planned, query model open |
