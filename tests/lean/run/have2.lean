definition Prop : Type.{1} := Type.{0}
variables a b c : Prop
axiom Ha : a
axiom Hb : b
axiom Hc : c
check have H1 [visible] : a, from Ha,
      have H2 : a, from H1,
      H2
