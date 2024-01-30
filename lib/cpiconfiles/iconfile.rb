module Cpiconfiles
  class Iconfile
    # @valid_exts = [:PNG, :JPG, :JPEG, :GIF, :SVG]
    @valid_exts = [:PNG, :GIF, :SVG]

    def self.valid_ext(sym)
      # Loggerxcm.debug "sym=#{sym}"
      @valid_exts.include?(sym)
      # Loggerxcm.debug "ret=#{ret}"
    end

    attr_accessor :valid_ext, :valid_name, :basename,:parent_basename,
                  :str_reason,
                  :pathn, :base_pn, :extname, :kind, :icon_size,
                  :relative_pathn, :parent_sizeddir,
                  :pattern, :l1, :l2, :category

    def initialize(top_dir_pn, pathn, sizepat, parent_sizeddir = nil)
      @top_dir_pn = top_dir_pn
      @sizepat = sizepat
      @parent_sizeddir = parent_sizeddir
      @valid_name = true
      raise NotPathnameClassError unless pathn.instance_of?(Pathname)
      @pathn = pathn
      @relative_pathn = @pathn.relative_path_from(@top_dir_pn)
      @head_str = nil
      @tail_str = nil
      @str_reason = nil
      # Loggerxcm.debug "Iconfile#initialize Iconfile.new @pathn=#{@pathn}"
      @base_pn = @pathn.basename
      @basename = @base_pn.basename('.*').to_s
      @extname = @base_pn.extname[1..]
      @category = @pathn.parent.basename('.*').to_s
      @kind = @extname.to_s.upcase.to_sym
      @valid_ext = Iconfile.valid_ext(@kind)
      # Loggerxcm.debug "Iconfile#initialize  @valid_ext=#{@valid_ext} #{path}"
      @icon_size = -1
      determine_icon_size(@basename)

      @pattern, kx1, kx2, kx3 = determine_basename_pattern(@basename)
      determine_hier(@pattern, kx1, kx2, kx3)
    end

    def determine_hier(pattern, kx1, kx2, kx3)
      case pattern
      when :three_parts
        @l1 = kx1
        @l2 = kx3
        # when :with_twice_size , :with_twice_size_2, :with_space_and_twice_size, :else
        #  @l1 = kx1
      else
        @l1 = kx1
      end
    end

    def determine_basename_pattern(basename)
      kx = basename
      if kx =~ /^(.+)\-(.+)\-(.+)$/
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:three_parts, kx1, kx2, kx3]
      elsif kx =~ /^(.+)\-(.+)x(.+)$/
        # not match
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:with_twice_size, kx1, kx2, kx3]
      elsif kx =~ /^(.+)_(.+)x(.+)$/
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:with_twice_size_2, kx1, kx2, kx3]
      elsif kx =~ /^(.+)(\s+)(.+)x(.+)$/
        # not match
        kx1 = $1
        kx2 = $2
        kx3 = $3
        kx4 = $4
        kx1ex = "#{kx1}#{kx2}"
        return [:with_space_and_twice_size, kx1ex, kx3, kx4]
      else
        kx1 = kx
        return [:else, kx1]
      end
    end

    def determine_icon_size(basename)
      return unless @valid_ext

      way, md, @head_str, @tail_str = @sizepat.size_specified_name_pattern?(basename)
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
