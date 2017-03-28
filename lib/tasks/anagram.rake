namespace :anagram do
  desc "Seed database with dictionary"
  task add_dictionary: :environment do
    File.readlines('dictionary.txt').each do |word|
      word = word.strip
      common_key = word.split("").sort.join
      Anagram.create!(word: word, common_key: common_key)
    end
  end
end
