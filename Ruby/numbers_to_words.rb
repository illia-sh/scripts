class NumberToWord
  # hash for number with unique word equivalents
  def number_words
    @number_words = {
      90 => "ninety",   80 => "eighty",   70 => "seventy",
      60 => "sixty",    50 => "fifty",    40 => "forty",
      30 => "thirty",   20 => "twenty",   19 => "nineteen",
      18 => "eighteen", 17 => "seventeen",16 => "sixteen",
      15 => "fifteen",  14 => "fourteen", 13 => "thirteen",
      12 => "twelve",   11 => "eleven",   10 => "ten",
      9  => "nine",     8  => "eight",    7  => "seven",
      6  => "six",      5  => "five",     4  => "four",
      3  => "three",    2  => "two",      1  => "one",
    }
  end

  # function for converting numbers to words
  def convert(number)
    # returns from hash for unique numbers
    if number_words.has_key?(number)
      number_words[number]
    # for all three digit numbers
    elsif (100..1000).include?(number)
      [ number_words[number / 100],
        "hundred",
        number_words[number - ((number / 100) * 100) - (number % 10)],
        number_words[number % 10]
      ].join(" ").strip
    # for two digit numbers not already in hash
    else
      [ number_words[number - (number % 10)],
        number_words[number % 10]
      ].join(" ")
    end
  end
end

p NumberToWord.new.convert(666)
