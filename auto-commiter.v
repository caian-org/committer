/*
	The person who associated a work with this deed has dedicated the work to the
	public domain by waiving all of his or her rights to the work worldwide under
	copyright law, including all related and neighboring rights, to the extent
	allowed by law.

	You can copy, modify, distribute and perform the work, even for commercial
	purposes, all without asking permission.

	AFFIRMER OFFERS THE WORK AS-IS AND MAKES NO REPRESENTATIONS OR WARRANTIES OF
	ANY KIND CONCERNING THE WORK, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,
	INCLUDING WITHOUT LIMITATION WARRANTIES OF TITLE, MERCHANTABILITY, FITNESS
	FOR A PARTICULAR PURPOSE, NON INFRINGEMENT, OR THE ABSENCE OF LATENT OR OTHER
	DEFECTS, ACCURACY, OR THE PRESENT OR ABSENCE OF ERRORS, WHETHER OR NOT
	DISCOVERABLE, ALL TO THE GREATEST EXTENT PERMISSIBLE UNDER APPLICABLE LAW.

	For more information, please see
	<http://creativecommons.org/publicdomain/zero/1.0/>
*/

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

	println('\n' + suc_m(' > commited $commits_t times') + '\n')
}
