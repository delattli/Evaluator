/*
  Copyright(C)2023 by DELATTRE Lionel <delattli@gmail.com>

  This software is a computer program whose purpose is to dynamically
  evaluate expressions.

  This software is governed by the CeCILL  license under French law and
  abiding by the rules of distribution of free software.  You can  use,
  modify and/ or redistribute the software under the terms of the CeCILL
  license as circulated by CEA, CNRS and INRIA at the following URL
  "http://www.cecill.info".
 */
module evaluator

struct NodeBinary {
	op_type Token
	left    Node
	right   Node
	op      fn (lhsval f64, rhsval f64) !f64 [required]
}

fn (nb NodeBinary) eval(ctx Context) !f64 {
	lhsval := nb.left.eval(ctx) or { return err }
	rhsval := nb.right.eval(ctx) or { return err }
	return nb.op(lhsval, rhsval)
}
