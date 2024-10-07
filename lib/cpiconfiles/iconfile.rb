module Cpiconfiles
  class Iconfile
    @store_class = Struct.new("IconfileSave",
                              :id_num,
                              :top_dir,
                              :path,
                              :relative_path,
                              :basename,
                              :extname,
                              :category,
                              :kind,
                              :valid_ext,
                              :icon_size,
                              :l1,
                              :l2)
    @store_idnum_class = Struct.new("IconfileSaveIdnum", :idnum)

    # @valid_exts = [:PNG, :JPG, :JPEG, :GIF, :SVG]
    @valid_exts = [:PNG, :GIF, :SVG]

    class << @store_class
      define_method(:recover) do
      end

      define_method(:load_from_obj) do
        p @path
      end

      define_method(:to_h) do
        hash = {}
        hash["id_num"] = @id_num
        hash["top_dir"] = @top_dir.to_s
        hash["path"] = @pathnto_s.to_s
        hash["relative_path"] = @relative_pathn.to_s
        hash["basename"] = @basename.to_s
        hash["extname"] = @extname.to_s
        hash["category"] = @category.to_s
        hash["kind"] = @kind
        hash["valid_ext"] = @valid_ext
        hash["icon_size"] = @icon_size
        hash
      end
    end

    class << self
      def store_class
        @store_class
      end

      def make_store(value)
        @store_class.new(value)
      end

      def valid_ext(sym)
        # Loggerxcm.debug "sym=#{sym}"
        @valid_exts.include?(sym)

        # Loggerxcm.debug "ret=#{ret}"
      end

      def restore(hash, sizepat)
        obj_hs = {}
        hash.each do |value|
          obj_hs[id_num] = create(value, sizepat)
        end
        obj_hs
      end
    end
    attr_accessor :valid_ext, :valid_name, :basename, :parent_basename,
                  :str_reason,
                  :top_dir_pn, :pathn, :base_pn, :extname, :kind, :icon_size,
                  :relative_pathn, :parent_sizeddir,
                  :pattern, :l1, :l2, :category

    def initialize(top_dir_pn, pathn, sizepat, parent_sizeddir = nil)
      @sizepat = sizepat
      @parent_sizeddir = parent_sizeddir
      @valid_name = true
      #
      @head_str = nil
      @tail_str = nil
      @str_reason = nil
      raise UnspecifiedTopDirError.new("Iconfile new top_dir_pn=#{top_dir_pn}") if top_dir_pn.nil?
      @top_dir_pn = top_dir_pn
      raise NotPathnameClassError unless pathn.instance_of?(Pathname)
      @pathn = pathn
      @relative_pathn = @pathn.relative_path_from(@top_dir_pn)
      @base_pn = @pathn.basename
      #
      @basename = @base_pn.basename(".*").to_s
      @extname = @base_pn.extname[1..]
      @category = @pathn.parent.basename(".*").to_s
      @kind = @extname.to_s.upcase.to_sym
      @valid_ext = Iconfile.valid_ext(@kind)
      @icon_size = -1
      @l1 = nil
      @l2 = nil
      #
      # Loggerxcm.debug "Iconfile#initialize  @valid_ext=#{@valid_ext} #{path}"
      determine_icon_size(@basename)
      @pattern, kx1, kx2, kx3 = determine_basename_pattern(@basename)
      determine_hier(@pattern, kx1, kx2, kx3)
    end

    def make(count)
      self.class.store_class.new(
                      count,
                       @top_dir_pn.to_s,
                       @pathn.to_s,
                       @relative_pathn.to_s,
                       @basename,
                       @extname,
                       @category,
                       @kind,
                       @valid_ext,
                       @icon_size,
                       @l1,
                       @l2)
    end

    def save_to_obj(count)
      self.class.store_class.new(count, @top_dir_pn.to_s, @pathn.to_s, @relative_pathn.to_s,
                                 @basename.to_s, @extname.to_s, @category.to_s, @kind, @valid_ext, @icon_size)
    end

    def determine_hier(pattern, kx1, _kx2, kx3)
      case pattern
      when :three_parts
        @l1 = kx1
        @l2 = kx3
        # when :with_twice_size , :with_twice_size2, :with_space_and_twice_size, :else
        #  @l1 = kx1
      else
        @l1 = kx1
      end
    end

    def determine_basename_pattern(basename)
      case basename
      when /^(.+)-(.+)-(.+)$/
        kx1 = Regexp.last_match(1)
        kx2 = Regexp.last_match(2)
        kx3 = Regexp.last_match(3)
        [:three_parts, kx1, kx2, kx3]
      when /^(.+)-(.+)x(.+)$/
        # not match
        kx1 = Regexp.last_match(1)
        kx2 = Regexp.last_match(2)
        kx3 = Regexp.last_match(3)
        [:with_twice_size, kx1, kx2, kx3]
      when /^(.+)_(.+)x(.+)$/
        kx1 = Regexp.last_match(1)
        kx2 = Regexp.last_match(2)
        kx3 = Regexp.last_match(3)
        [:with_twice_size2, kx1, kx2, kx3]
      when /^(.+)(\s+)(.+)x(.+)$/
        # not match
        kx1 = Regexp.last_match(1)
        kx2 = Regexp.last_match(2)
        kx3 = Regexp.last_match(3)
        kx4 = Regexp.last_match(4)
        kx1ex = "#{kx1}#{kx2}"
        [:with_space_and_twice_size, kx1ex, kx3, kx4]
      else
        [:else, basename]
      end
    end

    def determine_icon_size(basename)
      return unless @valid_ext

      way, md, @head_str, @tail_str = @sizepat.size_specified_name_pattern?(basename)
      case way
      when Sizepattern::SIZE_STRING
        @icon_size = determine_icon_size_by_symbol(md.to_sym)
        @str_reason = Sizepattern::SIZE_STRING
        # Loggerxcm.debug "Sizepattern:SIZE_STRING #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_ONLY
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_ONLY
        # Loggerxcm.debug "Sizepattern:NUMBER_ONLY #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER
        # Loggerxcm.debug "Sizepattern:NUMBER #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER3
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER3
        # Loggerxcm.debug "Sizepattern:NUMBER2 #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER2
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER2
        # Loggerxcm.debug "Sizepattern:NUMBER2 #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_NUMBER
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_NUMBER
        # Loggerxcm.debug "Sizepattern:NUMBER_NUMBER #{path} #{md} #{@icon_size}"
      when Sizepattern::NUMBER_NUMBER2
        @icon_size = md.to_i
        @str_reason = Sizepattern::NUMBER_NUMBER2
        # Loggerxcm.debug "Sizepattern:NUMBER_NUMBER2 #{path} #{md} #{@icon_size}"
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
      # Loggerxcm.debug "Sizepattern:MAX_ICON_SIZE #{path} #{md} #{@icon_size}"
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
