# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'mina/unicorn/version'

Gem::Specification.new do |spec|
  spec.name          = 'mina-unicorn_systemd'
  spec.version       = Mina::Unicorn::VERSION
  spec.authors       = ['coezbek']
  spec.email         = ['c.oezbek@gmail.com']
  spec.summary       = %(Mina tasks for Unicorn setup and deployment.)
  spec.description   = %(Mina-deploy tasks to enable easy setup and deployment of unicorn application server managed via systemd)
  spec.homepage      = 'https://github.com/hbin/mina-unicorn_systemd.git'
  spec.license       = 'MIT'

  spec.files         = `git ls-files`.split($RS)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'mina'

  spec.add_development_dependency 'bundler', '~> 1.5'
  spec.add_development_dependency 'rake', '~> 0'
end
