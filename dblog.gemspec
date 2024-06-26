# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "dblog"
  spec.version       = "0.1.0"
  spec.authors       = ["Andre Attamimi"]
  spec.email         = ["73837775+sionta@users.noreply.github.com"]

  spec.summary       = "Write a short summary, because Rubygems requires one."
  spec.homepage      = "https://github.com/sionta/dblog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_data|_layouts|_includes|_sass|LICENSE|README|_config\.yml)!i) }

  spec.add_runtime_dependency "jekyll", "~> 4.3"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.17"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.8"
end
