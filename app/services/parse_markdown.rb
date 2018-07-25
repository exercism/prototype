require 'redcarpet'
require 'rouge'
require 'rouge/plugins/redcarpet'

class ParseMarkdown
  include Mandate

  attr_reader :text
  def initialize(text)
    @text = text.to_s
  end

  def call
    sanitized_html
  end

  private

  def sanitized_html
    @sanitized_html ||= Loofah.fragment(raw_html).scrub!(:escape).to_s
  end

  def raw_html
    @raw_html ||= markdown.render(preprocessed_text)
  end

  def markdown
    @markdown ||= Redcarpet::Markdown.new(Renderer.new(options), extensions)
  end

  def preprocessed_text
    @preprocessed_text ||=
      text.gsub(/^`{3,}(.*?)`{3,}\s*$/m) { "\n#{$&}\n" }
  end

  def options
    @options ||= {
      with_toc_data: false,
      hard_wrap: false,
      xhtml: true
    }
  end

  def extensions
    @extensions ||= {
      fenced_code_blocks: true,
      no_intra_emphasis: true,
      autolink: true,
      strikethrough: true,
      lax_html_blocks: true,
      superscript: true,
      tables: true,
      space_after_headers: true,
      lax_spacing: true,
    }
  end

  class Renderer < Redcarpet::Render::XHTML
    #def lexer
    #  Rouge::Lexers::PlainText
    #end

    #def formatter
    #  @formatter ||= Rouge::Formatters::HTML.new(
    #    css_class: "highlight #{lexer.tag}",
    #    line_numbers: true
    #  )
    #end

    def link(link, title, content)
      elem = %Q{<a href="#{link}" target="_blank"}
      elem += %Q{ target="_blank"}
      elem += %Q{>#{content}</a>}
      elem
    end

    def block_code(code, language)
      language ||= "plain"
      %Q{<pre><code class="language-#{language}">#{code}</code></pre>}
      #Rouge::Formatters::HTML.new(
      #  css_class: "highlight #{lexer.tag}",
      #  line_numbers: true
      #)

      #formatter.format(lexer.lex(code))
      #SyntaxHighlighter.new(code, language).render
    end
  end

=begin
  class SyntaxHighlighter
    ROUGE_LANG = {
      'objective-c' => 'objective_c',
      'elisp'       => 'common_lisp',
      'lisp'        => 'common_lisp',
      'lfe'         => 'common_lisp',
      'plsql'       => 'sql',
      'ecmascript'  => 'javascript',
      'perl5'       => 'perl',
      'crystal'     => 'ruby',
      'delphi'      => 'pascal',
    }.freeze

    attr_reader :lexer, :code
    def initialize(raw_code, raw_language)
      language = ROUGE_LANG.fetch(raw_language) { raw_language }
      @code = raw_code.gsub(/\r\n?/, "\n")
      @lexer = Rouge::Lexer.find_fancy(language, code) || Rouge::Lexers::PlainText

      # XXX HACK: Redcarpet strips hard tabs out of code blocks,
      # so we assume you're not using leading spaces that aren't tabs,
      # and just replace them here.
      @code = code
      @code.gsub!(/^    /, "\t") if lexer.tag == 'make'
    end

    def render
      formatter.format(lexer.lex(code))
    end

    def formatter
      @formatter ||= Rouge::Formatters::HTML.new(
        css_class: "highlight #{lexer.tag}",
        line_numbers: true
      )
    end
  end
=end
end
