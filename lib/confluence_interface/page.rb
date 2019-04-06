require "json"
require "pathname"
require "httparty"

module Confluence
  class Page
    include HTTParty
    include ConfluenceInterface

    base_uri BASE_URI

    def self.santize_title_for_display(title)
      return title unless (title =~ /\.md/i)
      title.gsub(/.md/i, "").gsub("-", " ")
    end

    def initialize(page:, content:, context:)
      path = Pathname.new(page)

      @page = page
      @filename = path.basename.to_s
      @parent = path.dirname.to_s

      @content = content
      @context = context
    end

    def create!
      raise "Missing Parent Confluence Page #{@parent}" unless parent_id

      puts "Creating Confluence page #{@page} ..."

      post!
      update_context
    end

    private

    def post!
      self.class.post(CONTENT_ENDPOINT, options).tap do |response|
        raise response.body unless (200..299).include?(response.code)

        @id = JSON.parse(response.body)["id"]
      end
    end

    def update_context
      display_path = [@parent, display_title].join("/")
      @context.add_page(display_path, @id)
    end

    def options
      {
        body: payload.to_json,
        headers: {
          "Accept" => "application/json",
          "Content-Type" => "application/json"
        }
      }.merge(auth_options)
    end

    def payload
      {
        title: display_title,
        type: "page",
        space: { key: @context.space },
        status: "current",
        ancestors: [
          { id: parent_id }
        ],
        body: {
          storage: {
            value: @content,
            "representation": "storage"
          }
        }
      }
    end

    def parent_id
      @parent_id ||= @context.index_for(@parent)
    end

    def display_title
      @display_title ||= self.class.santize_title_for_display(@filename)
    end
  end
end
