package Dist::Zilla::PluginBundle::Author::DBOOK;

use Moose;
with 'Dist::Zilla::Role::PluginBundle::Easy';

our $VERSION = '0.001';

sub configure {
	my $self = shift;
	
	$self->add_plugins([GithubMeta => { issues => 1 }]);
	$self->add_plugins([ReadmeAnyFromPod => { type => 'pod', filename => 'README.pod', location => 'root' }]);
	$self->add_plugins('MetaProvides::Package');
	
	if ($self->payload->{fromcpanfile}) { $self->add_plugins('Prereqs::FromCPANfile') }
	else { $self->add_plugins('CPANFile') }
	
	# @Git and versioning
	$self->add_plugins(qw/Git::Check RewriteVersion NextRelease Git::Commit Git::Tag BumpVersionAfterRelease/,
		['Git::Commit' => 'Commit_Version_Bump' => { allow_dirty_match => '^lib/', commit_msg => 'Bump version' }],
		'Git::Push');
	
	# @Basic, with some modifications
	$self->add_plugins(['GatherDir' => { exclude_filename => 'LICENSE' }],
		qw/PruneCruft ManifestSkip MetaYAML MetaJSON License Readme ExtraTests ExecDir ShareDir/);
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
 fromcpanfile = 1
 makemaker = awesome
 mma_test_file = t/*.t

=head1 DESCRIPTION

This is the plugin bundle that DBOOK uses. It is equivalent to:

 [GithubMeta]
 issues = 1
 
 [ReadmeAnyFromPod]
 type = pod
 filename = README.pod
 location = root
 
 [MetaProvides::Package]
 [CPANFile]
 
 [Git::Check]
 [RewriteVersion]
 [NextRelease]
 [Git::Commit]
 [Git::Tag]
 [BumpVersionAfterRelease]
 [Git::Commit / Commit_Version_Bump]
 allow_dirty_match = ^lib/
 commit_msg = Bump version
 [Git::Push]
 
 [GatherDir] ; split out to exclude existing license file
 exclude_filename = LICENSE
 [@Basic]
 [MetaJSON]

=head1 OPTIONS

=head2 fromcpanfile

 fromcpanfile = 1

Set to a true value to read prereqs from an existing cpanfile, instead of
writing a cpanfile to the distribution.

=head2 makemaker

 makemaker = awesome

Set to C<awesome> to use the L<Dist::Zilla::Plugin::MakeMaker::Awesome> plugin
instead of the basic C<MakeMaker> plugin. Options for C<MakeMaker::Awesome> can
be specified with the prefix C<mma_>, for example C<mma_WriteMakefile_arg> and
C<mma_header>.

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
