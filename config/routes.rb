Rails.application.routes.draw do
  get 'anagrams/:word', to: 'anagrams#show_anagrams'
  get 'word_info', to: 'anagrams#show_word_info'
  get 'anagram_check', to: 'anagrams#is_anagram?'
  get 'proper_noun_anagrams/:word', to: 'anagrams#return_proper_noun_anagrams'
  get 'most_anagrams', to: 'anagrams#most_anagrams'
  get 'anagram_groups', to: 'anagrams#anagram_group_sizes'

  post '/words', to: 'anagrams#create_words'

  delete 'words/:word', to: 'anagrams#delete_word'
  delete 'delete_associated_anagrams/:word', to: 'anagrams#delete_associated_anagrams'
  delete '/words', to: 'anagrams#delete_all_words'
end
