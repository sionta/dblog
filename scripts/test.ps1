Push-Location "$PSScriptRoot/.."
$watch = @(
    '--watch',
    '--config',
    "'_config.yml,_config.dev.yml'",
    $args
)

Write-Host 'bundle exec jekyll clean'
& bundle exec jekyll clean

Write-Host 'bundle exec jekyll serve' @watch
& bundle exec jekyll serve @watch

Pop-Location
