# frozen_string_literal: true

Gem::Specification.new do |spec|
  spec.name          = 'dblog'
  spec.version       = '0.1.0'
  spec.authors       = ['Andre Attamimi']
  spec.email         = ['rumatua0@gmail.com']

  spec.summary       = 'A clean and minimalist Jekyll theme tailored for blogger seeking simplicity'
  spec.homepage      = 'https://github.com/sionta/dblog'
  spec.license       = 'MIT'

  spec.files         = `git ls-files -z`.split("\x0").select do |f|
    f.match(/^(assets|_data|_includes|_layouts|_sass|LICENSE|README.md|_config\.yml)/i)
  end

  spec.required_ruby_version = '>= 3.0' # 3.2.4-1
  spec.add_runtime_dependency 'jekyll', '~> 4.3'
  spec.add_runtime_dependency 'jekyll-feed', '~> 0.17'
  spec.add_runtime_dependency 'jekyll-seo-tag', '~> 2.8'
  spec.add_runtime_dependency 'jekyll-sitemap', '~> 1.4'
  # spec.add_runtime_dependency 'nokogiri', '~> 1.16'
end
