Push-Location "$PSScriptRoot/.."
& bundle exec jekyll clean
& bundle exec jekyll serve --watch --trace --config '_config.yml,_config.dev.yml' $args
Pop-Location
