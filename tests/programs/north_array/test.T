
test('north_array',
     [skip_if_fast, extra_clean(['Main.hi', 'Main.o'])],
     multimod_compile_and_run,
     ['Main', ''])

