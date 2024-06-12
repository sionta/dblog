@echo off
chcp 65001
bundle exec jekyll clean && bundle exec jekyll serve --watch --trace --config "%~dp0_config.dev.yml"
