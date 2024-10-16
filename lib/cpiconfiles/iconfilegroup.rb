module Cpiconfiles
  # TODO: class Iconfilegroupを実装する
  class Iconfilegroup
    @store_class = Struct.new("IconfilegroupSave", 
      :id_num,
      :top_dir, :parent, 
      :iconfiles_hs, :iconfiles_by_icon_size,
      :iconfilesubgroups, :iconfilesubgroups_by_icon_size,
      :iconfilesubgroups_by_icon_size_range)

      @store_idnum_class = Struct.new("IconfilegroupSaveIdnum", :idnum)
    class << @store_class
      define_method(:to_h) do
        hash = {}
        hash["id_num"] = @id_num
        hash["top_dir"] = @top_dir_pn.to_s
        hash["parent"] = @parent_pn.to_s
        hash["iconfiles_hs"] = @iconfiles_hs
        hash["iconfiles_by_icon_size"] = @iconfiles_by_icon_size
        hash["iconfilesubgroups"] = @iconfilesubgroups
        hash["iconfilesubgroups_by_icon_size"] = @iconfilesubgroups_by_icon_size
        hash["iconfilesubgroups_by_icon_size_range"] = @iconfilesubgroups_by_icon_size_range
        hash
      end

      define_method(:restore) do
        @iconfiles_hs.each do |key, value|
        end
      end
    end

    class << self
      def store_class
        @store_class
      end

      def make_store(value)
        @store_class.new(value)
      end

      def restore(hash, sizepat)
        obj_hs = {}
        hash.each do |key, value|
          inst = create( value, sizepat )
          inst.setup_for_iconfiles
          obj_hs[key] = inst
        end
        obj_hs
      end
    end

    attr_reader :top_dir_pn,
    :parent_pn,
    :iconfiles_hs, :iconfiles_by_icon_size,
    :iconfilesubgroups, :iconfilesubgroups_by_icon_size,
    :iconfilesubgroups_by_icon_size_range
    def initialize(top_dir_pn, parent_pn, sizepat)
      raise UnspecifiedTopDirError.new("Iconfilegroup top_dir_pn=#{top_dir_pn}") if top_dir_pn.nil?
      @top_dir_pn = top_dir_pn
      @parent_pn = parent_pn
      @sizepat = sizepat
      @iconfiles = []

      @iconfiles_hs = {}
      @iconfiles_by_icon_size = {}
      @iconfilesubgroups = {}
      @iconfilesubgroups_by_icon_size = {}
      @iconfilesubgroups_by_icon_size_range = {}
    end

    def make(count)
      self.class.store_class.new(
        count,
        @top_dir_pn.to_s,
        @parent_pn.to_s,
        @iconfiles_hs,
        @iconfiles_by_icon_size,
        @iconfilesubgroups,
        @iconfilesubgroups_by_icon_size,
        @iconfilesubgroups_by_icon_size_range)
    end

    def set_iconfiles(iconfiles)
      @iconfiles = iconfiles
    end

    def restore
      hs = Yamlstore.get_iconfilegroup_hs
      hs["iconfilegroups"].each do |key, value|
        p "key=#{key} value.class=#{value.class}"
      end
      exit
    end

    def save_to_obj(id_num)
        iconfiles_hs = {}
        @iconfiles_hs.each_with_object({}) { |(key, icf_array), iconfiles_hs|
            iconfiles_hs[key.to_s] = icf_array.map{ |icf|
            Yamlstore.add_base(:iconfile, icf)
          }
        }
        iconfiles_by_icon_size = {}
        @iconfiles_by_icon_size.each do |key, icf_array|
          iconfiles_by_icon_size[key] = icf_array.map{ |icf| 
            Yamlstore.add_iconfile(icf)
          }
        end
        iconfilesubgroups = {}
        @iconfilesubgroups.each do |key, icfsg|
          key_str = key.join('|')
          # icfsg.save_to_obj()
          iconfilesubgroups[key_str] = Yamlstore.add_iconfilesubgroup(icfsg)
        end
        iconfilesubgroups_by_icon_size = {}
        @iconfilesubgroups_by_icon_size.each do |key, icfsg_array|
            iconfilesubgroups_by_icon_size[key] = icfsg_array.map{ |icfsg|
            Yamlstore.add_iconfilesubgroup(icfsg) 
          }
        end
        iconfilesubgroups_by_icon_size_range = {}
        @iconfilesubgroups_by_icon_size_range.each do |key, icfsg_array|
          key_str = key.join('|')
          iconfilesubgroups_by_icon_size_range[key_str] = icfsg_array.map{ |icfsg|
            # icfsg.save_to_obj
            Yamlstore.add_iconfilesubgroup(icfsg)
          }
        end
        count = Yamlstore.get_id_num_base(:iconfilegroup, self)
        self.class.store_class.new(
          count,
          @top_dir_pn.to_s, @parent_pn.to_s,
          iconfiles_hs, iconfiles_by_icon_size,
          iconfilesubgroups, iconfilesubgroups_by_icon_size,
          iconfilesubgroups_by_icon_size_range)
    end

    def setup_for_iconfiles
      @base_pns = make_uniq_field("base_pn")
      @basenames = make_uniq_field("basename")
      @extnames = make_uniq_field("extname")
      # parent_basenames = make_uniq_field('parent_basename')
      # @categories = parent_basenames
      @categories = make_uniq_field("category")
      @kinds = make_uniq_field("kind")
      @icon_sizes = make_uniq_field("icon_size")
      @l1s = make_uniq_field("l1")
      @l2s = make_uniq_field("l2")
      @pathns = make_uniq_field("pathn")
      @icon_sizes = make_uniq_field("icon_size")
      @icon_size_list_sizes = @icon_size_list_sizes
      @iconfiles_by_icon_size = @iconfiles.each_with_object(Hash.new([])) { |icf, h| h[icf.icon_size] += [icf] }
    end

    def create_icfg(obj)
      IconfilegroupArray.new(obj).set_iconfilegroup(self)
    end

    def make_uniq_field(name)
      @iconfiles.map { |item| item.send(name) }.uniq
    end

    def findx(name, value, iconfiles = nil)
      items = iconfiles
      items ||= @iconfiles
      list = items.select { |item| item.send(name) == value }
      create_icfg(list)
    end

    def collect(dir_pn, parent_sizeddir = nil)
      @iconfiles = collect_sub(dir_pn, parent_sizeddir)
      setup_for_iconfiles
    end

    def collect_sub(dir_pn, parent_sizeddir = nil)
      return [] unless dir_pn

      icon_files = []
      Loggerxcm.debug  "dir_pn~#{dir_pn}"
      dir_pn.children.each do |pn|
        next unless pn

        # Loggerxcm.debug  "pn=#{pn}"
        if pn.file?
          icf = Iconfile.new(@top_dir_pn, pn, @sizepat, parent_sizeddir)
          next unless icf.valid

          icon_files << icf
          if icf.category
            if icf.l1
              if icf.l2
                key = [icf.category, icf.l1, icf.l2]
              else
                key = [icf.category, icf.l1]
              end
            else
              key = [icf.category]
            end
          else
            key = []
          end
          @iconfiles_hs[key] ||= []
          @iconfiles_hs[key] << icf
        else
          sizeddir = Sizeddir.new(pn, @sizepat)
          sizeddirx = sizeddir.valid ? sizeddir : parent_sizeddir
          icon_files2 = collect_sub(pn, sizeddirx)
          icon_files += icon_files2
        end
      end
      icon_files
    end

    def save_as_csv(file)
      Loggerxcm.debug "save_as_csv S"
      @iconfiles.map do |icf|
        file.write("#{icf.kind},#{icf.icon_size},#{icf.parent_basename},#{icf.basename},#{icf.pathn}\n")
      end
      Loggerxcm.debug "save_as_csv E"
    end

    def analyze
      items = {}

      @iconfiles_hs.each_with_index do |k_v, index|
        key = k_v[0]
        list = k_v[1]
        category, l1, l2 = key
        if category
          items[category] ||= {}
          if l1
            items[category][l1] ||= {}
            if l2
              items[category][l1][l2] ||= []
              items[category][l1][l2] << list
            else
              items[category][l1][:direct] ||= []
              items[category][l1][:direct] << list
            end
          else
            items[category][:direct] ||= []
            items[category][:direct] << list
          end
        else
          items[:direct] ||= []
          items[:direct] << list
        end

        ifsg = @iconfilesubgroups[key]
        ifsg = Iconfilesubgroup.new(index, category, l1, l2) unless ifsg
        list.map { |icfile| ifsg.add(icfile) }
        ifsg.post_process
        @iconfilesubgroups[key] = ifsg
        @iconfilesubgroups_by_icon_size[ifsg.num_of_iconfiles] ||= []
        @iconfilesubgroups_by_icon_size[ifsg.num_of_iconfiles] << ifsg
        key = [ifsg.min_icon_size, ifsg.max_icon_size]
        @iconfilesubgroups_by_icon_size_range[key] ||= []
        @iconfilesubgroups_by_icon_size_range[key] << ifsg
      end
    end

    def to_json
      @iconfilesubgroups.each do |key, ifsg|
        ifsg.to_json
      end
    end

    def copy_to(output_dir_pn)
      @iconfilesubgroups_by_icon_size_range.each do |key, value|
        value.each do |ifsg|
          dest_pn = (output_dir_pn + ifsg.category)
          dest_pn.mkpath
          ifsg.iconfiles.each do |icf|
            FileUtils.copy(icf.pathn, dest_pn)
          end
        end
      end
    end

    def print
      @iconfilesubgroups.each do |key, ifsg|
        ifsg.print
      end
    end

    def print_l1
      p "@iconfilesubgroups #{@iconfilesubgroups}"
      @iconfilesubgroups.each do |key, ifsg|
        ifsg.print_l1
      end
    end

    def print_l1_icon_size
      iconfiles_by_icon_size.each do |key, value|
        p "icon_size=#{key} value.size=#{value.size}"
      end
    end

    def print2
      @iconfilesubgroups_by_icon_size.each do |key, value|
        p "@iconfilesubgroups_by_icon_size key=#{key} value.size=#{value.size}"
        value.each do |ifsg|
          p "###==== S"
          p "ifsg.id_num=#{ifsg.id_num}"
          p "ifsg.category=#{ifsg.category}"
          p "ifsg.icon_size_list=#{ifsg.icon_size_list}"
          p "ifsg.max_icon_size=#{ifsg.max_icon_size}"
          p "ifsg.min_icon_size=#{ifsg.min_icon_size}"
          ifsg.iconfiles.each do |icf|
            p "icf.pathn=#{icf.pathn}"
          end
          p "ifsg.num_of_iconfiles=#{ifsg.num_of_iconfiles}"
          p "ifsg.icon_size_list_size=#{ifsg.icon_size_list_size}"
          p "###==== E"
          p ""
        end
        p "#####"
      end
      #
      @iconfilesubgroups_by_icon_size_range.each do |key, value|
        p "@iconfilesubgroups_by_icon_size_range key=#{key} value.size=#{value.size}"
        value.each do |ifsg|
          p "ifsg.icon_size_list=#{ifsg.icon_size_list}"

        end
        p "===="
      end
    end

    def print_l2
      p "iconfilesubgroups_by_icon_size_range #{@iconfilesubgroups_by_icon_size_range}"
    end

    def print_l2_icon_size
      p "==================== print_l2_icon_size"
      @iconfilesubgroups_by_icon_size.each do |key, value|
        p "key=#{key} value.size=#{value.size}"
      end
    end
  end
end
