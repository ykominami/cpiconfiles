module Cpiconfiles
  class Sizeddir
    attr_reader :valid, :size, :head_str

    def initialize(pathn, sizepat)
      @pathn = pathn
      @size = nil
      @basename = @pathn.basename
      result, md, head_str = sizepat.size_specified_name_pattern?(@basename)
      @head_str = head_str
      @valid = result != :INVALID_PATTERN
      @size = md.to_i if @valid

      Loggerxcm.debug "Sizedir #{@pathn}" if @valid
    end
  end
end
