require_relative 'json_parser'

require 'octokit'
require 'base64'
require 'json'

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

    super path
  end

  private
  def open path
    begin
      content_decode = Base64.decode64(@content.content)
      result = JSON.parse content_decode

      return result
    rescue
      return Hash.new
    end
  end

  def write path, db
    begin
      @client.update_contents(@repository,
        path,
        MESSAGE_UPDATE,
        @content.sha,
        JSON.pretty_generate(db)
      )
    end
  end
end