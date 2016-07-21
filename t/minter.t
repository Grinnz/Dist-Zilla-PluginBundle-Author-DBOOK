use strict;
use warnings;
use Git::Wrapper;
use Path::Tiny;
use Test::More;
use Test::DZil;

eval { Git::Wrapper->new(Path::Tiny->cwd)->version; 1 } or plan skip_all => 'git is not available for testing';

use Test::File::ShareDir::Module { 'Dist::Zilla::MintingProfile::Author::DBOOK' => 'profiles' };

my $tzil = Minter->_new_from_profile(
  [ 'Author::DBOOK' => 'default' ],
  { name => 'DZT-Minty' },
  { global_config_root => 't/minter/global' },
);

$tzil->mint_dist;

my @expected_files = sort qw(
  .gitignore
  .travis.yml
  Changes
  cpanfile
  dist.ini
  LICENSE
  lib/DZT/Minty.pm
);

my $mint_dir = path($tzil->tempdir)->child('mint');
my @found_files;
my $iter = $mint_dir->iterator({ recurse => 1 });
while (my $path = $iter->()) {
  next if $path =~ m!\.git/!;
  push @found_files, $path->relative($mint_dir)->stringify if -f $path;
}

is_deeply [sort @found_files], \@expected_files, 'minted the correct files';

my $pm = $tzil->slurp_file('mint/lib/DZT/Minty.pm');
my $distini = $tzil->slurp_file('mint/dist.ini');
my $gitignore = $tzil->slurp_file('mint/.gitignore');
my $travisyml = $tzil->slurp_file('mint/.travis.yml');
my $changes = $tzil->slurp_file('mint/Changes');

like $pm, qr/^package DZT::Minty;$/m, 'right package declaration';
like $pm, qr/^use strict;$/m, 'module uses strict';
like $pm, qr/^use warnings;$/m, 'module uses warnings';
like $pm, qr/^our \$VERSION = '0\.001';$/m, 'module version is set';
like $pm, qr/^=head1 NAME\n\nDZT::Minty - /m, 'right name section in pod';

like $distini, qr/^name\s*=\s*DZT-Minty$/m, 'right dist name';
like $distini, qr/^\[\@Author::DBOOK\]$/m, 'author bundle included';

like $gitignore, qr/^\/DZT-Minty-\*$/m, 'builds ignored in git';

like $travisyml, qr/^language:\s*perl$/m, 'travis configured for perl';

like $changes, qr/^\{\{\$NEXT\}\}$/m, 'changes file set up';

done_testing;
