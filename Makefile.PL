use inc::Module::Install;
name 'Net-TinyIp';
all_from 'lib/Net/TinyIp.pm';
readme_from "lib/Net/TinyIp.pm";

requires "Module::Install::ReadmeFromPod";

tests 't/*.t';
author_tests 'xt';

test_requires 'Test::More';
auto_set_repository;
auto_include;
WriteAll;
