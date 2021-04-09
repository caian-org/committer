module main

import os
import rand


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

fn exec(cmd string) ? {
	res := os.execute(cmd)
	if res.exit_code != 0 {
		return error(res.output)
	}
}

fn do_commit() ? {
	msg_file := os.join_path(os.getwd(), 'commit.txt')
	msg := gen_message()

	os.write_file(msg_file, msg) or {
		return error('could not write on file "$msg_file", got: $err.msg')
	}

	exec('git commit --allow-empty --file $msg_file') or {
		return error('could not commit, got: $err.msg')
	}

	os.rm(msg_file) or {
		return error('could not remove file "$msg_file"; got: $err.msg')
	}
}


fn main() {
	commits_t := rand.u32_in_range(2, 6)

	for i := 0; i < commits_t; i++ {
		do_commit() or { panic(err.msg) }
	}
}
