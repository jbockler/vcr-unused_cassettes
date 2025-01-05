namespace :vcr do
  namespace :unused_cassettes do
    desc "List unused cassettes"
    task check: :environment do |_task|
      unused_cassettes, warnings = VCR::UnusedCassettes::Runner.new.find_unused_cassettes

      VCR::UnusedCassettes::Warning.print(warnings)

      if unused_cassettes.empty?
        puts "Everything is fine! No unused cassettes found."
        exit(true)
      end

      puts "Unused cassettes:"
      unused_cassettes.each { |cassette| puts cassette.gsub(Dir.pwd, ".") }
      puts "\n"

      abort("There are #{unused_cassettes.size} unused cassettes")
    end

    desc "Remove unused cassettes"
    task remove: :environment do |_task|
      unused_cassettes, warnings = VCR::UnusedCassettes::Runner.new.find_unused_cassettes

      VCR::UnusedCassettes::Warning.print(warnings)

      if unused_cassettes.empty?
        puts "Everything is fine! No unused cassettes found."
        exit(true)
      end

      puts "Removing unused cassettes:"
      unused_cassettes.each do |cassette|
        puts cassette.gsub(Dir.pwd, ".")
        File.delete(cassette)
      end
      puts "\n"

      puts "Removed #{unused_cassettes.size} unused cassettes"
    end
  end
end
