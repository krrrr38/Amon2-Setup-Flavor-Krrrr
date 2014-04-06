use inc::Module::Install;
name 'Amon2-Setup-Flavor-Krrrr';
all_from 'lib/Amon2/Setup/Flavor/Krrrr.pm';

# requires '';

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
