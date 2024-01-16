module Cpiconfiles
  class Iconfile
    # @valid_exts = [:PNG, :JPG, :JPEG, :GIF, :SVG]
    @valid_exts = [:PNG, :GIF, :SVG]

    def self.valid_ext(sym)
      # Loggerxcm.debug "sym=#{sym}"
      @valid_exts.include?(sym)
      # Loggerxcm.debug "ret=#{ret}"
    end

    attr_accessor :valid_ext, :valid_name, :basename,
                  :str_reason,
                  :pathn, :base_pn, :extname, :kind, :icon_size,
                  :relative_pathn

    def initialize(top_dir_pn, pathn, sizepat, parent_sizeddir = nil)
      @top_dir_pn = top_dir_pn
      @sizepat = sizepat
      @parent_sizeddir = parent_sizeddir
      @valid_name = true
      @pathn = pathn
      @relative_pathn = @pathn.relative_path_from(@top_dir_pn)
      @head_str = nil
      @tail_str = nil
      @str_reason = nil
      # Loggerxcm.debug "Iconfile#initialize Iconfile.new @pathn=#{@pathn}"
      @base_pn = @pathn.basename
      @basename = @base_pn.basename('.*').to_s
      @extname = @base_pn.extname[1..]
      @kind = @extname.to_s.upcase.to_sym
      @valid_ext = Iconfile.valid_ext(@kind)
      # Loggerxcm.debug "Iconfile#initialize  @valid_ext=#{@valid_ext} #{path}"
      @icon_size = -1
      determine_icon_size(@basename)
    end

    def determine_icon_size(basename)
      return unless @valid_ext

      way, md, @head_str, @tail_str = sizepat.size_specified_name_pattern?(basename)
      case way
      when Sizepattern::SIZE_STRING
        @icon_size = determine_icon_size_by_symbol(md.to_sym)
        @str_reason = Sizepattern::SIZE_STRING
        # Loggerxcm.debug "Sizepattern::SIZE_STRING #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_ONLY
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_ONLY
        # Loggerxcm.debug "Sizepattern::NUMBER_ONLY #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER
        # Loggerxcm.debug "Sizepattern::NUMBER #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER3
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER3
        # Loggerxcm.debug "Sizepattern::NUMBER2 #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER2
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER2
        # Loggerxcm.debug "Sizepattern::NUMBER2 #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_NUMBER
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_NUMBER
        # Loggerxcm.debug "Sizepattern::NUMBER_NUMBER #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_NUMBER2
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_NUMBER2
        # Loggerxcm.debug "Sizepattern::NUMBER_NUMBER2 #{path} #{md} #{@icon_size}"
      else
        if parent_sizeddir
          @icon_size = parent_sizeddir.size
          @str_reason = Sizepattern::FROM_PARENT_SIZEDDIR
          # Loggerxcm.debug "parent_sizeddir #{path} #{md} #{@icon_size}"
        else
          # Loggerxcm.debug "parent_sizeddir=nil #{@extname} #{path}" if @valid
          @str_reason = Sizepattern::INVALID_PATTERN
          @valid_name = false
        end
      end
      return if @icon_size <= Sizepattern::MAX_ICON_SIZE

      @icon_size = -1
      @valid_name = false
      # Loggerxcm.debug "Sizepattern::MAX_ICON_SIZE #{path} #{md} #{@icon_size}"
    end

    def part_name
      array = [@head_str, @tail_str]
      array.each_with_object([]) do |str, arrayx|
        arrayx << str if !str.nil? && !str.strip.empty?
      end
    end

    def parent_pathn
      @pathn.parent
    end

    def parent_relative_pathn
      @pathn.parent.relative_path_from(@top_dir_pn)
    end

    def parent_pathn_in_string
      @pathn.parent.to_s
    end

    def valid
      @valid_ext && @valid_name
    end

    def path
      @pathn.to_s
    end

    def relative_path
      @relative_pathn.to_s
    end

    def determine_icon_size_by_symbol(basename)
      case basename
      when :hdpi
        72
      when :mdpi
        48
      when :xhdpi
        96
      when :xxhdpi
        144
      when :xxxhdpi
        192
      else
        -1
      end
    end
  end
end
