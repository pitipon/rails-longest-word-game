require 'open-uri'
require 'json'

class PagesController < ApplicationController
  def start; end

  def game
    @start_time = Time.now.to_i
    @grid = generate_grid(9).join(' ')

    # do it after they click
    # @end_time = Time.now
  end

  def score
    @query = params[:query]
    @grid = params[:grid]
    @start_time = Time.at(params[:start_time].to_i)
    @end_time = Time.now

    puts '******** Now your result ********'

    @result = run_game(@query, @grid, @start_time, @end_time)

    puts "Your word: #{@query}"
    puts "Time Taken to answer: #{@result[:time]}"
    puts "Your score: #{@result[:score]}"
    puts "Message: #{@result[:message]}"

    puts '*****************************************************'
  end

  private

  def generate_grid(grid_size)
    # TODO: generate random grid of letters
    random = []
    grid_size.times { random << ('A'..'Z').to_a.sample }
    random
  end

  def word_match?(one_word)
    # TRUE: matched
    # FALSE: not matched
    url = 'https://wagon-dictionary.herokuapp.com/' + one_word
    word_serialized = open(url).read
    word_result = JSON.parse(word_serialized)
    word_result['found']
end

  def cal_score(time_diff, word_length, keywords_length)
    score =  word_length - (time_diff * 0.2)
    score += 10 if word_length > (keywords_length / 2) # perfect
    score += 10 if time_diff < 10 # fast in 5s
    score
  end

  def in_grid?(attempt, grid)
    # TRUE: in the grid
    # FALSE: not in the grid
    check = true
    attempt.each_char do |c|
      c.upcase!
      check = false unless grid.include?(c)
    end
    check
  end

  def enough_letter?(attempt, grid)
    # TRUE: enough char to make word
    # FALSE: not enough char to make word
    check = true
    arr = grid
    attempt.each_char do |c|
      c.upcase!
      if arr.include?(c)
        arr.each_with_index { |x, index| arr.delete_at(index) if x == c }
      else
        check = false
      end
    end
    check
  end

  def run_game(attempt, grid, start_time, end_time)
    # TODO: runs the game and return detailed hash of result
    time_diff = end_time - start_time
    score = 0
    message = ''

    if word_match?(attempt)
      if enough_letter?(attempt, grid)
        score = cal_score(time_diff, attempt.length, grid.size)
        message = 'well done'
      else
        score = 0
        message = 'not in the grid'
      end
    else
      if in_grid?(attempt, grid)
        score = 0
        message = 'not an english word'
      else
        score = 0
        message = 'not in the grid'
      end
    end

    { time: time_diff, score: score, message: message }
  end
end
