requires 'perl' => '5.010';
requires 'Dist::Zilla';
requires 'Dist::Zilla::Plugin::Git::Check';
requires 'Dist::Zilla::Plugin::Git::Commit';
requires 'Dist::Zilla::Plugin::Git::Tag';
requires 'Dist::Zilla::Plugin::Git::Push';
requires 'Dist::Zilla::Plugin::Git::GatherDir';
requires 'Dist::Zilla::Plugin::GithubMeta';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';
requires 'Dist::Zilla::Plugin::MetaProvides::Package';
requires 'Dist::Zilla::Plugin::RewriteVersion';
requires 'Dist::Zilla::Plugin::NextRelease';
requires 'Dist::Zilla::Plugin::BumpVersionAfterRelease';
requires 'Dist::Zilla::Plugin::Prereqs';
requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::CopyFilesFromRelease';
requires 'Dist::Zilla::Plugin::CheckChangesHasContent';
requires 'Dist::Zilla::Plugin::PruneCruft';
requires 'Dist::Zilla::Plugin::ManifestSkip';
requires 'Dist::Zilla::Plugin::MetaYAML';
requires 'Dist::Zilla::Plugin::MetaJSON';
requires 'Dist::Zilla::Plugin::License';
requires 'Dist::Zilla::Plugin::Readme';
requires 'Dist::Zilla::Plugin::ExtraTests';
requires 'Dist::Zilla::Plugin::ExecDir';
requires 'Dist::Zilla::Plugin::ShareDir';
requires 'Dist::Zilla::Plugin::MakeMaker';
requires 'Dist::Zilla::Plugin::MakeMaker::Awesome';
requires 'Dist::Zilla::Plugin::Manifest';
requires 'Dist::Zilla::Plugin::TestRelease';
requires 'Dist::Zilla::Plugin::ConfirmRelease';
requires 'Dist::Zilla::Plugin::UploadToCPAN';
requires 'Moose';
requires 'Scalar::Util';
test_requires 'Test::More' => '0.88';
