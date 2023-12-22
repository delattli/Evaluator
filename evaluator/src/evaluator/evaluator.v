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

import math

interface VariableResolver {
	resolve_variable(name string) !f64
}

type Function = fn(arguments []f64) !f64

pub struct Context {
	resolver  VariableResolver = Empty{}
	functions map[string]Function
}

struct Empty{}

pub const std_functions = {
	'ceil': float_ceil,
	'max': float_max
}

fn float_ceil(args []f64) !f64 {
	if args.len == 0 {
		return 0
	}
	return math.ceil(args[0])
}

fn float_max(args []f64) !f64 {
	if args.len == 0 {
		return 0
	}
	if args.len == 1 {
		return args[0]
	}
	mut max := math.smallest_non_zero_f64
	for i := 0; i < args.len; i++ {
		max = math.max(max, args[i])
	}
	return max
}

fn (e Empty)resolve_variable(name string) !f64 {
	return error('Function resolve_variable undefined')
}

pub fn (context Context) evaluate(expr string) !f64 {
	mut nodes := parse(expr) or { return err }
	return nodes.eval(context)
}
