#!/usr/bin/env ruby -w

Claim = Struct.new(:num, :left, :top, :right, :bottom) do
  def self.find_claims str
    from_str(str)
      .combination(2)
      .select { |a,b| a.overlap(b) > 1 }
      .count
  end

  def self.from_str str
    str.split("\n").map do |line|
      m = line.match(/#(\d+) @ (\d+),(\d+): (\d+)x(\d+)/)
      num, x, y, w, h = m[1..5].map(&:to_i)
      Claim.new num, x,y,x+w,y+h
    end
  end

  def overlap other
    [0, [right,other.right].min - [left,other.left].max].max *
      [0, [bottom,other.bottom].min - [top,other.top].max].max
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class ClaimTest < Minitest::Test
      INPUT = <<~EOS
                #1 @ 1,3: 4x4
                #2 @ 3,1: 4x4
                #3 @ 5,5: 2x2
              EOS
      def test_parse_claims
        assert_equal [Claim.new(1, 1, 3, 5, 7),
                Claim.new(2, 3, 1, 7, 5),
                Claim.new(3, 5, 5, 7, 7)], Claim.from_str(INPUT)
      end

      def test_overlap
        c1 = Claim.new(1, 1, 3, 5, 7)
        c2 = Claim.new(2, 3, 1, 7, 5)
        assert_equal 4, c1.overlap(c2)
      end

      def test_overlap_counts
        assert_equal 1, Claim.find_claims(INPUT)
      end
    end
  else
    input = ARGF.read
    p Claim.find_claims input
  end
end
