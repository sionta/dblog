# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = "dblog"
  spec.version       = "0.1.0"
  spec.authors       = ["Andre Attamimi"]
  spec.email         = ["rumatua0@gmail.com"]

  spec.summary       = "dblog is just a blog or data blog"
  spec.homepage      = "https://github.com/sionta/dblog"
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").select { |f| f.match(%r!^(assets|_data|_layouts|_includes|_sass|LICENSE|README|_config\.yml)!i) }

  spec.required_ruby_version = ">= 3.0" # 3.2.4-1
  spec.add_runtime_dependency "jekyll", "~> 4.3"
  spec.add_runtime_dependency "jekyll-feed", "~> 0.17"
  spec.add_runtime_dependency "jekyll-seo-tag", "~> 2.8"
end
