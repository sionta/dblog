# frozen_string_literal: true

# Based on https://github.com/jekyll/jekyll/blob/master/lib/jekyll/tags/include.rb,
# provides a transclude block that maintains Jekyll include semantics. Files can
# pass parameters to transcludes via the `include` object, with the addition of
# {{ include.content }} which includes the block content.
#
# Transcludes must be located in Jekyll's _includes dir.
#
# Example:
# pythagoras.md:
# In a right-angled triangle the square of the hypotenuse is equal to the sum
# of the squares of the other two sides.
# {% transclude sidenote.html count=1 %}
#   This can be written as a^2 + b^2 = c^2, where [...]
# {% endtransclude %}
#
# _includes/sidenote.html:
# <span class="sidenote">
#   {{ include.count }}. {{ include.content }}
# </span>
#
# Original idea credits go to Corey Megown. See
# - https://github.com/jekyll/jekyll/issues/6789 for their idea
# - https://github.com/cmegown/jekyll-transclude for their proposed syntax
#
# Installation: copy this file to <Jekyll source dir>/_plugins.
#
# Code licensed under MIT (https://opensource.org/licenses/MIT)
module Jekyll
  module Tags
    class Transclude < Liquid::Block
      VALID_SYNTAX = /
        ([\w-]+)\s*=\s*
        (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
      /x

      VARIABLE_SYNTAX = /
        (?<variable>[^{]*(\{\{\s*[\w\-.]+\s*(\|.*)?\}\}[^\s{}]*)+)
        (?<params>.*)
      /mx

      FULL_VALID_SYNTAX = /\A\s*(?:#{VALID_SYNTAX}(?=\s|\z)\s*)*\z/
      VALID_FILENAME_CHARS = %r{^[\w/.-]+$}
      INVALID_SEQUENCES = %r![./]{2,}!

      def initialize(name, params, tokens)
        super
        matched = params.strip.match(VARIABLE_SYNTAX)
        if matched
          @file = matched['variable'].strip
          @params = matched['params'].strip
        else
          @file, @params = params.strip.split(/\s+/, 2)
        end
        validate_params if @params
        @name = name
      end

      def syntax_example
        "{% #{@tag_name} file.ext param='value' param2='value' %}content{% end#{@tag_name} %}"
      end

      def parse_params(context, content)
        params = { 'content' => content }
        markup = @params

        if markup
          while (match = VALID_SYNTAX.match(markup))
            markup = markup[match.end(0)..]

            value = if match[2]
                      match[2].gsub('\\"', '"')
                    elsif match[3]
                      match[3].gsub("\\'", "'")
                    elsif match[4]
                      context[match[4]]
                    end

            params[match[1]] = value
          end
        end

        params
      end

      def validate_file_name(file)
        return unless INVALID_SEQUENCES.match?(file) || !VALID_FILENAME_CHARS.match?(file)

        raise ArgumentError, <<~MSG
          Invalid syntax for transclude tag. File contains invalid characters or sequences:
            #{file}
          Valid syntax:
            #{syntax_example}
        MSG
      end

      def validate_params
        return if FULL_VALID_SYNTAX.match?(@params)

        raise ArgumentError, <<~MSG
          Invalid syntax for transclude tag:
          #{@params}
          Valid syntax:
          #{syntax_example}
        MSG
      end

      # Grab file read opts in the context
      def file_read_opts(context)
        context.registers[:site].file_read_opts
      end

      # Render the variable if required
      def render_variable(context)
        Liquid::Template.parse(@file).render(context) if VARIABLE_SYNTAX.match?(@file)
      end

      def tag_includes_dirs(context)
        context.registers[:site].includes_load_paths.freeze
      end

      def locate_include_file(context, file, safe)
        includes_dirs = tag_includes_dirs(context)
        includes_dirs.each do |dir|
          path = PathManager.join(dir, file)
          return path if valid_include_file?(path, dir.to_s, safe)
        end
        raise IOError, could_not_locate_message(file, includes_dirs, safe)
      end

      def render(context)
        site = context.registers[:site]

        file = render_variable(context) || @file
        validate_file_name(file)

        path = locate_include_file(context, file, site.safe)
        return unless path

        add_include_to_dependency(site, path, context)

        partial = load_cached_partial(path, context)

        context.stack do
          context['include'] = parse_params(context, super)
          begin
            partial.render!(context)
          rescue Liquid::Error => e
            e.template_name = path
            e.markup_context = 'transcluded ' if e.markup_context.nil?
            raise e
          end
        end
      end

      def add_include_to_dependency(site, path, context)
        return unless context.registers[:page]&.key?('path')

        site.regenerator.add_dependency(
          site.in_source_dir(context.registers[:page]['path']),
          path
        )
      end

      def load_cached_partial(path, context)
        context.registers[:cached_partials] ||= {}
        cached_partial = context.registers[:cached_partials]

        if cached_partial.key?(path)
          cached_partial[path]
        else
          unparsed_file = context.registers[:site]
                                 .liquid_renderer
                                 .file(path)
          begin
            cached_partial[path] = unparsed_file.parse(read_file(path, context))
          rescue Liquid::Error => e
            e.template_name = path
            e.markup_context = 'transcluded ' if e.markup_context.nil?
            raise e
          end
        end
      end

      def valid_include_file?(path, dir, safe)
        !outside_site_source?(path, dir, safe) && File.file?(path)
      end

      def outside_site_source?(path, dir, safe)
        safe && !realpath_prefixed_with?(path, dir)
      end

      def realpath_prefixed_with?(path, dir)
        File.exist?(path) && File.realpath(path).start_with?(dir)
      rescue StandardError
        false
      end

      # This method allows to modify the file content by inheriting from the class.
      def read_file(file, context)
        File.read(file, **file_read_opts(context))
      end

      private

      def could_not_locate_message(file, includes_dirs, safe)
        message = "Could not locate the transcluded file '#{file}' in any of "\
          "#{includes_dirs}. Ensure it exists in one of those directories and"
        message + if safe
                    ' is not a symlink as those are not allowed in safe mode.'
                  else
                    ', if it is a symlink, does not point outside your site source.'
                  end
      end
    end
  end
end

Liquid::Template.register_tag('transclude', Jekyll::Tags::Transclude)
