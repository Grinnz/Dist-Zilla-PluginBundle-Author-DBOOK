use Test::More tests => 2;
use_ok('Dist::Zilla::PluginBundle::Author::DBOOK');
diag("Dist::Zilla::PluginBundle::Author::DBOOK version $Dist::Zilla::PluginBundle::Author::DBOOK::VERSION");
use_ok('Dist::Zilla::MintingProfile::Author::DBOOK');
diag("Dist::Zilla::MintingProfile::Author::DBOOK version $Dist::Zilla::MintingProfile::Author::DBOOK::VERSION");
