Gem::Specification.new do |s|
  s.name        = 'samanage'
  s.version     = '1.5.4'
  s.date        = '2017-01-01'
  s.summary     = "Samanage Ruby Gem"
  s.description = "Connect to Samanage using Ruby!"
  s.authors     = ["Chris Walls"]
  s.email       = 'cwalls2908@gmail.com'
  s.files       = `git ls-files`.split("\n")
  s.require_paths = ["lib"]
  s.add_development_dependency 'http', ['~> 2.2']
  s.add_runtime_dependency 'http', ["~> 2.2"]
  s.homepage    = 'http://rubygems.org/gems/samanage'
  s.license     = 'MIT'
end