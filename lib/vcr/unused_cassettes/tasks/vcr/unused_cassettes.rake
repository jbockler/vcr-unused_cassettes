namespace :vcr do
  desc "List unused cassettes"
  task unused_cassettes: :environment do |_task|
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
end
