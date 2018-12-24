#!/usr/bin/env ruby -w

require "date"

class Record
  attr_reader :timestamp, :message

  def initialize timestamp, message
    @timestamp = DateTime.parse timestamp
    @message = message
  end

  def formatted_timestamp
    timestamp.strftime "%F %R"
  end

  def minute
    timestamp.to_time.min
  end
end

class Guard
  attr_reader :id, :sleep_minutes

  def initialize id
    @id = id
    @sleep_minutes = 0
    @sleep_times = Hash.new{0}
  end

  def add_time start_time, end_time
    @sleep_minutes += end_time - start_time
    start_time.upto(end_time) do |i|
      @sleep_times[i] += 1
    end
  end

  def sleepiest_minute
    @sleep_times.max_by{ |_,total| total }.first
  end

  def sleepiest_minute_time
    @sleep_times.values.max
  end

  def product
    id * sleepiest_minute
  end
end

class GuardLog
  attr_reader :records

  def initialize str
    @records = parse str
    @guards = Hash.new
    build_guards
  end

  def parse str
    str.lines
      .map(&:chomp)
      .map { |line|
        m = line.match(/\[(.+)\] (.+)/)
        _,t,s = *m
        Record.new t, s
      }.sort_by(&:timestamp)
  end

  def find_or_create_guard id
    @guards.fetch(id) { Guard.new id }
  end

  def save_guard guard
    @guards[guard.id] = guard
  end

  def build_guards
    current = nil
    start = nil
    records.each do |record|
      case record.message
      when /Guard #(\d+) begins shift/
        current = find_or_create_guard $1.to_i
      when /falls asleep/
        start = record.minute
      when /wakes up/
        current.add_time start, record.minute
        save_guard current
      end
    end
  end

  def sleepiest_guard
    @guards.values.max_by{ |g| g.sleep_minutes }
  end

  def sleepiest_guard_by_minute
    max_time = 0
    max_minute = nil
    max_gaurd = nil
    @guards.values.each do |g|
      if g.sleepiest_minute_time > max_time
        max_minute = g.sleepiest_minute
        max_gaurd = g
      end
    end

    [max_minute, max_gaurd]
  end
end

if __FILE__ == $0
  if ARGV.empty?
    require "minitest/autorun"
    require "minitest/pride"

    class GuardLogTest < Minitest::Test
      INPUT = <<~EOS
        [1518-11-04 00:46] wakes up
        [1518-11-01 00:55] wakes up
        [1518-11-04 00:36] falls asleep
        [1518-11-01 00:00] Guard #10 begins shift
        [1518-11-05 00:45] falls asleep
        [1518-11-01 00:25] wakes up
        [1518-11-05 00:55] wakes up
        [1518-11-01 00:30] falls asleep
        [1518-11-01 23:58] Guard #99 begins shift
        [1518-11-02 00:40] falls asleep
        [1518-11-01 00:05] falls asleep
        [1518-11-02 00:50] wakes up
        [1518-11-03 00:24] falls asleep
        [1518-11-03 00:29] wakes up
        [1518-11-04 00:02] Guard #99 begins shift
        [1518-11-03 00:05] Guard #10 begins shift
        [1518-11-05 00:03] Guard #99 begins shift
      EOS

      def setup
        @subject = GuardLog.new INPUT
      end

      def test_orders_input
        assert_equal 17, @subject.records.length
        assert "1518-11-01 00:00", @subject.records.first.formatted_timestamp
        assert_equal "1518-11-05 00:55", @subject.records.last.formatted_timestamp
      end

      def test_find_sleepiest_guard
        assert_equal 10, @subject.sleepiest_guard.id
        assert_equal 50, @subject.sleepiest_guard.sleep_minutes
        assert_equal 24, @subject.sleepiest_guard.sleepiest_minute
        assert_equal 240, @subject.sleepiest_guard.product
      end

      def test_find_sleepiest_gaurd_minute
        assert_equal 45, @subject.sleepiest_guard_by_minute.first
        assert_equal 99, @subject.sleepiest_guard_by_minute.last.id
        assert_equal 4455, @subject.sleepiest_guard_by_minute.first * @subject.sleepiest_guard_by_minute.last.id
      end
    end
  else
    g = GuardLog.new ARGF.read
    puts g.sleepiest_guard.product
    puts g.sleepiest_guard_by_minute.first * g.sleepiest_guard_by_minute.last.id
  end
end
