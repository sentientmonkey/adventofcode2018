#!/usr/bin/env ruby -w


class Hash
  def contains_bitmap *values
    values.map do |val|
      self.select{ |_,v| v == val }.length > 0 ? 1 : 0
    end
  end
end

class Array
  def vec_sum
    reduce do |mem, a|
      r = []
      mem.zip(a) do |x,y|
        r << x+y
      end
      r
    end
  end
end

class Device
  def self.letter_freq word
    word.chop
      .each_char
      .each_with_object(Hash.new {0}) { |char,hash| hash[char] += 1 }
  end

  def self.checksum str
    str.split(/\s+/).map { |word|
      letter_freq(word)
        .contains_bitmap(2, 3)
    }.vec_sum
     .reduce(&:*)
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class DeviceTest < Minitest::Test
      def test_contains_bitmap
        hash = {"a": 2, "b": 1, "c": 3, "d": 3}
        assert_equal [1,1], hash.contains_bitmap(2, 3)

        hash = {"a": 2, "d": 2, "c": 1, "b": 1}
        assert_equal [1,0], hash.contains_bitmap(2, 3)

        hash = {"a": 3, "b": 3}
        assert_equal [0,1], hash.contains_bitmap(2, 3)
      end

      def test_vec_sum
        vec = [[1,2,3], [4,5,6], [1,1,1]]
        assert_equal [6, 8, 10], vec.vec_sum
      end

      def test_checksum
        assert_equal 12, Device.checksum("abcdef bababc abbcde abcccd aabcdd ababab")
      end
    end
  else
    input = ARGF.read.chomp
    p Device.checksum input
  end
end
