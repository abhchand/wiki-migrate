require "securerandom"
require "pathname"
require "kramdown"

module Github
  class Repository
    GITHUB_ORG = ENV.fetch("GITHUB_ORG")
    GITHUB_REPO = ENV.fetch("GITHUB_REPO")

    def initialize
      create_dir
      clone_repo
    end

    def content_for(filename)
      filepath = path.join(filename || "")
      return "" unless filename =~ /.md/i && filepath.exist?

      markdown = File.read(filepath)
      Kramdown::Document.new(markdown).to_html
    end

    private

    def path
      @path ||= Pathname.new("/tmp").join("wiki-migrate", SecureRandom.hex)
    end

    def create_dir
      puts "Creating: #{path}"
      `mkdir -p #{path}`
    end

    def clone_repo
      url = "git@github.com:#{GITHUB_ORG}/#{GITHUB_REPO}.wiki.git"
      cmd = ["git", "clone", url, path.to_s].join(" ")

      puts "Running: #{cmd}"
      raise "Error Running Command" unless system(cmd)
    end
  end
end
