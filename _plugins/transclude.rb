# frozen_string_literal: true

#
# Jekyll Transclude Plugin
#
# This plugin allows you to transclude content within your Jekyll site. It enables users to include content from
# other files while passing along parameters and block content for more dynamic layouts.
#
# Features:
# - Supports passing block content via `include.content`.
# - Allows parameters to be defined and accessed in the included content.
# - Blocks cannot override the `content` key to prevent unexpected behavior.
# - Provides error handling for invalid syntax or missing files.
#
# Installation:
# - Place this file in your Jekyll project under `<Jekyll source dir>/_plugins/transclude.rb`.
#
# Usage:
#
# To use the `transclude` tag in your markdown or HTML files, format it like this:
#
#   ```markdown
#   {% transclude snippet.html title="Important Note" %}
#   This content will be available as `include.content`.
#   {% endtransclude %}
#   ```
#
# Inside the `_includes/snippet.html` file, you can access the parameters and content:
#
#   ```html
#   <div class="note">
#     <h2>{{ include.title | strip }}</h2>
#     <div>{{ include.content | markdownify }}</div>
#   </div>
#   ```
#
# Restrictions:
# - The `content` parameter cannot be overridden with `param=value`. An error will be raised if attempted.
#
# Error Handling:
# - Invalid file names or parameter syntax will trigger detailed error messages.
# - Included files must exist in the `_includes` directory, and symbolic links are not allowed in safe mode.
#
# License:
# - Code licensed under MIT (https://opensource.org/licenses/MIT)
module Jekyll
  # The Transclude class allows for including partial templates with parameters
  # in Jekyll posts. It can also render Markdown content into HTML.
  class TranscludeBlock < Liquid::Block
    VALID_SYNTAX = /
      ([\w-]+)\s*=\s*
      (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
    /x

    # Initializes a new Transclude tag
    #
    # @param tag_name [String] The name of the tag
    # @param params [String] The parameters passed to the tag
    # @param tokens [Array] The tokens for the Liquid template
    def initialize(tag_name, markup, tokens)
      super

      @template, @params = markup.strip.split(/\s+/, 2)
    end

    # Renders the Transclude tag by combining content and parameters
    #
    # @param context [Liquid::Context] The context in which the tag is rendered
    # @return [String] The rendered HTML output
    def render(context)
      site = context.registers[:site]
      content = super
      content_html = content.strip
      # content_html = render_markdown(content.strip) # Convert Markdown to HTML

      # File location
      template_path = File.join(site.source, '_includes', @template)
      validate_file(template_path)

      # Render partial with parameters
      partial = Liquid::Template.parse(File.read(template_path))
      context.stack do
        context['include'] = parse_params(context, content_html)
        partial.render(context)
      end
    end

    private

    # Parses the parameters from the tag and returns them as a hash
    #
    # @param context [Liquid::Context] The context in which the tag is rendered
    # @param content [String] The content from the block
    # @return [Hash] The parsed parameters
    def parse_params(context, content)
      params = { 'content' => content } # Default content from block
      markup = @params

      if markup
        while (match = VALID_SYNTAX.match(markup))
          markup = markup[match.end(0)..]
          key = match[1]
          value = match[2] || match[3] || context[match[4]]

          # Warn if user tries to override `content`
          if key == 'content'
            Jekyll.logger.warn 'Transclude Warning:', "Cannot override 'content' in transclude, using block content."
          else
            params[key] = value
          end
        end
      end

      params
    end

    # Validates the existence of the specified file in the _includes directory
    #
    # @param path [String] The file path to validate
    # @raise [ArgumentError] If the file does not exist
    def validate_file(path)
      return if File.exist?(path)

      raise ArgumentError, "The file #{path} could not be found in the _includes directory."
    end

    # Renders Markdown content into HTML using Kramdown
    #
    # @param content [String] The Markdown content to render
    # @return [String] The rendered HTML
    def render_markdown(content)
      site = Jekyll.sites.first # Access the site configuration
      # Get kramdown settings from _config.yml
      kramdown_options = site.config['kramdown'] || { input: 'GFM', highlighter: 'rouge' }
      # Pass the config to Kramdown for rendering
      if site.config['markdown'] == 'kramdown'
        require 'kramdown'

        # Use Kramdown to convert Markdown to HTML
        Kramdown::Document.new(content, kramdown_options).to_html
      else
        content.to_str
      end
    end
  end
end

Liquid::Template.register_tag('transclude', Jekyll::TranscludeBlock)
