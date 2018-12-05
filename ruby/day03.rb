#!/usr/bin/env ruby -w

Claim = Struct.new(:num, :left, :top, :width, :height) do
  def self.find_claims str
    from_str(str)
      .each_with_object(Hash.new(0)) { |claim,hash|
        claim.width.times { |x|
          claim.height.times { |y|
            hash[[claim.left+x,claim.top+y]] += 1
        }
      }
    }.select { |k,v| v > 1 }
    .count
  end

  def self.from_str str
    str.split("\n").map do |line|
      m = line.match(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/)
      num, x, y, w, h = m[1..5].map(&:to_i)
      Claim.new num, x,y,w,h
    end
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class DeviceTest < Minitest::Test
      INPUT = <<~EOS
                #1 @ 1,3: 4x4
                #2 @ 3,1: 4x4
                #3 @ 5,5: 2x2
              EOS
      def test_parse_claims
        assert_equal [Claim.new(1, 1, 3, 4, 4),
                Claim.new(2, 3, 1, 4, 4),
                Claim.new(3, 5, 5, 2, 2)], Claim.from_str(INPUT)
      end

      def test_overlap_counts
        assert_equal 4, Claim.find_claims(INPUT)
      end
    end
  else
    input = ARGF.read
    p Claim.find_claims input
  end
end
