class ApiDocsController < ApplicationController
  def index
    markdown_file = Rails.root.join("doc", "api.md")
    markdown_content = File.read(markdown_file)
    renderer = Redcarpet::Render::HTML.new
    markdown = Redcarpet::Markdown.new(renderer, fenced_code_blocks: true, tables: true)
    @content = markdown.render(markdown_content).html_safe
  end
end
