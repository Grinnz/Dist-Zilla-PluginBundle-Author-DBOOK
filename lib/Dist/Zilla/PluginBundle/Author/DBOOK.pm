package Dist::Zilla::PluginBundle::Author::DBOOK;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

our $VERSION = '0.003';

sub mvp_multivalue_args { qw/mma_WriteMakefile_arg mma_header mma_footer mma_test_file mma_exe_file/ }

sub configure {
	my $self = shift;
	
	my $user = $self->payload->{github_user} // 'Grinnz';
	$self->add_plugins([GithubMeta => { issues => 1, user => $user }]);
	$self->add_plugins([ReadmeAnyFromPod => { type => 'pod', filename => 'README.pod', location => 'root' }]);
	$self->add_plugins('MetaProvides::Package', 'Prereqs::FromCPANfile');
	# Add this bundle as develop requires
	$self->add_plugins([Prereqs => { -phase => 'develop', 'Dist::Zilla::PluginBundle::Author::DBOOK' => $VERSION }]);
	
	my @from_build = qw(LICENSE META.json Makefile.PL);
	my @dirty_files = (@from_build, qw(dist.ini Changes README.pod));
	
	# @Git and versioning
	$self->add_plugins(
		['Git::Check' => { allow_dirty => \@dirty_files }],
		'RewriteVersion',
		[NextRelease => { format => '%-9v %{yyyy-MM-dd HH:mm:ss VVV}d%{ (TRIAL RELEASE)}T' }],
		['Git::Commit' => { allow_dirty => \@dirty_files, allow_dirty_match => '^lib/' }],
		qw/Git::Tag BumpVersionAfterRelease/,
		['Git::Commit' => 'Commit_Version_Bump' => { allow_dirty_match => '^lib/', commit_msg => 'Bump version' }],
		'Git::Push');
	
	$self->add_plugins(['Git::GatherDir' => { exclude_filename => \@from_build }]);
	$self->add_plugins(['CopyFilesFromBuild' => { copy => \@from_build }]);
	
	# @Basic, with some modifications
	$self->add_plugins(qw/PruneCruft ManifestSkip MetaYAML MetaJSON
		License Readme ExtraTests ExecDir ShareDir/);
	if (defined $self->payload->{makemaker} and lc $self->payload->{makemaker} eq 'awesome') {
		my $mma_config = $self->config_slice({
			mma_WriteMakefile_arg => 'WriteMakefile_arg',
			mma_header => 'header',
			mma_footer => 'footer',
			mma_delimiter => 'delimiter',
			mma_test_file => 'test_file',
			mma_exe_file => 'exe_file',
		});
		$self->add_plugins(['MakeMaker::Awesome' => $mma_config]);
	} else {
		$self->add_plugins('MakeMaker');
	}
	$self->add_plugins(qw/Manifest TestRelease ConfirmRelease UploadToCPAN/);
}

1;

=head1 NAME

Dist::Zilla::PluginBundle::Author::DBOOK - A plugin bundle for distributions
built by DBOOK

=head1 SYNOPSIS

 [@Author::DBOOK]
 makemaker = awesome
 mma_test_file = t/*.t

=head1 DESCRIPTION

This is the plugin bundle that DBOOK uses. It is equivalent to:

 [GithubMeta]
 issues = 1
 user = Grinnz
 
 [ReadmeAnyFromPod]
 type = pod
 filename = README.pod
 location = root
 
 [MetaProvides::Package]
 [Prereqs::FromCPANfile]
 [Prereqs]
 -phase = develop
 Dist::Zilla::PluginBundle::Author::DBOOK = $VERSION
 
 [Git::Check]
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod
 allow_dirty = LICENSE
 allow_dirty = META.json
 allow_dirty = Makefile.PL
 [RewriteVersion]
 [NextRelease]
 format = %-9v %{yyyy-MM-dd HH:mm:ss VVV}d%{ (TRIAL RELEASE)}T
 [Git::Commit]
 allow_dirty_match = ^lib/
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod
 allow_dirty = LICENSE
 allow_dirty = META.json
 allow_dirty = Makefile.PL
 [Git::Tag]
 [BumpVersionAfterRelease]
 [Git::Commit / Commit_Version_Bump]
 allow_dirty_match = ^lib/
 commit_msg = Bump version
 [Git::Push]
 
 [Git::GatherDir]
 exclude_filename = LICENSE
 exclude_filename = META.json
 exclude_filename = Makefile.PL
 [CopyFilesFromBuild]
 copy = LICENSE
 copy = META.json
 copy = Makefile.PL
 [PruneCruft]
 [ManifestSkip]
 [MetaYAML]
 [MetaJSON]
 [License]
 [Readme]
 [ExtraTests]
 [ExecDir]
 [ShareDir]
 [MakeMaker]
 [Manifest]
 [TestRelease]
 [ConfirmRelease]
 [UploadToCPAN]

=head1 OPTIONS

=head2 github_user

 github_user = gitster

Set the user whose repository should be linked in metadata. Defaults to
C<Grinnz>, change this when the main repository is elsewhere.

=head2 makemaker

 makemaker = awesome
 mma_WriteMakefile_arg = (clean => { FILES => 'autogen.dat' })
 mma_delimiter = |
 mma_footer = |{
 mma_footer = |  ...
 mma_footer = |}

Set to C<awesome> to use the L<Dist::Zilla::Plugin::MakeMaker::Awesome> plugin
instead of the basic C<MakeMaker> plugin. Options for C<MakeMaker::Awesome> can
then be specified with the prefix C<mma_>.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book, C<dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015, Dan Book.

This library is free software; you may redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 SEE ALSO

L<Dist::Zilla>, L<Dist::Zilla::Plugin::MakeMaker::Awesome>, L<cpanfile>
