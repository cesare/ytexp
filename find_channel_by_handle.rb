#
# Usage: bundle exec ruby find_channel_by_handle.rb handle-name
#
# for API details, @see https://developers.google.com/youtube/v3/docs/channels/list
#

require "faraday"
require "json"

api_key = ENV["API_KEY"]
unless api_key
  $stderr.puts "Set API_KEY env"
  Process.exit(111)
end

handle = ARGV.first
unless handle
  $stderr.puts "Usage: #{$PROGRAM_NAME} handle-name"
  Process.exit(111)
end

params = {
  key: api_key,
  part: "snippet,contentDetails,statistics",
  forHandle: "@#{handle}",
}

conn = Faraday.new("https://www.googleapis.com") do |f|
  f.response :json
end

response = conn.get("/youtube/v3/channels") do |req|
  req.params = params
end

items = response.body.dig("items")
items.each do |item|
  id = item.dig("id")
  title = item.dig("snippet", "title")
  description = item.dig("snippet", "description")

  puts <<~END
    ---
    id: #{id}
    title: #{title}
    description: #{description}
  END
end
