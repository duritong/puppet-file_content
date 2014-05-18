require 'bundler'
Bundler.require(:rake)

require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'

PuppetLint.configuration.ignore_paths = ["spec/**/*.pp", "vendor/**/*.pp"]
PuppetLint.configuration.log_format = '%{path}:%{linenumber}:%{KIND}: %{message}'
PuppetLint.configuration.send("disable_class_inherits_from_params_class")

# use librarian-puppet to manage fixtures instead of .fixtures.yml
# offers more possibilities like explicit version management, forge downloads,...
task :librarian_spec_prep do
  sh "librarian-puppet install --path=spec/fixtures/modules/"
  pwd = `pwd`.strip
  unless File.directory?("#{pwd}/spec/fixtures/modules/file_content")
    sh "ln -s #{pwd} #{pwd}/spec/fixtures/modules/file_content"
  end
end
task :spec_prep => :librarian_spec_prep


task :default => [:spec, :lint]
