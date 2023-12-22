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

struct NodeFunctionCall {
	function_name string
	arguments     []Node
}

fn (fnc NodeFunctionCall) eval(ctx Context) !f64 {
	mut argvals := []f64 {}

	for arg in fnc.arguments {
		argvals << arg.eval(ctx) or { return err }
	}

	call_function := ctx.functions[fnc.function_name] or { return error('Function not defined: ${fnc.function_name}') }
	return call_function(argvals)
}
