class AnagramsController < ApplicationController
  include ActionController::MimeResponds

  before_action :reset_scope, only: [:show_anagrams,
                                           :return_proper_noun_anagrams,
                                           :delete_word,
                                           :delete_associated_anagrams]

  def show_anagrams
    @response = Anagram.get_word(params[:word]) if params[:word].present?

    case
    when params["limit"]
      @key = Anagram.get_all_common_keys(@response, :common_key)
      @common_anagrams = Anagram.find_limit_with_common_key(@key.first, params["limit"].to_i)
      @final_result = Anagram.get_all_words(@common_anagrams, :word)
    when params["proper_noun"] == "false"
      @key = Anagram.get_all_common_keys(@response, :common_key)
      @common_anagrams = Anagram.find_all_with_common_key(@key.first)
      @word_collection = Anagram.get_all_words(@common_anagrams, :word)
      @final_result = @word_collection.delete_if {|item| item[0] =~ /[A-Z]/ }
    else
      @key = Anagram.get_all_common_keys(@response, :common_key)
      @common_anagrams = Anagram.find_all_with_common_key(@key.first)
      @final_result = Anagram.get_all_words(@common_anagrams, :word)
    end

    respond_to do |format|
      if @response.present?
        format.json { render json: { anagrams: @final_result }, status: 200 }
      else
        format.json { render json: { anagrams: [] }, status: 200 }
      end
    end
  end

  def show_word_info
    @response = Anagram.all
    @word_list = Anagram.get_all_words(@response, :word)
    @word_length = Anagram.get_word_length_for(@word_list)

    @max = Anagram.get_max_length_from(@word_list)
    @min = Anagram.get_min_length_from(@word_list)
    @average = Anagram.calculate_average(@word_length, @response)
    @median = Anagram.calculate_median(@word_length)

    respond_to do |format|
      if @response.present?
        format.json { render json: { total_word_count: @response.count, min_length: @min, max_length: @max, median: @median, average_length: @average  }, status: 200 }
      else
        format.json { render json: { words: [] }, status: 404 }
      end
    end
  end

  def is_anagram?
    request_information = request.raw_post
    @common_anagrams = Anagram.build_common_key_list(request_information)

    if @common_anagrams
      @final_check = true
    else
      @final_check = false
    end

    respond_to do |format|
      if request_information
        format.json { render json: { anagram_pair: @final_check }, status: 200 }
      else
        format.json { render json: { words: [] }, status: 404 }
      end
    end
  end

  def most_anagrams
    @group_count_response = Anagram.get_group_count_with(:common_key)

    @final_grouping = @group_count_response.keys.map do |word|
      @common_anagrams = Anagram.find_all_with_common_key(word)
      Anagram.get_all_words(@common_anagrams, :word)
    end

    respond_to do |format|
      if @group_count_response.present?
        format.json { render json: { anagrams: @final_grouping }, status: 200 }
      else
        format.json { render json: { anagrams: [] }, status: 404 }
      end
    end
  end

  def anagram_group_sizes
    group_size = params["size"].to_i

    @group_count_response = Anagram.get_group_count_with(:common_key)

    @word_grouping = @group_count_response.keys.map do |word|
      @common_anagrams = Anagram.find_all_with_common_key(word)
      Anagram.get_all_words(@common_anagrams, :word)
    end

    @final_grouping = Anagram.filter_anagram_group_size(@word_grouping, group_size)

    respond_to do |format|
      if @group_count_response.present?
        format.json { render json: { anagrams: @final_grouping }, status: 200 }
      else
        format.json { render json: { anagrams: [] }, status: 404 }
      end
    end
  end

  def return_proper_noun_anagrams
    @response = Anagram.get_word(params[:word]) if params[:word].present?

    if params["proper_noun"] == "true"
      @key = Anagram.get_all_common_keys(@response, :common_key)
      @common_anagrams = Anagram.find_all_with_common_key(@key.first)
      @word_collection = Anagram.get_all_words(@common_anagrams, :word)
      @final_result = @word_collection.delete_if {|item| item[0] =~ /[A-Z]/ }
    else
      @key = Anagram.get_all_common_keys(@response, :common_key)
      @common_anagrams = Anagram.find_all_with_common_key(@key.first)
      @final_result = Anagram.get_all_words(@common_anagrams, :word)
    end

    respond_to do |format|
      if @response.present?
        format.json { render json: { anagrams: @final_result } }
      else
        format.json { render json: { words: [] }, status: :not_found }
      end
    end
  end

  def create_words
    information = request.raw_post
    @anagram_params = Anagram.build_anagram_params(information)

    @anagram_params.each do |value|
      Anagram.create!(word: value[0], common_key: value[1])
    end

    respond_to do |format|
      format.json { render json: { status: 201 }, status: 201 }
    end
  end

  def delete_word
    @response = Anagram.delete_word_with(params[:word]) if params[:word].present?

    respond_to do |format|
      format.json { render json: { status: 200 }, status: 200 }
    end
  end

  def delete_all_words
    @response = Anagram.delete_all

    respond_to do |format|
      format.json { render json: { status: 204 }, status: 204 }
    end
  end

  def delete_associated_anagrams
    @response = Anagram.get_word(params[:word]) if params[:word].present?
    @key = Anagram.get_all_common_keys(@response, :common_key)
    @common_anagrams = Anagram.find_all_with_common_key(@key.first)
    @final_list = Anagram.get_all_ids(@common_anagrams, :id)

    @final_list.each do |id|
      Anagram.destroy(id)
    end

    respond_to do |format|
      if @response.present?
        format.json { render json: { status: 202 }, status: 202 }
      else
        format.json { render json: { anagrams: [] }, status: 404 }
      end
    end
  end

  private

  def reset_scope
    Anagram.where(nil)
  end

  def anagram_params
    params.require(:anagram).permit(:word, :common_key)
  end
end
