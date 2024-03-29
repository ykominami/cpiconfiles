module Cpiconfiles
  class Sizepattern
    MAX_ICON_SIZE = 512

    SIZE_STRING = :SIZE_STRING
    NUMBER_ONLY = :NUMBER_ONLY
    NUMBER = :NUMBER
    NUMBER2 = :NUMBER2
    NUMBER3 = :NUMBER3
    NUMBER_NUMBER = :NUMBER_NUMBER
    NUMBER_NUMBER2 = :NUMBER_NUMBER2
    NUMBER_NUMBER3 = :NUMBER_NUMBER3
    FROM_PARENT_SIZEDDIR = :FROM_PARENT_SIZEDDIR
    INVALID_PATTERN = :INVALID_PATTERN

    def initialize
      # @pats = {}
    end

    def size_specified_name_pattern?(basename)
      way = 0
      # Loggerxcm.debug"Sizepattern basename=#{basename}"
      mdx = case basename
            when /([^(\-|_\d)]*)(-|_)(hdpi|mdpi|xhdpi|xxhdpi|xxxhdpi)/
              head = ::Regexp.last_match(1)
              md = ::Regexp.last_match(3)
              way = SIZE_STRING
              md
            # when /([^(\-|_|\d)]*)(\-|_|)(\d+)x(\d+)/
            when /([^\d]*)(\d+)x(\d+)/
              md = ::Regexp.last_match(2)
              head = ::Regexp.last_match(1)
              tail = nil
              way = :NUMBER_NUMBER
              md
            # when /(.*)(\d+)([^\d])(\d+)((\-|_)*)(.*)/
            when /(.*)(-|_)(\d+)(-|_)([^\d]*)$/
              md = ::Regexp.last_match(3)
              head = ::Regexp.last_match(1)
              tail = ::Regexp.last_match(5)
              way = NUMBER_NUMBER2
              md
            when /(.*)(-|_)(\d+)(.*)$/
              md = ::Regexp.last_match(3)
              head = ::Regexp.last_match(1)
              tail = ::Regexp.last_match(4)
              way = NUMBER_NUMBER3
              md
            when /^(\d+)$/
              md = ::Regexp.last_match(1)
              head = nil
              way = NUMBER_ONLY
              md
            when /(.*)(\d+)((-|_)*)([^\d]+)$/
              head = ::Regexp.last_match(1)
              md = ::Regexp.last_match(2)
              tail = ::Regexp.last_match(5)
              way = NUMBER3
              md
            when /(.+)(-|_)(\d+)/
              head = ::Regexp.last_match(1)
              md = ::Regexp.last_match(3)
              way = NUMBER2
              md
            when /([^\d]*)(\d+)/
              md = ::Regexp.last_match(2)
              head = ::Regexp.last_match(1)
              way = NUMBER
              md
            else
              way = :INVALID_PATTERN
              head = nil
              nil
            end
      [way, mdx, head, tail]
    end

    def mat(pat, str)
      reg = Regexp.new(pat)
      ret = 0

      case str
      when reg
        Loggerxcm.debug 'match'
        Loggerxcm.debug MatchData
        ret = 1
      else
        Loggerxcm.debug 'etc'
        Loggerxcm.debug MatchData
      end

      ret
    end
  end
end
