module Cpiconfiles
  class Yamlstore
    class Item
      attr_reader :save_hs
      attr_accessor :hs, :restore_hs
      def initialize()
        @count = 0
        @data_hs = {}
        @data_array = []
        @save_hs = {}
        # @save_array = []

        @load_hs = {}
        @recove_hs = {}
        @restore_hs = {}
      end

      def get_id_num(obj)
        @data_hs[obj]
      end

=begin
      def to_h()
        hash = {}
        @save_hs.each do |key, val|
          hash[key] = val.to_h
        end
        hash
      end
=end
      def add(obj)
        count = get_id_num(obj)
        if count == nil
          # obj.set_idnum(count)
          count = @data_hs[obj] = @count
          # raise
          # obj["id_numn"] = count
          @data_array << obj
          store_obj = obj.save_to_obj(count)
          p "count=#{count} store_obj=#{store_obj} obj.class=#{obj.class}"
          h = store_obj.to_h
          @save_hs[count] = h
          # @save_array << h
          @count += 1
        end
        count
      end

      def load(id_num, obj)
        p "load obj.id_num=#{id_num} obj=#{obj}"
        raise if @load_hs[id_num] != nil
        raise if obj.id_num != id_num
        @restore_hs[id_num] = obj
      end

      def recover(id_num)
        obj = @restore_hs[id_num]
        @recover_hs[id_num] = obj.dup.class.recover(obj)
      end

      def count_of_loading()
        @restore_hs.size
      end

      def restore(hash)
        @restore_hs = hash
      end

      def get_data_hs()
        @data_hs
      end

      def get_restore_hs()
        @restore_hs
      end
    end

    @item_hs = Hash.new(Item.new)
    # @item_hs[:iconfilegroup] =
    # @item_hs[:iconfilesubgroup] = Item.new
    # @item_hs[:iconfile] = Item.new
    # @item_hs[:iconlist] = Item.new
    @item_hs[:yaml] = {}

    @klass = {
      :iconfilegroup => Iconfilegroup,
      :iconfilesubgroup => Iconfilesubgroup,
      :iconfile => Iconfile,
      :iconlist => Iconlist
    }

    class << self
      def get_id_num_base(key, value)
        raise if value.class != @klass[key]
        @item_hs[key].get_id_num(value)
      end

      def add_base(key, value)
        p "value.class=#{value.class}"
        p "klass[key]=#{@klass[key]}"
        # raise if value.class != @klass[key]
        @item_hs[key].add(value)
      end

      def add_iconfilegroup(icfg)
        add_base(:iconfilegroup, icfg)
      end

      def add_iconfilesubgroup(icfsg)
        add_base(:iconfilesubgroup, icfsg)
      end

      def add_iconfile(icf)
        add_base(:iconfile, icf)
      end

      def add_iconlist(icl)
        add_base(:iconlist, icl)
      end
      #
      def get_recover_base(key, id_num)
        @item_hs[key].recover(id_num)
      end

      def recover_base(key, id_num, value)
        @item_hs[key].set_recover(id_num, value)
      end

      def get_recover_base(key, id_num)
        @item_hs[key].set_recover(id_num)
      end
      #
      def restore_base(hash, key)
        @item_hs[key].restore(hash)
      end

      def restore_iconfilegroup(hash)
        @item_hs[:iconfilegroup].restore(hash)
      end

      def restore_iconfilesubgroup(hash)
        @item_hs[:iconfilesubgroup].restore(hash)
      end
 
      def restore_iconfile(hash)
        @item_hs[:iconfile].restore(hash)
      end
 
      def restore_iconlist(hash)
        @item_hs[:iconlist].restore(hash)
      end

      #
      def load_base(key, id_num, obj)
        @item_hs[key].load(id_num,obj)
      end

      def load_iconfilegroup(id_num, obj)
        @item_hs[:iconfilegroup].load(id_num, obj)
      end

      def load_iconfilesubgroup(id_num, obj)
        @item_hs[:iconfilesubgroup].load(obj, id_num)
      end
 
      def load_iconfile(id_num, obj)
        @item_hs[:iconfile].load(id_num, obj)
      end
 
      def load_iconlist(id_num, obj)
        @item_hs[:iconlist].load(id_num, obj)
      end
      #
      def get_load_hs_base(key)
        @item_hs[key].load_hs
      end

      def get_hs_base(key)
        @item_hs[key].hs
      end

      def get_restore_hs_base(key)
        @item_hs[key].restore_hs
      end

      def get_iconfilegroup_hs
        @item_hs[:iconfilegroup].hs
      end

      def get_iconfilesubgroup_hs
        @item_hs[:iconfilesubgroup].hs
      end

      def get_iconfile_hs
        @item_hs[:iconfile].hs
      end

      def get_iconlist_hs
        @item_hs[:iconlist].hs
      end

      def get_yaml_hs
        @item_hs[:yaml]
      end
      #
      def num_of_base(key)
        @item_hs[key].count_of_loading
      end
      #
      def load(fname)
        content = File.read(fname)
        @item_hs[:yaml] = YAML.safe_load(content, 
        permitted_classes: [Symbol],
        aliases: true)
      end

      def save(fname)
        obj = {
          "iconfilegroup" => @item_hs[:iconfilegroup].save_hs,
          # "iconfilegroup" => [],
          "iconfilesubgroup" => @item_hs[:iconfilesubgroup].save_hs,
          # "iconfilesubgroup" => {},
          "iconfile" => @item_hs[:iconfile].save_hs,
          "iconlist" => @item_hs[:iconlist].save_hs
        }
        #raise if obj["iconfilegroup"].size.zero?
        # raise if obj["iconfilesubgroup"].size.zero?
        raise if obj["iconfile"].size.zero?
        raise if obj["iconlist"].size.zero?
        content = YAML.dump(obj)
        File.write(fname, content)
        p @item_hs[:iconfile].save_hs
        p 'obj["iconlist"]='
        p obj["iconlist"]
        p "============="
        p YAML.dump(obj["iconlist"])
        p "============="
        xobj = obj["iconlist"].to_h
        File.write("ax.yml", YAML.dump(xobj) )
      end

      def loadx_sub(obj, keyx, klass, var_name_part)
        hs = obj[keyx.to_s]
        hs.each do |key, val|
          p "key=#{key} val.class=#{val.class} val=#{val}"
          # x = klass.make(**val)
          x = klass.make_store(val)
          # x.class.load_from_obj(x)
          load_base(keyx, key, x)
        end
        # num_of_icfg = num_of_iconfilegroup()
        num = num_of_base(keyx)
        p "num_of_#{var_name_part}=#{num}"
        p ""
      end

      def loadx(obj)
        loadx_sub(obj, :iconfilegroup, Iconfilegroup, "icfg")
        loadx_sub(obj, :iconfilesubgroup, Iconfilesubgroup, "icfsg")
        loadx_sub(obj, :iconfile, Iconfile, "icf")
        loadx_sub(obj, :iconlist, Iconlist, "icl")
      end

      def print_hash(hash)
        hash.each do |key, val|
          p "key=#{key}"
          p "val=#{val}"
        end
      end

      def restorex_sub(keyx)
        load_hs = get_restore_hs_base(keyx)
        print_hash(load_hs)
      end


      def restorex(obj, dump_fname, sizepat)
        @sizepat = sizepat
        p "Yamlstore.restore 1"
        keyx = :iconfile
        restorex_sub(keyx)
        p ""

        p "Yamlstore.restore 2"
        keyx = :iconfilesubgroup
        restorex_sub(keyx)
        p ""

        p "Yamlstore.restore 3"
        keyx = :iconfilegroup
        restorex_sub(keyx)
        p ""
      end

      def restore(obj, dump_fname, sizepat)
        p "Yamlstore.restore 1"
        @sizepat = sizepat
        p "Yamlstore.restore 2"
        icf_hs = Iconfile.restore(obj["iconfile"], @sizepat)
        restore_iconfile(icf_hs)
        p "Yamlstore.restore 3"
        icfg_hs = Iconfilesubgroup.restore(obj["iconfilesubgroup"], @sizepat)
        restore_iconfilesubgroup(icfg_hs)
        p "Yamlstore.restore 4"
        icfsg_hs = Iconfilegroup.restore(obj["iconfilegroup"], @sizepat)
        restore_iconfilegroup(icfsg_hs)
        p "Yamlstore.restore 5"
        icl_hs = Iconlist.restore(obj["iconlist"], dump_fname, @sizepat)
        restore_iconlist(icl_hs)
        p "Yamlstore.restore 6"
      end
    end
  end
end
