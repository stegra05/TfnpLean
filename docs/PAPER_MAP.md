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
(arXiv:2602.18380), DGP09 = Daskalakis, Goldberg, Papadimitriou, SIAM J.
Comput. 39(1), 2009, JPY88 = Johnson, Papadimitriou, Yannakakis 1988,
FGHS23 = Fearnley, Goldberg, Hollender, Savani, J. ACM 70(1), 2023
(arXiv:2011.01929), HR23 = Hollender and Rubinstein, four-agent envy-free
cake cutting.

| Paper item | Lean declaration | File | Status |
|---|---|---|---|
| DFHM24 Def. 1: node values 0, 1, ⊥ | `TfnpLean.PureCircuit.Value` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: gate (NOR, PURIFY) | `TfnpLean.PureCircuit.Gate` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: instance (gate set, distinct nodes and exactly-one rule as fields) | `TfnpLean.PureCircuit.Instance` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: every node output of exactly one gate | `TfnpLean.PureCircuit.OutputUnique` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: NOR satisfied | `TfnpLean.PureCircuit.Gate.Satisfied` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: PURIFY satisfied | `TfnpLean.PureCircuit.Gate.Satisfied` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Def. 1: solution | `TfnpLean.PureCircuit.Instance.IsSolution` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 §2.1: gates COPY, NOT, OR, AND, NAND | `TfnpLean.PureCircuit.Gate` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 §2.1: COPY, NOT, OR, AND, NAND satisfied | `TfnpLean.PureCircuit.Gate.Satisfied` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Cor. 2.2: choice of gate types | `TfnpLean.PureCircuit.GateType`, `TfnpLean.PureCircuit.norPurify`, field `Instance.allowed` | `TfnpLean/PureCircuit.lean` | drafted |
| DFHM24 Cor. 2.2 proof: NOT from PURIFY and NAND, NOR from OR and NOT | `TfnpLean.PureCircuit.Tests.notGadget`, `TfnpLean.PureCircuit.Tests.norGadget` | `TfnpLean/Tests/PureCircuit.lean` | drafted |
| DFHM24 Cor. 2.2: variants reduce to NOR + PURIFY | | `TfnpLean/Results/PureCircuitVariants.lean` | planned |
| DFHM24 Thm. 2.1: Pure-Circuit in PPAD (statement) | | `TfnpLean/Results/PureCircuitInPPAD.lean` | planned, proof not planned |
| DFHM24 Thm. 2.1: Pure-Circuit PPAD-hard (statement only) | | `TfnpLean/Results/PureCircuitPPADHard.lean` | planned, proposed, to confirm; proof out of scope |
| DFHM24 Cor. 2.3: structural restrictions | | | out of scope |
| DFHM24 Def. 2: StrongSperner | | | out of scope (only needed for the hardness proof) |
| DFHM24 App. A.1: all-garbage not a solution with PURIFY | `TfnpLean.PureCircuit.Tests.norCycle` | `TfnpLean/Tests/PureCircuit.lean` | drafted (MF1) |
| MP91 §1: search problem | | `TfnpLean/SearchProblem.lean` | planned |
| MP91 §1: total search problem | | `TfnpLean/SearchProblem.lean` | planned |
| MP91 §1: FP | | `TfnpLean/PolyTime.lean` | planned, model open (D5) |
| MP91 §1: TFNP | | `TfnpLean/TFNP.lean` | planned |
| Pap94 §2: polynomial-time reduction | | `TfnpLean/Reduction.lean` | planned |
| Sanity: reductions compose, the identity is a reduction | | `TfnpLean/Reduction.lean` | planned |
| DGP09 §3.1 p. 202: vertices {0,1}^n, 0^n | `TfnpLean.EndOfLine.Vertex`, `TfnpLean.EndOfLine.zeros` | `TfnpLean/PPAD.lean` | drafted |
| DGP09 §3.1 p. 202: End-of-Line solution condition (on functions) | `TfnpLean.EndOfLine.IsSolution` | `TfnpLean/PPAD.lean` | drafted |
| DGP09 §3.1 p. 202: edge x → y iff y = S(x) and x = P(y); sink, source | `TfnpLean.EndOfLine.Edge`, `TfnpLean.EndOfLine.IsSink`, `TfnpLean.EndOfLine.IsSource` | `TfnpLean/PPAD.lean` | drafted |
| DGP09 §3.1 p. 202: End-of-Line instance (two circuits, P(0^n) = 0^n ≠ S(0^n) as a field) | `TfnpLean.EndOfLine.Instance` | `TfnpLean/PPAD.lean` | drafted, D13 and D18 proposed |
| DGP09 §3.1 p. 202: solution of an instance | `TfnpLean.EndOfLine.Instance.IsSolution` | `TfnpLean/PPAD.lean` | drafted |
| DGP09 §3.1 p. 202: "a sink, or a source other than 0^n" equals the formula | | `TfnpLean/Results/EndOfLineTotal.lean` | planned (D17 bridge) |
| Pap94 §2: PPAD, PPAD-hard, PPAD-complete | | `TfnpLean/PPAD.lean` | planned, as a reduction closure (D14) |
| Pap94 §2: End-of-Line is total | | `TfnpLean/Results/EndOfLineTotal.lean` | planned |
| Folklore: circuit evaluation in polynomial time | | `TfnpLean/Results/CircuitEvalPolyTime.lean` | planned, depends on D5 |
| Pap94: PPAD ⊆ TFNP | | `TfnpLean/Results/PPADSubsetTFNP.lean` | planned |
| Pap94: Sperner in PPAD (statement) | | | planned |
| FGHS23 Def. 2 (p. 13): Localopt | | | planned, variant to choose (D15) |
| JPY88 §2, FGHS23 §3.1: PLS | | | planned, as a reduction closure (D14) |
| Pap94: PPA, PPP, PPADS; FGHS23: CLS | | | planned, after PPAD and PLS |
| BFGS26: main theorem restated with library primitives | | `TfnpLean/Validation/SparseWinLose.lean` | planned |
| HR23: envy-free cake cutting | | | out of scope (query model, not an input-based search problem) |
