def textile_to_markdown(textile)
  d = []
  pre = false
  table_header = false
  text_line = false

  textile.each_line do |s|
     s.chomp!

    if pre
      if s =~ /<\/pre>/
        d << "~~~"
        pre = false
      else
        d << s
      end
      next
    end

    s.gsub!(/(^|\s)\*([^\s\*].*?)\*(\s|$)/, " **\\2** ")
    s.gsub!(/(^|\s)@([^\s].*?)@(\s|$)/, " `\\2` ")
    s.gsub!(/(^|\s)-([^\s].*?)-(\s|$)/, " ~~\\2~~ ")
    s.gsub!(/"(.*?)":(.*?)\.html/, " [\\1](\\2.html) ")

    d << ""  if text_line
    text_line = false

    case s
    when /^<pre>/
      d << "~~~"
      pre = true
    when /^\*\*\* (.*)$/
      d << "      * " + $1
    when /^\*\* (.*)$/
      d << "   * " + $1
    when /^\* (.*)$/
      d << "* " + $1
    when /^\#\#\# (.*)$/
      d << "      1. " + $1
    when /^\#\# (.*)$/
      d << "   1. " + $1
    when /^\# (.*)$/
      d << "1. " + $1
    when /^h(\d)\. (.*)$/
      d << "#" * $1.to_i + " " + $2
    when /^!(.*?)!/
      d << "![](#{$1})"
    when /^\|_\./
      d << s.gsub("|_.", "| ")
      table_header = true
    when /^\|/
      d << s.gsub(/\=\..+?\|/, ":---:|").gsub(/\s+.+?\s+\|/, "---|") if table_header
      table_header = false
      d << s.gsub("|=.", "| ")
    when /^\s*$/
      d << s
    else
      d << s
      text_line = true
    end
  end

  d.join("\n") + "\n"
end

# def update_content(model, attrbute)
#   total = model.count
#   step = total / 10
#   puts "  #{model}.#{attrbute} : #{total}"
#   model.all.each_with_index do |rec, ix|
#     n = ix + 1
#     puts sprintf("%8d", n)   if n % step == 0
#     rec[attrbute] = textile_to_markdown(rec[attrbute])  if rec[attrbute]
#     rec.save!
#   end
# end

def convfile(input_filepath, output_dirpath)
  s = []
  conv = []
  File.open(input_filepath, mode = "rt"){|f|
    s = f.readlines
  }
  s.each_with_index do |rec, ix|
    conv.push(textile_to_markdown(rec))
  end

  input_filename = File.basename(input_filepath, '.*')
  output_filename = input_filename + "_conv.txt"
  output_filepath = File.join(output_dirpath, output_filename)
  File.open(output_filepath, "w") do |f|
    conv.each { |s| f.puts(s) }
  end
end

output_dirpath = "."

if !ARGV[1].nil?
  output_dirpath = ARGV[1]
end

convfile("./textile.txt", output_dirpath)
