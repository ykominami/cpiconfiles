require 'thor'
require 'fileutils'

class MyCmd < Thor
  desc "hello", "Greet and write to a file specified by -o"
  option :o, required: true, aliases: :output, desc: "Output filename"
  def hello
    output_filename = options[:o]
    greeting = "Hello, Thor user!"

    # ファイルに書き込み
    File.open(output_filename, 'w') do |file|
      file.puts greeting
    end

    puts "Greeting was written to #{output_filename}"
  end
end

MyCmd.start(ARGV)
