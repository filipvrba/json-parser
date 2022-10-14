require_relative 'json_parser'

require 'octokit'
require 'base64'
require 'json'
require 'open-uri'

class JsonParserGithub < JsonParser
  MESSAGE_UPDATE = "Updating content"
  GITHUB_ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']

  def initialize repository, path, branch = 'main'
    unless GITHUB_ACCESS_TOKEN
      raise "Please set the 'GITHUB_ACCESS_TOKEN' access token to the linux environment. "
    end

    @repository = repository
    @client = Octokit::Client.new(access_token: GITHUB_ACCESS_TOKEN)

    @content = @client.contents(repository, path: path, query: {ref: branch})
    @sha = @content.sha

    super path, false
  end

  def push
    write(@path, @db)
  end

  private
  def open path
    begin
      content = @content.content
      unless content
        content_decode = Base64.decode64(content)
        result = JSON.parse content_decode
      else
        URI.open @content.download_url do |f|
          result = JSON.parse f.read
        end
      end

      return result
    rescue
      return Hash.new
    end
  end

  def write path, db
    begin
      @client.update_contents(@repository,
        path,
        "#{MESSAGE_UPDATE} #{Time.now}",
        @sha,
        JSON.pretty_generate(db)
      )

      @sha = @client.last_response.data.content.sha
    rescue
      puts "409 HTTP status code for #{path}"
    end
  end
end