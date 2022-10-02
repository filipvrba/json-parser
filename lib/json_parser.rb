require "json"
require 'fileutils'

class JsonParser
  attr_reader :db
  
  def initialize path
    @path = path
    @db = open @path
  end

  def on symbol, value
    if exist?
      parse symbol, value
    end
  end

  def parse symbols, value = nil
    if symbols.class.name == "Array"
      symbols_join = symbols.join("\"][\"").prepend("[\"").concat("\"]")
    else
      symbols_join = symbols.to_s.prepend("[\"").concat("\"]")
    end

    unless value
      eval "@db#{ symbols_join }"
    else
      eval "@db#{ symbols_join } = value"
      write @path, @db
    end
  end

  def exist?
    @db.empty?
  end

  private
  def open path
    begin
      result = String.new
      File.open path do |f|
        result = JSON.parse f.read
      end

      return result
    rescue
      return Hash.new
    end
  end

  def write path, db
    begin
      create_dir path do 

        f = File.new path, "w"
        f.write JSON.pretty_generate db
        f.close
      end
    end
  end

  def create_dir path, &callback
    begin
      dir_path = File.dirname path
      unless Dir.exist? dir_path
        FileUtils.mkpath dir_path
      end

      callback.call
    rescue
      
    end
  end
end
