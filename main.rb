Page = Struct.new(:fpath, :above_text, :below_text, :weight)

DIR_PATH = ARGV[0] || "."
# TODO: Hard code
WEIGHT_START = 10
# TODO: Hard code
WEIGHT_STEP  = 10

md_names = Dir.entries(DIR_PATH).reject{|f| [".", ".."].include?(f)}
md_paths = md_names.map{|f| File.join(DIR_PATH, f)}

pages = md_paths.map{|md_path|
  lines = File.read(md_path).each_line.to_a
  weight_reg = %r{weight\s*=\s*(\d+)}
  idx = lines.index{|l| l.match(weight_reg)}

  if idx.nil?
    STDERR.puts("Error: weight = <number> is not found in #{md_path}")
    exit(1)
  end
  weight = lines[idx].match(weight_reg)[1].to_i

  above_text = lines[0..idx-1].join
  below_text = lines[idx+1..-1].join

  Page.new(
    md_path,
    above_text,
    below_text,
    weight
  )
}

weight       = WEIGHT_START
pages.sort{|p1, p2| [p1.weight, p1.fpath] <=> [p2.weight, p2.fpath]}.each{|page|
  puts("====== #{page.fpath} ======")
  puts("#{page.weight} => #{weight}")

  # Create new-weighted text
  md_text = page.above_text + "weight = #{weight}\n" + page.below_text
  # Rewirte
  File.write(page.fpath, md_text)

  weight += WEIGHT_STEP
}
