requires 'perl' => '5.010';
requires 'Dist::Zilla';
requires 'Dist::Zilla::PluginBundle::Git';
requires 'Dist::Zilla::Plugin::GithubMeta';
requires 'Dist::Zilla::Plugin::ReadmeAnyFromPod';
requires 'Dist::Zilla::Plugin::MetaProvides::Package';
requires 'Dist::Zilla::Plugin::RewriteVersion';
requires 'Dist::Zilla::Plugin::NextRelease';
requires 'Dist::Zilla::Plugin::BumpVersionAfterRelease';
requires 'Dist::Zilla::Plugin::MetaJSON';
requires 'Dist::Zilla::Plugin::MakeMaker::Awesome';
requires 'Dist::Zilla::Plugin::Prereqs::FromCPANfile';
requires 'Dist::Zilla::Plugin::CopyFilesFromBuild';
requires 'Moose';
test_requires 'Test::More' => '0.88';
