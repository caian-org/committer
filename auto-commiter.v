module main

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

fn get_commit_msg() string {
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

fn main() {
	commits_t := rand.u32_in_range(20, 60)

	for i := 0; i < commits_t; i++ {
		println(get_commit_msg())
	}
}
