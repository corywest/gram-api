class Anagram < ApplicationRecord
  # Find single record
  scope :get_word, -> (word) { where(word: word) }

  # Find multiple records
  scope :find_all_with_common_key, -> (common_key) { where("common_key like ?", "#{common_key}").all }
  scope :find_limit_with_common_key, -> (common_key, max) { where("common_key like ?", "#{common_key}").limit(max) }

  # Deletes
  scope :delete_word_with, -> (word) { where("word like ?", "#{word}%").destroy_all }

  def self.get_all_common_keys(response, common_key_param)
    response.pluck(common_key_param)
  end

  def self.get_all_words(response, word_param)
    response.pluck(word_param)
  end

  def self.get_all_ids(response, id_param)
    response.pluck(id_param)
  end

  def self.get_max_length_from(word_list)
    word_list.max_by(&:length).length
  end

  def self.get_min_length_from(word_list)
    word_list.min_by(&:length).length
  end

  def self.get_word_length_for(word_list)
    word_list.map { |word| word.length }
  end

  def self.get_group_count_with(common_key)
    group_counts = self.all.group(common_key).count
    group_counts.sort_by {|_key, value| value}.reverse.to_h
  end

  def self.calculate_average(word_length, response)
    (word_length.reduce(:+) / response.count)
  end

  def self.calculate_median(word_list_length)
    sorted_list = word_list_length.sort
    array_length = sorted_list.length
    ((sorted_list[(array_length - 1) / 2] + sorted_list[array_length / 2]) / 2.0).to_i
  end

  def self.build_anagram_params(request_information)
    data_parsed = JSON.parse(request_information)
    word_list = data_parsed.values.flatten
    common_key_list = word_list.map {|item| item.downcase.split("").sort.join }
    word_list.zip(common_key_list)
  end

  def self.build_common_key_list(request_information)
    data_parsed = JSON.parse(request_information)
    word_list = data_parsed.values.flatten
    common_key_list = word_list.map {|item| item.split("").sort.join }
    common_key_list.all? {|word| word == common_key_list[0]}
  end

  def self.filter_anagram_group_size(word_groups, size)
    word_groups.select { |item| item.count >= size }
  end
end
