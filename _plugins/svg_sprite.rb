# frozen_string_literal: true

module Jekyll
  # SVGSpriteTag is a custom Liquid tag for rendering SVG symbols from an external SVG sprite file.
  #
  # This tag allows users to insert SVG icons into their Jekyll site easily.
  # Attributes can be passed to customize the output, including the ID of the SVG symbol
  # and additional SVG attributes.
  #
  # ## Usage
  #
  # You can use this tag in your Liquid templates like this:
  #
  # ```liquid
  # {% assign myid = 'sun' %}
  # <span data-theme-value="light">{%- svg_sprite id=myid class='custom-class' -%}</span>
  # ```
  #
  # ## Output
  #
  # Given the above usage, if the SVG sprite file contains a symbol with the ID `sun`, the rendered output would be:
  #
  # ```html
  # <span data-theme-value="light">
  #   <svg class="custom-class" width="24" height="24" viewBox="0 0 24 24" aria-hidden="true">
  #     <use href="/assets/icons.svg#sun"></use>
  #   </svg>
  # </span>
  # ```
  #
  # In this example, the `<use>` tag references the `sun` symbol within the SVG sprite file located at `/assets/icons.svg`.
  #
  class SVGSpriteTag < Liquid::Tag
    VALID_SYNTAX = /
      (\w+)\s*=\s*
      (?:"([^"\\]*(?:\\.[^"\\]*)*)"|'([^'\\]*(?:\\.[^'\\]*)*)'|([\w.-]+))
    /x

    # Initializes the SVGSpriteTag.
    #
    # @param tag_name [String] The name of the tag.
    # @param markup [String] The markup string containing attributes.
    # @param tokens [Array] The token array.
    def initialize(tag_name, markup, tokens)
      super
      @attributes = {}
      parse_markup(markup) # Parse attributes from the markup
    end

    # Parses the markup to extract attributes.
    #
    # @param markup [String] The markup string containing attributes.
    def parse_markup(markup)
      markup.scan(VALID_SYNTAX) do |key, d_quoted, s_quoted, variable|
        value = if d_quoted
                  d_quoted.include?('\\"') ? d_quoted.gsub('\\"', '"') : d_quoted
                elsif s_quoted
                  s_quoted.include?("\\'") ? s_quoted.gsub("\\'", "'") : s_quoted
                elsif variable
                  variable.strip # Handle variable names passed directly
                end
        @attributes[key] = value if key
      end
    end

    # Renders the SVG symbol tag.
    #
    # @param context [Liquid::Context] The Liquid context.
    # @return [String] The rendered SVG HTML.
    def render(context)
      svg_id = @attributes['id'] || ''

      # Resolve the variable if it exists in the context
      svg_id = context[svg_id] if context[svg_id].is_a?(String)

      # Return nothing if no id is provided
      return '' if svg_id.nil? || svg_id.empty?

      # Retrieve baseurl and source directory from context
      site = context.registers[:site]
      baseurl = site.config['baseurl'] || ''
      svg_base = File.join('assets', 'icons.svg')
      svg_path = File.join(site.source, svg_base)

      # Check if the SVG sprite file exists
      raise "SVG sprite file not found: '#{svg_path}'" unless File.exist?(svg_path)

      # Construct the SVG URL reference
      svg_url = File.join(baseurl, svg_base) # Base URL part
      svg_path_with_id = "#{svg_url}##{svg_id}".downcase

      # Initialize attributes for the <svg> element
      svg_attrs = {}
      svg_attrs['width'] = '24'
      svg_attrs['height'] = '24'
      svg_attrs['viewBox'] = '0 0 24 24'
      svg_attrs['aria-hidden'] = 'true'

      # Add additional attributes from the markup, excluding specific ones
      @attributes.each do |key, value|
        next if %w[id width height viewbox aria-hidden].include?(key)

        svg_attrs[key] = value
      end

      # Convert the svg_attrs hash into a string of HTML attributes
      svg_attrs_string = svg_attrs.map { |k, v| "#{k}=\"#{v}\"" }.join(' ')

      # Render the SVG element
      %(<svg #{svg_attrs_string}><use href="#{svg_path_with_id}" /></svg>)
    end
  end
end

# Register the custom Liquid tag
Liquid::Template.register_tag('svg_sprite', Jekyll::SVGSpriteTag)
