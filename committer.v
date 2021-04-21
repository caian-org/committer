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

fn get_ipsum_word() string {
	return lorem_ipsum[rand.i64n(lorem_ipsum.len)]
}

fn gen_message() string {
	// we want a bit of "garbage" to test if the char escape filters are working properly
	scrambled_eggs := rand.ascii(32)

	mut words := []string{}
	t := rand.u32_in_range(3, 9)
	for i := 0; i < t; i++ {
		// 1 in 7 times change of adding a comma
		comma := if rand.u32n(6) == 0 { ',' } else { '' }
		words << get_ipsum_word() + comma
	}

	mut phrase := words.join(' ')
	if phrase.ends_with(',') {
		phrase = phrase.substr(0, phrase.len - 2)
	}

	return '$scrambled_eggs $phrase'
}

fn exec(cmd string) ?string {
	res := os.execute(cmd)
	if res.exit_code != 0 {
		return error(res.output)
	}

	return res.output
}

fn do_commit() ?(string, string) {
	msg_file := os.join_path(os.getwd(), 'commit.txt')
	msg := gen_message()

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

fn main() {
	commits_t := rand.u32_in_range(10, 20)

	println('')
	for i := 0; i < commits_t; i++ {
		git_hash, git_msg := do_commit() or { panic(err_m(err.msg)) }

		hc := term.bold('[${git_hash.substr(0, 7)}]')
		println(
			' * ${term.bright_cyan('COMMITED:')} $hc $git_msg'
		)
	}

	tag := add_tag() or { panic(err_m(err.msg)) }
	println(
		'\n'
		+ suc_m(' > commited $commits_t times\n')
		+ suc_m(' > closed at tag $tag\n')
	)

}
