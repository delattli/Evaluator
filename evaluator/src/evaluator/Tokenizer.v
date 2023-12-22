module evaluator

pub interface Node {
	eval(ctx Context) !f64
}

struct Tokenizer {
	expression   string
	mut:
	index        int
	current_char u8
	token        Token
	number       f64
	identifier   string
}

fn (mut t Tokenizer) next_char() {
	if t.index < t.expression.len {
		t.current_char = t.expression[t.index]
		t.index++
	} else {
		t.current_char = 0
	}
}

fn (mut t Tokenizer) next_token() ! {
	// Skip whitespace
	for t.current_char.is_space() {
		t.next_char()
	}

	// Special characters
	match t.current_char {
		0 {
			t.token = .eof
			return
		}
		`+` {
			t.next_char()
			t.token = .add
			return
		}
		`-` {
			t.next_char()
			t.token = .subtract
			return
		}
		`*` {
			t.next_char()
			t.token = .multiply
			return
		}
		`/` {
			t.next_char()
			t.token = .divide
			return
		}
		`(` {
			t.next_char()
			t.token = .openparens
			return
		}
		`)` {
			t.next_char()
			t.token = .closeparens
			return
		}
		`,` {
			t.next_char()
			t.token = .comma
			return
		}
		else {}
	}

	// number ?
	if t.current_char.is_digit() || t.current_char == `.` {
		// Capture digits/decimal point
		mut sb := ''
		mut have_decimal_point := false
		for t.current_char.is_digit() || (!have_decimal_point && t.current_char == `.`) {
			sb += t.current_char.ascii_str()
			have_decimal_point = t.current_char == `.`
			t.next_char()
		}

		// Parse it
		t.number = sb.f64()
		t.token = .number
		return
	}

	// Identifier - starts with letter or underscore
	if t.current_char.is_letter() || t.current_char == `_` {
		mut sb := ''
		for t.current_char.is_alnum() || t.current_char == `_` {
			sb += t.current_char.ascii_str()
			t.next_char()
		}

		t.identifier = sb
		t.token = .identifier
		return
	}
	return error('Unexpect character \'${t.current_char.ascii_str()}\'')
}

