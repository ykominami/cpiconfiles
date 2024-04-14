require "yaml"
require "pathname"
require "pstore"

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
          Yamlstore.load_iconfilegroup(id_numn)
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
=begin
      def create(value, dump_fname, sizepat)
        s_inst = @store_class.new(**value)
        dump_fname = dump_fname
        top_dir_pn = Pathname.new(s_inst.top_dir)
        new(dump_fname, sizepat, top_dir_pn)
      end
=end
      def restore(hash, dump_fname, sizepat)
        obj_hs = {}
        icfg_hs = Yamlstore.get_iconfilegroup_hs
        icfsg_hs = Yamlstore.get_iconfilesubgroup_hs
        icf_hs = Yamlstore.get_iconfile_hs
        icl_hs = Yamlstore.get_iconlist_hs
        yaml = Yamlstore.get_yaml_hs

        hs = yaml["iconfilegroup"]
        hs.each do |key, val|
          x_class_a = Iconfilegroup.make(**val)
          p x_class_a
          p ""
        end

        icfsg_hs = yaml["iconfilesubgroup"]
        icfsg_hs.each do |key2, val2|
          val2 = Iconfilesubgroup.make(**val2)
          p val2
        end
        p ""
        icf_hs = yaml["iconfile"]
        icf_hs.each do |key3, val3|
          val3 = Iconfile.make(**val3)
          p val3
        end
        p ""
        icl_hs = yaml["iconlist"]
        icl_hs.each do |key4, val4|
          val4 = self.make(**val4)
          p val4
        end
        p ""

        exit

        p "==="
        yaml.each do |key, value|
          p "key=#{key}"
          # p "value=#{value}"
          value.each do |key2, value2|
            p "  key2=#{key2}"
            # p "value2=#{value2}"
            value2.each do |key3, value3|
              p "    key3=#{key3}"
              if value3.instance_of?(Array)
                p "      value4=#{value3}"
              elsif value3.instance_of?(Hash)
                value3.each do |key4, value4|
                  p "      key4=#{key4}"
                  p "       value4=#{value4}"
                end
              else
                p "     value3=#{value3}"
              end
            end
          end
          p "==="
          p ""
        end
        hash.each do |key, value|
          p "value=#{value}"
          p value[:top_dir]
          top_dir = value[:top_dir]
          icfg_id = value[:iconfilegroups][top_dir]
          x = icfg_hs[icfg_id]
          p x
          p x.iconfilegroups
          p "==="

          inst = create(value, dump_fname, sizepat)
          inst.setup_for_iconfiles
          obj_hs[key] = inst
        end
        obj_hs
      end
    end
    attr_reader :top_dir_pn, :iconfilegroups

    def initialize(dump_fname, sizepat, top_dir_pn = nil)
      log_level = :info
      # log_level = :debug
      Loggerxcm.log_init(log_level)

      @dump_fname = dump_fname
      @sizepat = sizepat
      @top_dir_pn = top_dir_pn

      @obj = {}
      @iconfilegroups = {}

      @store = PStore.new(@dump_fname) if @dump_fname
    end

    def make(count)
      self.class.store_class.new(count, @top_dir_pn.to_s, @iconfilegroups)
    end

    def valid?
      ret = @iconfilegroups.size.positive?
      size = @iconfilegroups.size
      Loggerxcm.debug "Iconlist valid? ret=#{ret} size=#{size}"
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
      p "### Iconlist#save_to_obj @iconfilegroups=#{@iconfilegroups}"
      @iconfilegroups.each do |key, icfg|
        # store_obj = icfg.save_to_obj(count)
        iconfilegroups[key.to_s] = Yamlstore.add_iconfilegroup(icfg)
      end
      self.class.store_class.new(count, @top_dir_pn.to_s, iconfilegroups)
    end

    def prepare_for_save
      @obj[:iconfilegroups] = @iconfilegroups
      Loggerxcm.debug "prepare_for_save @iconfilegroups.size=#{@iconfilegroups.size}"
    end

    def postprocess_for_load
      raise unless @obj[:iconfilegroups].instance_of?(Hash)
      @iconfilegroups = @obj[:iconfilegroups]
      raise if @iconfilegroups.nil?
      raise if @iconfilegroups.each do |key, ifg|
        raise if ifg.instance_of?(Iconfilegroup)
      end

      @iconfilegroups ||= {}
      Loggerxcm.debug "Iconlist postprocess_for_load @iconfilegroups=#{nil}"
    end

    def collect(dir_pn, parent_sizeddir = nil)
      ifg = Iconfilegroup.new(@top_dir_pn, dir_pn, @sizepat)
      Loggerxcm.debug "Iconlist collect dir_pn=#{dir_pn}"
      ifg.collect(dir_pn, parent_sizeddir)
      @iconfilegroups[dir_pn] = ifg
    end

    def analyze
      @iconfilegroups.each do |key, ifg|
        p "key=#{key}"
        p "ifg=#{ifg}"
        # raise if ifg.instance_of?(Iconfilegroup)
        p "Iconlist#analyze key=#{key} ifg=#{ifg}"
        if ifg
          ifg.analyze
        else
          p "Iconlist#analyze ifg=nil"
          ""
        end
      end
    end

    def setup_for_iconfiles
      # p "@iconfilegroups~#{@iconfilegroups}"
      @iconfilegroups.each do |key, ifg|
        p "key=#{key}"
        if ifg
          ifg.setup_for_iconfiles
        else
          p "Iconlist#setup_for_iconfiles ifg=nil"
          ""
        end
      end
    end

    def check_files
      ret = true
      keys = @obj.keys
      Loggerxcm.debug keys
      keys.each do |key|
        Loggerxcm.debug "key=#{key}"
        val = @obj[key]
        if val.nil? || val.empty?
          ret = false
        else
          Loggerxcm.debug "val.size=#{val.size}"
        end
      end
      ret
    end

    def load
      return unless @store

      @store.transaction(true) do
        # オブジェクトをデシリアライズ
        @obj = @store[:my_object]
        postprocess_for_load
        # check_files
        Loggerxcm.debug "#=== load"
      end
    end

    def dump
      return unless @store

      @store.transaction do
        Loggerxcm.debug "save # S"
        prepare_for_save
        check_files
        Loggerxcm.debug "save # S E"
        # オブジェクトをシリアライズ
        @store[:my_object] = @obj
        # トランザクションの終了（このブロックを抜けると自動的に終了します）
      end
    end

    def save_as_csv(csv_file)
      Loggerxcm.debug "############################## Iconlist#save_as_csv S csv_file=#{csv_file}"
      csv_file = Pathname.new(csv_file)
      csv_file.open("w") do |file|
        @iconfilegroups.map do |key, icfg|
          raise if ifg.instance_of?(Iconfilegroup)
          # puts "iconlist save_as_csv key=#{key}"
          icfg.save_as_csv(file)
        end
      end
      Loggerxcm.debug "############################## Iconlist#save_as_csv E csv_file=#{csv_file}"
      csv_file
    end

    def json
      @iconfilegroups.each do |key, ifg|
        raise if ifg.instance_of?(Iconfilegroup)

        ifg.to_json
      end
    end

    def yaml
      YAML.dump(@iconfilegroups)
    end

    def print
      @iconfilegroups.map do |key, icfg|
        raise if ifg.instance_of?(Iconfilegroup)

        Loggerxcm.debug key
        icfg.print
      end
    end

    def print2
      Loggerxcm.debug "ICONLIST#PRINT2 @iconfilegroups.size=#{@iconfilegroups.size}"

      @iconfilegroups.map do |key, icfg|
        raise if ifg.instance_of?(Iconfilegroup)

        Loggerxcm.debug "key=#{key}"
        icfg.print2
      end
    end

    def print_l1
      @iconfilegroups.map do |_key, icfg|
        raise if ifg.instance_of?(Iconfilegroup)

        icfg.print_l1
      end
    end

    def print_l1_icon_size
      @iconfilegroups.map do |_key, icfg|
        raise if ifg.instance_of?(Iconfilegroup)

        icfg.print_l1_icon_size
      end
    end

    def print_l2
      @iconfilegroups.map do |_key, icfg|
        raise if ifg.instance_of?(Iconfilegroup)

        icfg.print_l2
      end
    end

    def show_iconfilegroups
      @iconfilegroups.each do |key, ifg|
        p "ifg.class=#{ifg.class}"
        raise if ifg.instance_of?(Iconfilegroup)

        p "key=#{key}"
        ifg.show_iconfiles
      end
    end
  end
end
