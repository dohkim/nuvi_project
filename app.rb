require 'nokogiri'
require 'open-uri'
require 'zip'
require 'redis'
require 'net/http'
require_relative 'lib/downxml'
require_relative 'lib/nuvi'

include Nuvi


redis=Redis.new
download = Downxml.new("http://bitly.com/nuvi-plz")
download.new_file_download
xml_to_redis(redis, download.target_folder)