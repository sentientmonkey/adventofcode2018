#!/usr/bin/env ruby -w

module Enumerable
  def foldr m=nil
    reverse.inject(m){ |acc,i| yield acc, i }
  end
end

class Alchemy
  def self.remove_polymers polymers
    polymers.chars.foldr("") do |ys,x|
      y = if !ys.empty? then ys.chars.first; end
      if y.nil?
        x.to_s
      elsif y != x && y.upcase == x.upcase
        ys[1..ys.length-1]
      else
        x + ys
      end
    end
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
    end
  else
    puts Alchemy.remove_polymers(ARGF.read.chomp).length
  end
end