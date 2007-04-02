require 'rake'
require 'rake/packagetask'
require 'rake/rdoctask'
require 'find'

readme = File.read("README").gsub("\r\n", "\n")
author_line = readme[/^\*\s*Author:.+$/].split(/\s+/, 2)[1] rescue nil

# Manual globals

PKG_AUTOREQUIRE = nil
PKG_RUBY_VERSION = '>= 1.8.4'
PKG_GEM_DEPENDENCIES = {}
PKG_RDOC_FILES = ['README', 'NEWS']
PKG_RDOC_OPTIONS = %w(--all --main README --title #{PKG_NAME})
PKG_FILES = PKG_RDOC_FILES + ['COPYING', 'setup.rb', 'Rakefile']

# Automatic globals

PKG_NAME, PKG_VERSION = *File.read("NEWS")[/^==.+$/].split(/\s+/)[1..2]
PKG_DESCRIPTION = readme.split(/\n{3,}/)[0].sub(/^=.+$\s*/, "") rescue nil
PKG_SUMMARY = readme[/^=.+$/].split(/--/)[1].strip rescue PKG_DESCRIPTION
PKG_HOMEPAGE = readme[/^\*\s*Homepage:.+$/].split(/\s+/, 2)[1] rescue nil
PKG_EMAIL = author_line[/<(.+)>/, 1] rescue nil
PKG_AUTHOR = author_line.sub(PKG_EMAIL, "").sub("<>", "").strip rescue nil

Find.find('lib/', 'test/', 'bin/') do |file|
  if FileTest.directory?(file) and file[/\.svn/i] then
    Find.prune
  elsif !file[/\.DS_Store/i] then
    PKG_FILES << file
  end
end

PKG_FILES.reject! { |file| !File.file?(file) }

PKG_EXE_FILES, PKG_LIB_FILES = *%w(bin/ lib/).map do |dir|
  PKG_FILES.grep(/#{dir}/i).reject { |f| File.directory?(f) }
end

PKG_EXE_FILES.map! { |exe| exe.sub(%r(^bin/), "") }

# Tasks

task :default => :test

# Test task
if File.exist?("test/") then
  require 'rake/testtask'
  
  Rake::TestTask.new do |test|
    test.test_files = ['test/tc_all.rb']
  end
else
  task :test do
    puts "No tests to run"
  end
end

# Doc task
Rake::RDocTask.new do |rd|
  rd.rdoc_files.include(PKG_LIB_FILES, PKG_RDOC_FILES)
  rd.options += PKG_RDOC_OPTIONS
end

# Tar task
Rake::PackageTask.new(PKG_NAME, PKG_VERSION) do |pkg|
  pkg.need_tar = true
  pkg.package_files = PKG_FILES
end

# Gem task
begin
  require 'rake/gempackagetask'

  spec = Gem::Specification.new do |spec|
    spec.name = PKG_NAME
    spec.version = PKG_VERSION
    spec.summary = PKG_SUMMARY 
    spec.description = PKG_DESCRIPTION
    
    spec.homepage = PKG_HOMEPAGE
    spec.email = PKG_EMAIL
    spec.author = PKG_AUTHOR

    spec.has_rdoc = true
    spec.extra_rdoc_files = PKG_RDOC_FILES
    spec.rdoc_options += PKG_RDOC_OPTIONS

    if File.exist?("test/") then
      spec.test_files = ['test/tc_all.rb']
    end

    spec.required_ruby_version = PKG_RUBY_VERSION
    (PKG_GEM_DEPENDENCIES || {}).each do |name, version|
      spec.add_dependency(name, version)
    end
    
    spec.files = PKG_FILES
    spec.executables = PKG_EXE_FILES
    spec.autorequire = PKG_AUTOREQUIRE
  end

  Rake::GemPackageTask.new(spec) do |pkg|
    pkg.need_zip = true
    pkg.need_tar = true
  end
rescue LoadError
end
