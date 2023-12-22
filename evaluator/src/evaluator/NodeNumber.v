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

struct NodeNumber {
	number f64
}

fn (nn NodeNumber) eval(ctx Context) !f64 {
	return nn.number
}
