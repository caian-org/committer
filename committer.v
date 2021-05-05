module main

import os
import rand
import term


const (
	lorem_ipsum = ['lorem', 'ipsum', 'dolor', 'sit', 'amet', 'consectetur', 'adipiscing', 'elit',
		'morbi', 'efficitur', 'libero', 'vitae', 'congue', 'blandit', 'orci', 'sem', 'semper',
		'purus', 'ac', 'mattis', 'eros', 'mi', 'quis', 'magna', 'mauris', 'id', 'turpis', 'iaculis',
		'pulvinar', 'ut', 'porta', 'dui', 'duis', 'faucibus', 'augue', 'eget', 'laoreet', 'etiam',
		'eu', 'a', 'metus', 'scelerisque', 'bibendum', 'non', 'lacus', 'sed', 'feugiat', 'nibh',
		'suscipit', 'ante', 'in', 'hac', 'habitasse', 'platea', 'dictumst', 'cras', 'cursus',
		'lectus', 'finibus', 'rhoncus', 'quam', 'justo', 'tincidunt', 'urna', 'et', 'integer',
		'fringilla', 'at', 'odio', 'consequat', 'suspendisse', 'interdum', 'nulla', 'gravida',
		'pellentesque', 'pharetra', 'velit', 'elementum', 'vulputate', 'maximus', 'nisi', 'nunc',
		'nullam', 'sapien', 'posuere', 'dictum', 'praesent', 'dapibus', 'sollicitudin', 'vivamus',
		'venenatis', 'risus', 'varius', 'donec', 'aliquam', 'quisque', 'pretium', 'commodo', 'nec',
		'vel', 'condimentum', 'nisl', 'facilisis', 'tristique', 'euismod', 'est', 'fusce', 'volutpat',
		'enim', 'lacinia', 'hendrerit', 'accumsan', 'mollis', 'imperdiet', 'tempor', 'ullamcorper',
		'porttitor', 'diam', 'tellus', 'vestibulum', 'neque', 'sodales', 'class', 'aptent', 'taciti',
		'sociosqu', 'ad', 'litora', 'torquent', 'per', 'conubia', 'nostra', 'inceptos', 'himenaeos',
		'nam', 'auctor', 'phasellus', 'eleifend', 'ultricies', 'dignissim', 'rutrum']
)

struct CommitOpts {
	include_body bool
	wrap_text    bool
}

fn get_ipsum_word() string {
	return lorem_ipsum[rand.i64n(lorem_ipsum.len)]
}

fn gen_message() string {
	// we want a bit of "garbage" to test if the char escape filters are working properly
	scrambled_eggs := rand.ascii(24)

	mut words := []string{}
	t := rand.u32_in_range(3, 9)
	for i := 0; i < t; i++ {
		// 1 in 7 times chance of adding a comma
		comma := if rand.u32n(6) == 0 { ',' } else { '' }
		words << get_ipsum_word() + comma
	}

	mut phrase := words.join(' ')
	if phrase.len > 79 {
		phrase = phrase.substr(0, 79)
	}

	if phrase.ends_with(',') {
		phrase = phrase.substr(0, phrase.len - 2)
	}

	return '$scrambled_eggs $phrase'
}

fn concat_body(words []string) string {
	return words
		.join(' ')
		.add('.')
		.split('\n')
		.map(fn (w string) string { return w.trim(' ') })
		.join('\n')
}

fn gen_body(wrap_text bool) string {
	mut body := []string{}
	body << get_ipsum_word().capitalize()

	if !wrap_text {
		t := rand.u32_in_range(16, 32)
		for i := 0; i < t; i++ {
			body << get_ipsum_word()
		}

		return concat_body(body)
	}

	mut c := 0
	t := rand.u32_in_range(32, 64)
	for i := 0; i < t; i++ {
		word := get_ipsum_word()
		len  := word.len + 1

		c += len
		if c <= 60 {
			body << word
			continue
		}

		body << '$word\n'
		c = 0
	}

	return concat_body(body)
}

fn exec(cmd string) ?string {
	res := os.execute(cmd)
	if res.exit_code != 0 {
		return error(res.output)
	}

	return res.output
}

fn do_commit(opts CommitOpts) ?(string, string) {
	msg_file := os.join_path(os.getwd(), 'commit.txt')
	mut msg := gen_message()

	if opts.include_body {
		msg += '\n\n${gen_body(opts.wrap_text)}'
	}

	os.write_file(msg_file, msg) or {
		return error('could not write file "$msg_file", got: $err.msg')
	}

	exec('git commit --allow-empty --file $msg_file') or {
		return error('could not commit, got: $err.msg')
	}

	os.rm(msg_file) or {
		return error('could not remove file "$msg_file"; got: $err.msg')
	}

	hash := exec('git rev-parse HEAD') or {
		return error('could not retrieve last commit; got: $err.msg')
	}

	return hash, msg
}

fn add_tag() ?string {
	tag := rand.hex(32)
	exec('git tag $tag') or {
		return error('could not add tag "$tag"')
	}

	return tag
}

fn err_m(txt string) string {
	return term.bright_red(term.bold(txt))
}

fn suc_m(txt string) string {
	return term.bright_green(term.bold(txt))
}

fn do_it(opts CommitOpts) {
	hash, msg := do_commit(opts) or { panic(err_m(err.msg)) }

	hc := term.bold('[${hash.substr(0, 7)}]')
	m := if msg.len > 99 { msg.replace('\n', ' ').substr(0, 99) } else { msg }

	println(' * ${term.bright_cyan('COMMITED:')} $hc $m')
}

fn main() {
	commits_t := rand.u32_in_range(10, 20)

	println('')
	for i := 0; i < commits_t; i++ {
		do_it(CommitOpts{})
	}

	do_it(CommitOpts{ include_body: true, wrap_text: true })

	tag := add_tag() or { panic(err_m(err.msg)) }
	println(
		'\n'
		+ suc_m(' > commited $commits_t times\n')
		+ suc_m(' > closed at tag $tag\n')
	)

}
