package Dist::Zilla::PluginBundle::Author::DBOOK;

use Moose;
use Scalar::Util 'blessed';
with 'Dist::Zilla::Role::PluginBundle::Easy', 'Dist::Zilla::Role::PluginBundle::Config::Slicer';

our $VERSION = '0.019';

sub configure {
	my $self = shift;
	
	my %accepted_installers = map { ($_ => 1) }
		qw(MakeMaker MakeMaker::Awesome ModuleBuildTiny ModuleBuildTiny::Fallback);
	my $installer = $self->payload->{installer} // 'MakeMaker';
	unless (exists $accepted_installers{$installer}) {
		die "Invalid installer $installer. Possible installers: " .
			join(', ', sort keys %accepted_installers) . "\n";
	}
	
	my $user = $self->payload->{github_user} // 'Grinnz';
	$self->add_plugins([GithubMeta => { issues => 1, user => $user }]);
	$self->add_plugins([ReadmeAnyFromPod => 'Readme_Github' => { type => 'pod', filename => 'README.pod', location => 'root' }]);
	$self->add_plugins('MetaProvides::Package', 'Prereqs::FromCPANfile', 'Git::Contributors');
	$self->add_plugins([MetaNoIndex => { directory => [ qw/t xt inc share eg examples/ ] }]);
	# Add this bundle as develop requires
	$self->add_plugins([Prereqs => 'Self_Prereq' => { -phase => 'develop', (blessed $self) => $self->VERSION }]);
	
	my @from_release = qw(LICENSE META.json);
	if ($installer =~ /^ModuleBuild/) {
		push @from_release, 'Build.PL';
	} else {
		push @from_release, 'Makefile.PL';
	}
	my @installer_files = qw(Build.PL Makefile.PL);
	my @dirty_files = qw(dist.ini Changes README.pod);
	my $versioned_match = '^(?:lib|script|bin)/';
	
	# @Git and versioning
	$self->add_plugins(
		'CheckChangesHasContent',
		['Git::Check' => { allow_dirty => \@dirty_files }],
		'RewriteVersion',
		[NextRelease => { format => '%-9v %{yyyy-MM-dd HH:mm:ss VVV}d%{ (TRIAL RELEASE)}T' }],
		[CopyFilesFromRelease => { filename => \@from_release }],
		['Git::Commit' => { allow_dirty => [@dirty_files, @from_release], allow_dirty_match => $versioned_match, add_files_in => '/' }],
		'Git::Tag',
		[BumpVersionAfterRelease => { munge_makefile_pl => 0 }],
		['Git::Commit' => 'Commit_Version_Bump' => { allow_dirty_match => $versioned_match, commit_msg => 'Bump version' }],
		'Git::Push');
	
	# Pod tests
	if ($self->payload->{pod_tests}) {
		$self->add_plugins('PodSyntaxTests');
		$self->add_plugins('PodCoverageTests') unless $self->payload->{pod_tests} eq 'syntax';
	}
	
	$self->add_plugins(['Git::GatherDir' => { exclude_filename => [@installer_files, @from_release] }]);
	# @Basic, with some modifications
	$self->add_plugins(qw/PruneCruft ManifestSkip MetaYAML MetaJSON
		License ReadmeAnyFromPod ExtraTests ExecDir ShareDir/);
	$self->add_plugins([ExecDir => 'ScriptDir' => { dir => 'script' }]);
	$self->add_plugins($installer);
	$self->add_plugins(qw/Manifest TestRelease ConfirmRelease/);
	$self->add_plugins($ENV{FAKE_RELEASE} ? 'FakeRelease' : 'UploadToCPAN');
}

1;

=head1 NAME

Dist::Zilla::PluginBundle::Author::DBOOK - A plugin bundle for distributions
built by DBOOK

