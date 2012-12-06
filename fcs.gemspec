# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run 'rake gemspec'
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = "fcs"
  s.version = "0.1.13"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Tilting @, LLC"]
  s.date = "2012-12-05"
  s.description = ""
  s.email = "steve@tilting.at"
  s.extra_rdoc_files = [
    "LICENSE.txt",
    "README.rdoc"
  ]
  s.files = [
    ".document",
    "Gemfile",
    "LICENSE.txt",
    "README.rdoc",
    "Rakefile",
    "VERSION",
    "fcs.gemspec",
    "features/create_asset.feature",
    "features/fcs.feature",
    "features/step_definitions/fcs_steps.rb",
    "features/support/env.rb",
    "features/support/test.m4v",
    "lib/ext/string.rb",
    "lib/fcs.rb",
    "lib/fcs/asset.rb",
    "lib/fcs/client.rb",
    "lib/fcs/device.rb",
    "lib/fcs/element.rb",
    "lib/fcs/factory.rb",
    "lib/fcs/fcs_entity.rb",
    "lib/fcs/file.rb",
    "lib/fcs/lazy_reader.rb",
    "lib/fcs/multi_tree.rb",
    "lib/fcs/project.rb",
    "lib/ssh/id_dsa",
    "lib/ssh/id_dsa.pub",
    "spec/fcs/client_spec.rb",
    "spec/fcs_spec.rb",
    "spec/spec_helper.rb"
  ]
  s.homepage = "http://github.com/TiltingAt/fcs"
  s.licenses = ["MIT"]
  s.require_paths = ["lib"]
  s.rubygems_version = "1.8.24"
  s.summary = "Final Cut Server offers a command line interface to much of it's functionality.   This gem offers a more ruby'ish interface to that functionality."

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<net-ssh>, [">= 0"])
      s.add_runtime_dependency(%q<net-scp>, [">= 0"])
      s.add_runtime_dependency(%q<erubis>, [">= 0"])
      s.add_runtime_dependency(%q<json>, [">= 0"])
      s.add_runtime_dependency(%q<json_pure>, [">= 0"])
      s.add_runtime_dependency(%q<rubytree>, [">= 0"])
      s.add_runtime_dependency(%q<POpen4>, [">= 0"])
      s.add_runtime_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_development_dependency(%q<shoulda>, [">= 0"])
      s.add_development_dependency(%q<bundler>, [">= 0"])
      s.add_development_dependency(%q<cucumber>, [">= 0"])
      s.add_development_dependency(%q<jeweler>, [">= 0"])
      s.add_development_dependency(%q<rspec>, [">= 0"])
      s.add_development_dependency(%q<rcov>, [">= 0"])
      s.add_development_dependency(%q<rdoc>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug>, [">= 0"])
      s.add_development_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_development_dependency(%q<simplecov>, [">= 0"])
      s.add_development_dependency(%q<sourcify>, [">= 0"])
      s.add_development_dependency(%q<yard>, [">= 0"])
    else
      s.add_dependency(%q<net-ssh>, [">= 0"])
      s.add_dependency(%q<net-scp>, [">= 0"])
      s.add_dependency(%q<erubis>, [">= 0"])
      s.add_dependency(%q<json>, [">= 0"])
      s.add_dependency(%q<json_pure>, [">= 0"])
      s.add_dependency(%q<rubytree>, [">= 0"])
      s.add_dependency(%q<POpen4>, [">= 0"])
      s.add_dependency(%q<libxml-ruby>, [">= 0"])
      s.add_dependency(%q<shoulda>, [">= 0"])
      s.add_dependency(%q<bundler>, [">= 0"])
      s.add_dependency(%q<cucumber>, [">= 0"])
      s.add_dependency(%q<jeweler>, [">= 0"])
      s.add_dependency(%q<rspec>, [">= 0"])
      s.add_dependency(%q<rcov>, [">= 0"])
      s.add_dependency(%q<rdoc>, [">= 0"])
      s.add_dependency(%q<ruby-debug>, [">= 0"])
      s.add_dependency(%q<ruby-debug19>, [">= 0"])
      s.add_dependency(%q<simplecov>, [">= 0"])
      s.add_dependency(%q<sourcify>, [">= 0"])
      s.add_dependency(%q<yard>, [">= 0"])
    end
  else
    s.add_dependency(%q<net-ssh>, [">= 0"])
    s.add_dependency(%q<net-scp>, [">= 0"])
    s.add_dependency(%q<erubis>, [">= 0"])
    s.add_dependency(%q<json>, [">= 0"])
    s.add_dependency(%q<json_pure>, [">= 0"])
    s.add_dependency(%q<rubytree>, [">= 0"])
    s.add_dependency(%q<POpen4>, [">= 0"])
    s.add_dependency(%q<libxml-ruby>, [">= 0"])
    s.add_dependency(%q<shoulda>, [">= 0"])
    s.add_dependency(%q<bundler>, [">= 0"])
    s.add_dependency(%q<cucumber>, [">= 0"])
    s.add_dependency(%q<jeweler>, [">= 0"])
    s.add_dependency(%q<rspec>, [">= 0"])
    s.add_dependency(%q<rcov>, [">= 0"])
    s.add_dependency(%q<rdoc>, [">= 0"])
    s.add_dependency(%q<ruby-debug>, [">= 0"])
    s.add_dependency(%q<ruby-debug19>, [">= 0"])
    s.add_dependency(%q<simplecov>, [">= 0"])
    s.add_dependency(%q<sourcify>, [">= 0"])
    s.add_dependency(%q<yard>, [">= 0"])
  end
end

