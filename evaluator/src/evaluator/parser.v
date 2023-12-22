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

const ( op_add_subtract = {
			Token.add: add
			Token.subtract: subtract
		}
		op_multiply_divide = {
			Token.multiply: multiply
			Token.divide: divide
		}
)

fn add(l f64, r f64) !f64 {
	return l + r
}

fn subtract(l f64, r f64) !f64 {
	return l - r
}

fn multiply(l f64, r f64) !f64 {
	return l * r
}

fn divide(l f64, r f64) !f64 {
	if r == 0 {
		return error('Divide by zero')
	}
	return l / r
}

// Parse an entire expression and check EOF was reached
fn (mut t Tokenizer) parse_expression() !Node {
	// For the moment, all we understand is add and subtract
	expr := t.parse_add_subtract() or { return err }

	// Check everything was consumed
	if t.token != .eof {
		return error('Unexpected characters at end of expression')
	}

	return expr
}

// Parse an sequence of add/subtract operators
fn (mut t Tokenizer) parse_add_subtract() !Node {
	// Parse the left hand side
	mut left := t.parse_multiply_divide() or { return err }
	for true {
		op := op_add_subtract[t.token] or { break }
		// Skip the operator
		t.next_token() or { return err }

		// Parse the right hand side of the expression
		right := t.parse_multiply_divide() or { return err }

		// Create a binary node and use it as the left-hand side from now on
		left = NodeBinary{
			left: left
			right: right
			op: op
		}
	}

	return left
}

// Parse an sequence of add/subtract operators
fn (mut t Tokenizer) parse_multiply_divide() !Node {
	// Parse the left hand side
	mut left := t.parse_unary() or { return err }
	for true {
		op := op_multiply_divide[t.token] or { break }
		// Skip the operator
		t.next_token() or { return err }

		// Parse the right hand side of the expression
		right := t.parse_unary() or { return err }

		// Create a binary node and use it as the left-hand side from now on
		left = NodeBinary{
			op_type: t.token
			left: left
			right: right
			op: op
		}
	}

	return left
}


// Parse a unary operator (eg: negative/positive)
fn (mut t Tokenizer) parse_unary() !Node {
	for true {
		// Positive operator is a no-op so just skip it
		if t.token == .add {
			// Skip
			t.next_token() or { return err }
			continue
		}

		// Negative operator
		if t.token == .subtract {
			// Skip
			t.next_token() or { return err }

			// Parse RHS
			// Note this recurses to self to support negative of a negative
			right := t.parse_unary() or { return err }

			// Create unary node
			return NodeUnary{
				right: right
				op:    fn(nb f64) f64 { return -nb }
			}
		}

		// No positive/negative operator so parse a leaf node
		break
	}
	return t.parse_leaf() or { err }
}

// Parse a leaf node
fn (mut t Tokenizer) parse_leaf() !Node {
	// Is it a number?
	if t.token == .number {
		node := NodeNumber{
			number: t.number
		}
		t.next_token() or { return err }
		return node
	}

	// Parenthesis?
	if t.token == .openparens {
		// Skip '('
		t.next_token() or { return err }

		// Parse a top-level expression
		node := t.parse_add_subtract() or { return err }

		// Check and skip ')'
		if t.token != .closeparens  {
			return error('Missing close parenthesis')
		}
		t.next_token() or { return err }

		// Return
		return node
	}

	// Variable
	if t.token == .identifier {
		// Capture the name and skip it
		name := t.identifier
		t.next_token() or { return err }

		// Parens indicate a function call, otherwise just a variable
		if t.token != .openparens {
			// Variable
			return NodeVariable{
				variable_name: name
			}
		} else {
			// Function call

			// Skip parens
			t.next_token() or { return err }

			// Parse arguments
			mut arguments := []Node {}
			for true {
				// Parse argument and add to list
				arg := t.parse_add_subtract() or { return err }
				arguments << arg

				// Is there another argument?
				if t.token == .comma {
					t.next_token() or { return err }
					continue
				}

				// Get out
				break
			}

			// Check and skip ')'
			if t.token != .closeparens {
				return error('Function not close')
			}
			t.next_token() or { return err }

			// Create the function call node
			return NodeFunctionCall{
				function_name: name
				arguments: arguments
			}
		}
	}

	// Don't Understand
	return error('Unexpect token: ${t.token}')
}

// Helper to parse a string
pub fn parse(str string) !Node {
	mut tokenizer := Tokenizer{
		expression: str
	}
	tokenizer.next_char()
	tokenizer.next_token() or { return err }
	return tokenizer.parse_expression()
}
