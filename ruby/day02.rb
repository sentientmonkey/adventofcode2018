#!/usr/bin/env ruby -w

class Device
  def self.checksum str
    twos = 0
    threes = 0
    str.split(/\s+/).each do |word|
      counts = word.chop
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
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class DeviceTest < Minitest::Test
      def test_checksum
        assert_equal 12, Device.checksum("abcdef bababc abbcde abcccd aabcdd ababab")
      end
    end
  else
    input = ARGF.read.chomp
    p Device.checksum input
  end
end
