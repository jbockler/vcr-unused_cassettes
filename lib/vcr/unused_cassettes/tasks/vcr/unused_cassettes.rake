namespace :vcr do
  desc "List unused cassettes"
  task :unused_cassettes => :environment do |_task|
    cassettes = Dir.glob(Rails.root.join("test", "vcr_cassettes", "*.yml.enc")).map{|path| File.basename(path)}
    cassette_uses, warnings = used_cassettes_names_patterns
    cassette_uses.map! { |name| "#{name}.yml.enc" }

    warnings.each { |warning| warn warning }

    unused_cassettes = cassettes.select do |existing_cassette_name|
      !cassette_uses.any? { |used_cassette_name| File.fnmatch?(used_cassette_name, existing_cassette_name) }
    end

    if unused_cassettes.empty?
      puts "Everything is fine! No unused cassettes found."
      exit(true)
    end

    puts "Unused cassettes:"
    unused_cassettes.each { |cassette| puts cassette }
    puts "\n"

    abort("There are unused cassettes")
  end

  def used_cassettes_names_patterns
    used_cassettes = []
    warnings = []
    use_cassette_snipped = "VCR.use_cassette"
    `grep -n '#{use_cassette_snipped}' test/**/*.rb`.split("\n").each do |line|
      file, line_number, code_line = line.split(":", 3)
      #next unless file == "test/models/merged_pdf_test.rb"
      #next unless line_number == "37"

      # comment_start_index = code_line.index(/#[^\{]/)
      # code_line = code_line[0..comment_start_index] if comment_start_index
      next unless code_line.include?(use_cassette_snipped)
      possible_name = code_line[(code_line.index(use_cassette_snipped) + use_cassette_snipped.size)..]
      possible_name = possible_name[1..] if possible_name.starts_with?("(")
      possible_name.strip!
      possible_name.gsub!(/\#\{[^\}]*\}/, "*")
      start_char = possible_name[0]
      if start_char == "'" || start_char == '"'
        end_of_string = possible_name.index(/[^\\]#{start_char}/, 1)
        name = possible_name[1..end_of_string]
        if name == "*"
          warnings << "Could not find cassette name in #{file}:#{line_number} for #{code_line}"
          next
        end
        used_cassettes << possible_name[1..end_of_string]
      else
        warnings << "Could not find cassette name in #{file}:#{line_number} for #{code_line}"
        next
      end
    end

    [used_cassettes, warnings]
  end
end
