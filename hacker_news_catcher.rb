require "nokogiri"
require 'open-uri'
require 'net/http'
require "parallel"
require "dotenv"

class HackerNewsCatcher
  def initialize
    @trend_urls = []
  end

  def fetch_trend_urls
    doc = Nokogiri::HTML(open('https://news.ycombinator.com/'))
    doc.css(".storylink").each {|link| @trend_urls << link.attributes['href'].value }
  end

  def save_trend_urls_to_instapaper
    return if @trend_urls.empty?

    puts "---Saving to instapaper...---"
    Parallel.map(@trend_urls, in_threads: 30) do |url|
      Net::HTTP.get(URI("https://www.instapaper.com/api/add?username=#{ENV['INSTAPAPER_EMAIL']}&password=#{ENV['INSTAPAPER_PASSWORD']}&url=#{url}"))
    end
    puts "---Complete!---"
  end

  def run
    fetch_trend_urls
    save_trend_urls_to_instapaper
  end
end

Dotenv.load(File.expand_path(File.dirname(__FILE__)) + "/.env")
HackerNewsCatcher.new.run
