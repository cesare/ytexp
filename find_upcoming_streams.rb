require "faraday"
require "json"
require "time"

api_key = ENV["API_KEY"]
unless api_key
  $stderr.puts "Set API_KEY env"
  Process.exit(111)
end

if ARGV.empty?
  $stderr.puts "Usage: #{$PROGRAM_NAME} channelId [channelId ...]"
  Process.exit(111)
end

conn = Faraday.new("https://www.googleapis.com") do |f|
  f.response :json
end

channel_ids = ARGV.each_with_object([]) do |channel_id, ids|
  params = {
    key: api_key,
    channelId: channel_id,
    eventType: "upcoming",
    part: "snippet",
    type: "video",
  }

  response = conn.get("/youtube/v3/search") do |req|
    req.params = params
  end

  items = response.body.dig("items")
  items.each do |item|
    ids << item.dig("id", "videoId")
  end
end

params = {
  key: api_key,
  id: channel_ids.join(","),
  part: "snippet,liveStreamingDetails",
}

response = conn.get("/youtube/v3/videos") do |req|
  req.params = params
end

items = response.body.dig("items")
items.each do |item|
  id = item.dig("id")
  title = item.dig("snippet", "title")
  scheduled_start_time = item.dig("liveStreamingDetails", "scheduledStartTime")
  starts = Time.parse(scheduled_start_time).getlocal("+09:00")

  puts <<~END
    ---
    id: #{id}
    title: #{title}
    starts: #{starts}
  END
end
