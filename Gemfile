# frozen_string_literal: true

source "https://rubygems.org"
gemspec

# If you have any plugins, put them here!
group :jekyll_plugins do
  gem "jemoji", "~> 0.13.0"
  gem "jekyll-gist", "~> 1.5.0"
  gem "jekyll-sitemap", "~> 1.4.0"
  gem "jekyll-paginate", "~> 1.1.0"
  gem "jekyll-redirect-from", "~> 0.16.0"
  gem "kramdown-math-katex", "~> 1.0.1"
end

# Windows and JRuby does not include zoneinfo files, so bundle the tzinfo-data gem
# and associated library.
platforms :mingw, :x64_mingw, :mswin, :jruby do
  gem "tzinfo", ">= 1", "< 3"
  gem "tzinfo-data"
end

# Performance-booster for watching directories on Windows
gem "wdm", ">= 0.1.0" if Gem.win_platform?

# Lock `http_parser.rb` gem to `v0.6.x` on JRuby builds since newer versions of the gem
# do not have a Java counterpart.
gem "http_parser.rb", "~> 0.6.0", :platforms => [:jruby]
