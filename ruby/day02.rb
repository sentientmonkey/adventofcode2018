#!/usr/bin/env ruby -w

class Device
  def self.checksum str
    twos = 0
    threes = 0
    str.split(/\s+/).each do |word|
      counts = word.chomp
                   .each_char
                   .group_by(&:itself)

      if counts.any? { |_, v| v.length == 2 }
        twos += 1
      end

      if counts.any? { |_, v| v.length == 3 }
        threes += 1
      end
    end
    twos * threes
  end

  def self.diff w1, w2
    w1.each_char
      .zip(w2.each_char)
      .map { |a,b| a == b ? 0 : 1 }
      .reduce(&:+)
  end

  def self.common w1, w2
    w1.each_char
      .zip(w2.each_char)
      .select { |a,b| a == b }
      .map{ |a,_| a }
      .join
  end

  def self.find_common str
    str.split(/\s+/)
      .map(&:chomp)
      .combination(2)
      .find { |a,b| diff(a,b) == 1 }
      .reduce { |a,b| common(a,b) }
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class DeviceTest < Minitest::Test
      def test_checksum
        assert_equal 12, Device.checksum("abcdef bababc abbcde abcccd aabcdd abcdee ababab")
      end

      def test_word_diff
        assert_equal 1, Device.diff("fghij", "fguij")
        assert_equal 2, Device.diff("abcde", "axcye")
        assert_equal 5, Device.diff("klmno", "pqrst")
      end

      def test_common
        assert_equal "fgij", Device.common("fghij", "fguij")
      end

      def test_find_commond
        assert_equal "fgij", Device.find_common("abcde fghij klmno pqrst fguij axcye wvxyz")
      end
    end
  else
    input = ARGF.read
    p Device.checksum input
    p Device.find_common input
  end
end
