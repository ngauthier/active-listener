# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{active-listener}
  s.version = "0.2.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Nick Gauthier"]
  s.date = %q{2009-01-29}
  s.default_executable = %q{active-listener}
  s.description = %q{TODO}
  s.email = %q{nick@smartlogicsolutions.com}
  s.executables = ["active-listener"]
  s.files = ["VERSION.yml", "README.html", "README.markdown", "bin/active-listener", "lib/activelistener", "lib/active-listener.rb", "test/test_helper.rb", "test/active_listener.log", "test/active_listener.pid", "test/active_listener.yml", "test/active_listener_test.rb"]
  s.has_rdoc = true
  s.homepage = %q{http://github.com/ngauthier/active-listener}
  s.rdoc_options = ["--inline-source", "--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{TODO}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 2

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
