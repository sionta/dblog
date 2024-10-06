@echo off

pushd "%~dp0.."
bundle exec jekyll clean
bundle exec jekyll serve --watch --trace --config "_config.yml,_config.dev.yml"
popd
