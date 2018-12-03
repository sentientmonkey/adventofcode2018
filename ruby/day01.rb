#!/usr/bin/env ruby -w

require "set"

class Accum
  def initialize
    @curr = 0
    @set = Set.new [@curr]
    @first_repeated = nil
  end

  def add n
    @curr = @curr + n
    if @first_repeated.nil? && @set.include?(@curr)
      @first_repeated = @curr
      @first_repeated
    else
      @set << @curr
      nil
    end
  end

  def first_repeated
    @first_repeated
  end
end

class Array
  def cycle_unless
    loop do
      self.each do |n|
        return n if yield n
      end
    end
  end
end

class Device
  def self.frequency str
    str.split(/\s+/)
      .map(&:to_i)
      .reduce(&:+)
  end

  def self.find_repeated str
    acc = Accum.new
    str.split(/\s+/)
    .map(&:to_i)
    .cycle_unless{ |n| acc.add(n) }
    acc.first_repeated
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class DeviceTest < Minitest::Test
      def test_frequencies
        assert_equal 3, Device.frequency("+1 -2 +3 +1")
        assert_equal 3, Device.frequency("+1 +1 +1")
        assert_equal 0, Device.frequency("+1 +1 -2")
        assert_equal (-6), Device.frequency("-1 -2 -3")
      end

      def test_cycle_while
        sum = 0
        [1,2,3].cycle_unless{ |n| sum += n; sum > 10}
        assert_equal 12, sum
      end

      def test_repeat
        assert_equal 0, Device.find_repeated("+1 -1")
        assert_equal 10, Device.find_repeated("+3 +3 +4 -2 -4")
        assert_equal 5, Device.find_repeated("-6 +3 +8 +5 -6")
        assert_equal 14, Device.find_repeated("+7 +7 -2 -7 -4")
      end
    end
  else
    input = ARGF.read.chomp
    p Device.frequency input
    p Device.find_repeated input
  end
end