=head1 SYNOPSIS

 [@Author::DBOOK]
 pod_tests = 1
 installer = MakeMaker::Awesome
 MakeMaker::Awesome.test_file[] = t/*.t
 Git::GatherDir.exclude_filename[0] = bad_file
 Git::GatherDir.exclude_filename[1] = another_file

=head1 DESCRIPTION

This is the plugin bundle that DBOOK uses. It is equivalent to:

 [GithubMeta]
 issues = 1
 user = Grinnz
 
 [ReadmeAnyFromPod / Readme_Github]
 type = pod
 filename = README.pod
 location = root
 
 [MetaProvides::Package]
 [Prereqs::FromCPANfile]
 [Git::Contributors]
 [MetaNoIndex]
 directory = t
 directory = xt
 directory = inc
 directory = share
 directory = eg
 directory = examples
 
 [Prereqs / Self_Prereq]
 -phase = develop
 Dist::Zilla::PluginBundle::Author::DBOOK = $VERSION
 
 [CheckChangesHasContent]
 [Git::Check]
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod
 [RewriteVersion]
 [NextRelease]
 format = %-9v %{yyyy-MM-dd HH:mm:ss VVV}d%{ (TRIAL RELEASE)}T
 [CopyFilesFromRelease]
 filename = LICENSE
 filename = META.json
 filename = Makefile.PL
 [Git::Commit]
 add_files_in = /
 allow_dirty_match = ^(?:lib|script|bin)/
 allow_dirty = dist.ini
 allow_dirty = Changes
 allow_dirty = README.pod
 allow_dirty = LICENSE
 allow_dirty = META.json
 allow_dirty = Makefile.PL
 [Git::Tag]
 [BumpVersionAfterRelease]
 munge_makefile_pl = 0
 [Git::Commit / Commit_Version_Bump]
 allow_dirty_match = ^(?:lib|script|bin)/
 commit_msg = Bump version
 [Git::Push]
 
 [Git::GatherDir]
 exclude_filename = LICENSE
 exclude_filename = META.json
 exclude_filename = Makefile.PL
 exclude_filename = Build.PL
 [PruneCruft]
 [ManifestSkip]
 [MetaYAML]
 [MetaJSON]
 [License]
 [ReadmeAnyFromPod]
 [ExtraTests]
 [ExecDir]
 [ExecDir / ScriptDir]
 dir = script
 [ShareDir]
 [MakeMaker]
 [Manifest]
 [TestRelease]
 [ConfirmRelease]
 [UploadToCPAN]

This bundle assumes that your git repo has the following: a L<cpanfile> with
the dist's prereqs, a C<Changes> populated for the current version (see
L<Dist::Zilla::Plugin::NextRelease>), and a C<.gitignore> including
C<Name-Of-Dist-*> but not C<Makefile.PL>/C<Build.PL> or C<META.json>.

To test releasing, set the env var C<FAKE_RELEASE=1> to run everything except
the upload to CPAN.

 $ FAKE_RELEASE=1 dzil release

=head1 OPTIONS

This bundle composes the L<Dist::Zilla::Role::PluginBundle::Config::Slicer>
role, so options for any included plugin may be specified in that format.
Additionally, the following options are provided.

=head2 github_user

 github_user = gitster

Set the user whose repository should be linked in metadata. Defaults to
C<Grinnz>, change this when the main repository is elsewhere.

=head2 installer

 installer = MakeMaker::Awesome
 MakeMaker::Awesome.WriteMakefile_arg[] = (clean => { FILES => 'autogen.dat' })
 MakeMaker::Awesome.delimiter = |
 MakeMaker::Awesome.footer[00] = |{
 MakeMaker::Awesome.footer[01] = |  ...
 MakeMaker::Awesome.footer[20] = |}

 installer = ModuleBuildTiny
 ModuleBuildTiny.version_method = installed

Set the installer plugin to use. Allowed installers are
L<MakeMaker|Dist::Zilla::Plugin::MakeMaker>,
L<MakeMaker::Awesome|Dist::Zilla::Plugin::MakeMaker::Awesome>,
L<ModuleBuildTiny|Dist::Zilla::Plugin::ModuleBuildTiny>, and
L<ModuleBuildTiny::Fallback|Dist::Zilla::Plugin::ModuleBuildTiny::Fallback>.
The default is C<MakeMaker>. Options for the selected installer can be
specified using config slicing.

=head2 pod_tests

 pod_tests = 1

Set to a true value to add L<Dist::Zilla::Plugin::PodSyntaxTests> and
L<Dist::Zilla::Plugin::PodCoverageTests>. Set to C<syntax> to only add the
syntax tests.

=head1 BUGS

Report any issues on the public bugtracker.

=head1 AUTHOR

Dan Book, C<dbook@cpan.org>

=head1 COPYRIGHT AND LICENSE

Copyright 2015, Dan Book.

This library is free software; you may redistribute it and/or modify it under
the terms of the Artistic License version 2.0.

=head1 SEE ALSO

L<Dist::Zilla>, L<cpanfile>, L<Dist::Zilla::MintingProfile::Author::DBOOK>
