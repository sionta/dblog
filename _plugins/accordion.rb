# frozen_string_literal: true

require 'nokogiri'
require 'jekyll'

module Jekyll
  class AccordionTag < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
      @title = markup.strip # Mengambil judul dari accordion
    end

    def render(context)
      accordion_content = super.strip # Mengambil konten di dalam block
      accordion_id = "accordion-#{rand(1000..9999)}" # Membuat ID unik untuk accordion
      accordion_title = @title.strip.gsub(/^["']|["']$/, '') # Hapus tanda kutip jika ada

      <<~HTML
        <div class="accordion">
          <input type="checkbox" id="#{accordion_id}" class="accordion-checkbox" />
          <label for="#{accordion_id}" class="accordion-label">#{accordion_title}</label>
          <div class="accordion-content">#{accordion_content}</div>
        </div>
      HTML
    end
  end
end

Liquid::Template.register_tag('accordion', Jekyll::AccordionTag)
