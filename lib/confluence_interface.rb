module ConfluenceInterface
  BASE_URI = ENV["BASE_URL"] || "https://callrail.atlassian.net"
  EMAIL = ENV.fetch("EMAIL")
  API_KEY = ENV.fetch("API_KEY")

  CONTENT_ENDPOINT = "/wiki/rest/api/content"

  def auth_options
    { basic_auth: { username: EMAIL, password: API_KEY } }
  end
end
