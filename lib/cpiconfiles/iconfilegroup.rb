module Cpiconfiles
  # TODO: class Iconfilegroupを実装する
  class Iconfilegroup
    @store_class = Struct.new("IconfilegroupSave", 
      :id_numn,
      :top_dir, :parent, 
      :iconfiles_hs, :iconfiles_by_icon_size,
      :iconfilesubgroups, :iconfilesubgroups_by_icon_size,
      :iconfilesubgroups_by_icon_size_range)

      @store_idnum_class = Struct.new("IconfilegroupSaveIdnum", :idnum)

    class << @store_class
      define_method(:load_from_obj) do
        p inst[:iconfiles_hs]
      end

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
=begin
      def create(value, sizepat)
        s_inst = @store_class.new(**value)
        top_dir_pn = Pathname.new(s_inst.top_dir)
        parent_pn = Pathname.new(s_inst.parent)
        new(top_dir_pn, parent_pn, sizepat)
      end
=end
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
        @top_dir_pn.to_s, @parent_pn.to_s,
        @iconfiles_hs, @iconfiles_by_icon_size,
        @iconfilesubgroups, @iconfilesubgroups_by_icon_size,
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
        p "################### Iconfilegroup#save_to_obj 0"
        iconfiles_hs = {}
        @iconfiles_hs.each_with_object({}) { |(key, icf_array), iconfiles_hs|
            iconfiles_hs[key.to_s] = icf_array.map{ |icf|
            Yamlstore.add_base(:iconfile, icf)
          }
        }
        p "################### Iconfilegroup#save_to_obj 1"
        iconfiles_by_icon_size = {}
        @iconfiles_by_icon_size.each do |key, icf_array|
          iconfiles_by_icon_size[key] = icf_array.map{ |icf| 
            Yamlstore.add_iconfile(icf)
          }
        end
        p "################### Iconfilegroup#save_to_obj 2"
        iconfilesubgroups = {}
        # @iconfilesubgroups.keyssize
        p "@iconfilesubgroups=#{@iconfilesubgroups}"
        @iconfilesubgroups.each do |key, icfsg|
          key_str = key.join('|')
          p "------ key_str=#{key_str}"
          # icfsg.save_to_obj()
          iconfilesubgroups[key_str] = Yamlstore.add_iconfilesubgroup(icfsg)
        end
        p "################### Iconfilegroup#save_to_obj 3"
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
      # p "#############  Iconfilegroup setup_for_iconfiles S"
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

      # @top_dir_pn = top_dir_pn
      icon_files = []
      # Loggerxcm.debug  "dir_pn~#{dir_pn}"
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
      p "Iconfilegroup#analyze @iconfiles_hs=#{@iconfiles_hs}"

      @iconfiles_hs.each do |key, list|
        p "Iconfilegroup#analyze key=#{key} list.size=#{list.size}"
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
        ifsg = Iconfilesubgroup.new(category, l1, l2) unless ifsg
        list.map { |icfile| ifsg.add(icfile) }
        ifsg.post_process
        @iconfilesubgroups[key] = ifsg
        @iconfilesubgroups_by_icon_size[ifsg.num_of_iconfiles] ||= []
        @iconfilesubgroups_by_icon_size[ifsg.num_of_iconfiles] << ifsg
        key = [ifsg.min_icon_size, ifsg.max_icon_size]
        @iconfilesubgroups_by_icon_size_range[key] ||= []
        @iconfilesubgroups_by_icon_size_range[key] << ifsg

        p "@iconfilesubgroups.keys=#{@iconfilesubgroups.keys}"
      end
      p "@iconfilesubgroups.keyssize=#{@iconfilesubgroups.keys.size}"

    end

    def print
      @iconfiles.map do |icf|
        Loggerxcm.debug icf.pathn.to_s
      end
    end

    def to_json
      @iconfilesubgroups.each do |key, ifsg|
        ifsg.to_json
      end
    end

    def print2
      @iconfilesubgroups.each do |key, item| category, l1, l2 = key
        
 # p "#{item.path} #{item.l2} #{item.icon_size}"
        p "#{item.category} #{item.l1} #{item.l2} #{item.num_of_iconfiles}"       end
      p "===="
      @iconfilesubgroups_by_icon_size.each do |key, list|
        p "key=#{key} list.size=#{list.size}"
      end
      p "===="
      @iconfilesubgroups_by_icon_size_range.each do |key, list|
        p "key=#{key} range_size=#{list.first.icon_size_list.size} list.size=#{list.size}"
      end
      p "===="
      @iconfiles_by_icon_size.each do |key, list|
        p "icon_size=#{key} list.size=#{list.size}"
      end
      p "===="
      icon_size = 16
      findx("min_icon_size", icon_size, @iconfilesubgroups.values)
        .findx("icon_size_list_size", 5)
        .sort_by(&:l1)
        .sort_by(&:l2)
        .each do |item|
        p "#{item.category} #{item.l1} #{item.l2} #{item.icon_size_list_size} | #{item.icon_size_list}"
      end
      p "===="
      icon_size_list_size = 5
      listx = findx("icon_size_list_size", icon_size_list_size, @iconfilesubgroups.values)
        .sort_by(&:l1)
      p "listx.size=#{listx.size}"

      listx.each do |item|
        #        p "#{item.category}/#{item.l1}/#{item.l2} #{item.icon_size_list_size} | #{item.icon_size_list} | #{item.iconfiles[0].path}"
        p "#{item.category}/#{item.l1}/#{item.l2} #{item.icon_size_list_size} | #{item.icon_size_list}"
      end
    end

    def print_l1
      @l1s.each do |l1|
        p "l1=#{l1}"
        findx("l1", l1).sort_by(&:l2).each do |item|
          p item.path
        end
      end
    end

    def print_l1_icon_size
      count = 0
      @l1s.each do |l1|
        list = findx("l1", l1)
        next unless count.zero? && list.size > 10

        count += 1
        category_list = list.map(&:category).uniq
        category_list.each do |cate|
          list.findx("category", cate).sort_by(&:l2).each do |item|
            p "#{item.path} #{item.l2} #{item.num_of_iconfiles}"
          end
        end
      end
    end

    def print_l2
      @l2s.each do |l2|
        p "l2=#{l2}"
        list = findx("l2", l2)
        next unless list.size > 10

        list.sort_by(&:l1).each do |item|
          p item.path
        end
      end
    end
  end
end
