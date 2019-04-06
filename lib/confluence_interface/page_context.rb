require "httparty"

module Confluence
  class PageContext
    include HTTParty
    include ConfluenceInterface

    LIMIT = 25


    base_uri BASE_URI

    attr_reader :context, :space

    def initialize(space:)
      @space = space
      @context = derive_context
    end

    def add_page(page, id)
      @context[page.downcase] = id
    end

    def page?(page)
      @context.keys.include?(page.downcase)
    end

    def index_for(page)
      @context[page.downcase]
    end

    private

    def derive_context
      puts "\n=== Space: #{@space}"

      @options = initial_options
      context = []

      puts "\nSearching for existing pages... "
      puts "Found:"

      loop do
        @response = query!(@options)
        context.concat(parse_pages)

        break unless next?
        paginate!
      end

      puts ""
      context.to_h
    end

    def initial_options
      {
        query: {
          spaceKey: @space,
          expand: "ancestors,descendants",
          limit: LIMIT,
          start: 0
        },
        headers: { "Accept" => "application/json" }
      }.merge(auth_options)
    end

    def query!(options)
      self.class.get(CONTENT_ENDPOINT, options).tap do |response|
        raise response.body unless (200..299).include?(response.code)
      end
    end

    def parse_pages
      @response["results"]
        .map do |page|
          prefix = page["ancestors"].map { |a| a["title"] }.join("/")
          prefix = nil if prefix == ""

          title = page["title"]
          id = page["id"]

          path = [prefix, title].compact.join("/")
          puts "- '#{path}'"

          [path.downcase, id]
        end
    end

    def next?
      @response["_links"].key?("next")
    end

    def paginate!
      @options[:query][:start] += LIMIT
    end
  end
end
