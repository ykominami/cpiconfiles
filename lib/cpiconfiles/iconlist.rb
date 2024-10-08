require "yaml"
require "pathname"

module Cpiconfiles
  class Iconlist
    @store_class = Struct.new("IconlistSave",
                              :id_umn,
                              :top_dir,
                              :iconfilegroups)
    # @store_idnum_class = Struct.new("IconlistSaveIdnum", :idnum)

    class << @store_class
      define_method(:load_from_obj) do
        @iconfilegroups.each do |id_num|
          Yamlstore.load_iconfilegroup(id_num)
        end
      end

      define_method(:to_h) do
          hash = {}
          hash["id_num"] = @id_num
          hash["top_dir"] = @top_dir
          hash["iconfilegroups"] = @iconfilegroups
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
    end
    attr_reader :top_dir_pn, :iconfilegroups

    def initialize(sizepat, top_dir_pn)
      @sizepat = sizepat
      @top_dir_pn = top_dir_pn
      raise NotInstanceOfIconfilegroupError.new("Cpiconfiles initialize @@top_dir_pn=#{@top_dir_pn}") if @top_dir_pn.nil?

      @obj = {}
      @iconfilegroups = {}
      @state = :BEFORE_LOAD
      @dump_load_result = nil
    end

    def move_state
      @state = :AFTER_LOAD
    end

    def make(count)
      self.class.store_class.new(count, @top_dir_pn.to_s, @iconfilegroups)
    end

    def valid?
      case @state
      when :BEFORE_LOAD
        ret = true
      when :IN_LOAD
        if @dump_load_result == :FAIL_LOAD
          ret = false
        else
          ret = true
        end
      else
        ret = @iconfilegroups.size.positive?
        size = @iconfilegroups.size
        Loggerxcm.debug "Iconlist valid? ret=#{ret} size=#{size}"
      end

      ret
    end

    def restore()
      hs = Yamlstore.get_iconlist_hs
      p "hs.keys=#{hs.keys}"
      icl = hs[0]
      p icl.class
      p icl
    end

    def save_to_obj(count)
      iconfilegroups = {}
      @iconfilegroups.each do |key, icfg|
        iconfilegroups[key.to_s] = Yamlstore.add_iconfilegroup(icfg)
      end
      self.class.store_class.new(count, @top_dir_pn.to_s, iconfilegroups)
    end

    def collect(dir_pn, parent_sizeddir = nil)
      ifg = Iconfilegroup.new(@top_dir_pn, dir_pn, @sizepat)
      Loggerxcm.debug "Iconlist collect dir_pn=#{dir_pn}"
      ifg.collect(dir_pn, parent_sizeddir)
      @iconfilegroups[dir_pn] = ifg
    end

    def analyze
      @iconfilegroups.each do |key, ifg|
        if ifg
          ifg.analyze
        else
          # p "Iconlist#analyze ifg=nil"
          ""
        end
      end
    end

    def setup_for_iconfiles
      @iconfilegroups.each do |key, ifg|
        if ifg
          ifg.setup_for_iconfiles
        else
          ""
        end
      end
    end

    def load
      @state = :IN_LOAD
      ret , @iconfilegroup = Appenv.dump_file.load unless Appenv.dump_file.nil?
      @dump_load_result = ret
      ret
    end

    def dump
       Appenv.dump_file.dump(@iconfilegroup)
    end

    def save_as_csv(csv_file)
      Loggerxcm.debug "############################## Iconlist#save_as_csv S csv_file=#{csv_file}"
      csv_file = Pathname.new(csv_file)
      csv_file.open("w") do |file|
        @iconfilegroups.map do |key, icfg|
          raise NotInstanceOfIconfilegroupError.new("iconlist save_as_csv icfg.class=#{icfg.class}") unless icfg.instance_of?(Iconfilegroup)
          icfg.save_as_csv(file)
        end
      end
      Loggerxcm.debug "############################## Iconlist#save_as_csv E csv_file=#{csv_file}"
      csv_file
    end

    def json
      @iconfilegroups.each do |key, ifg|
        raise NotInstanceOfIconfilegroupError.new("ifg.class=#{ifg.class}") unless ifg.instance_of?(Cpiconfiles::Iconfilegroup)

        ifg.to_json
      end
    end

    def yaml
      YAML.dump(@iconfilegroups)
    end

    def copy_to(output_dir_pn)
      @iconfilegroups.each do |key, ifg|
        raise NotInstanceOfIconfilegroupError.new("ifg.class=#{ifg.class}") unless ifg.instance_of?(Cpiconfiles::Iconfilegroup)
        ifg.copy_to(output_dir_pn)
      end
    end
  end
end
