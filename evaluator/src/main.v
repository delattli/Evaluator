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
module main

import evaluator
import math

const ( expressions = [
	'10 + 20',
	'10 - 20',
	'10 + 20 - 40 + 100',
	'-10',
	'+10',
	'ceil(10.54)',
	'--++-+-10',
	'10 + -20 - +30',
	'10 * 20',
	'10 / 20',
	'10 * 20 / 50',
	'10 + 20 * 30',
	'(10 + 20) * 30',
	'-(10 + 20) * 30',
	'((10 + 20) * 5) * 30'
	'r',
	'pi'
]
	resultats = [
	30.0,
	-10.0,
	90.0,
	-10.0,
	10.0,
	11.0,
	10.0,
	-40.0,
	200.0,
	0.5,
	4.0,
	610.0,
	900.0,
	-900.0,
        4500.0,
	5.0,
	math.pi
])

struct World{}

fn (w World) resolve_variable(name string) !f64 {
	if name == 'r' {
		return 5.0
	}
	if name == 'pi' {
		return math.pi
	}
	return error('Undefined variable')
}

fn main() {
	a := evaluator.Context{ functions: evaluator.std_functions, resolver: World{} }

	for i in 0..expressions.len {
		r := a.evaluate(expressions[i]) or {
			println(err)
			continue
		}
		assert r == resultats[i]

		println('Parse ${expressions[i]} = ${r}')
	}
}
