require "csv"

filename = ARGV.first
unless filename
  $stderr.puts "Usage: #{$PROGRAM_NAME} filename"
  Process.exit(111)
end

CSV.open(filename, "r", headers: true) do |csv|
  csv.each do |row|
    id = row["channel_id"]
    puts id
  end
end
