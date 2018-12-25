#!/usr/bin/env ruby -w


module Enumerable
  def foldr m=nil
    reverse.inject(m){ |acc,i| yield acc, i }
  end
end

class Alchemy
  def self.remove_polymers polymers
    polymers.chars.foldr([]) do |ys,x|
      y = if !ys.empty? then ys.first; end
      if y.nil?
        [x]
      elsif y != x && y.upcase == x.upcase
        ys[1..ys.length-1]
      else
        ys.insert 0, x
      end
    end.join ''
  end

  def self.remove_specific_polymers polymers, specific
    remove_polymers polymers.gsub(specific.upcase, '').gsub(specific.downcase, '')
  end

  def self.find_shortest_polymers polymers
    ('a'..'z')
      .map { |char| remove_specific_polymers polymers, char }
      .min_by{ |r| r.length }
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class AlchemyTest < Minitest::Test
      def assert_remove expected, original
        actual = Alchemy.remove_polymers original
        assert_equal expected, actual
      end

      def assert_same expected
        actual = Alchemy.remove_polymers expected
        assert_equal expected, actual
      end

      def assert_remove_specific expected, original, specific
        actual = Alchemy.remove_specific_polymers original, specific
        assert_equal expected, actual
      end

      def test_remove_polymers_for_repeating
        assert_remove 'dabA', 'dabAcC'
        assert_remove 'dabA', 'dabACc'
        assert_remove 'dabAc', 'dabAcAa'
        assert_remove 'dabAc', 'dabAcaA'
        assert_remove 'bgcDaa', 'bgcDaaAAaa'
      end

      def test_does_not_remove_when_same_case
        assert_same 'dabACC'
        assert_same 'dabAcc'
        assert_same 'dabAAA'
        assert_same 'dabaaa'
      end

      def test_removes_all_polymers
        assert_remove 'dabCBAcaDA', 'dabAcCaCBAcCcaDA'
        assert_remove 'dabCBAcaDA', 'dabAcCaCBAcCcaDA'
      end

      def test_remove_specific
        original = 'dabAcCaCBAcCcaDA'
        assert_remove_specific 'dbCBcD', original, 'a'
        assert_remove_specific 'daCAcaDA', original, 'b'
        assert_remove_specific 'daDA', original, 'c'
        assert_remove_specific 'abCBAc', original, 'd'
      end

      def test_shortest_polymer
        actual = Alchemy.find_shortest_polymers 'dabAcCaCBAcCcaDA'
        assert_equal 4, actual.length
      end
    end
  else
    input = ARGF.read.chomp
    puts Alchemy.remove_polymers(input).length
    puts Alchemy.find_shortest_polymers(input).length
  end
end
