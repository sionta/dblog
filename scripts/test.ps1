Push-Location "$PSScriptRoot/.."
& bundle exec jekyll clean
& bundle exec jekyll serve --watch --config '_config.yml,_config.dev.yml' $args
Pop-Location
