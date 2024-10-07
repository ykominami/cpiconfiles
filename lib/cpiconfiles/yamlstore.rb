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
        @recover_hs = {}
        @restore_hs = {}
      end

      def get_id_num(obj)
        @data_hs[obj]
      end

      def add(obj)
        count = get_id_num(obj)
        if count == nil
          count = @data_hs[obj] = @count
          @data_array << obj
          store_obj = obj.save_to_obj(count)
          h = store_obj.to_h
          @save_hs[count] = h
          @count += 1
        end
        count
      end

      def load(id_num, obj)
        id_num_x = obj.id_num[:id_num]
        raise NotFoundInRestorehsByIdError.new("yamlstore load 3 id_num=#{id_num}") if @restore_hs[id_num] != nil
        raise NotEqualIdError.new("yamlstore load 4 id_num=#{id_num} obj.id_num=#{id_num_x}") if id_num_x != id_num
        @restore_hs[id_num] = obj
      end

      def recover(id_num)
        obj = @restore_hs[id_num]
        @recover_hs[id_num] = obj.dup.class.recover(obj)
      end

      def set_recover(id_num, obj)
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
        raise DifferentClassError if value.class != @klass[key]
        @item_hs[key].get_id_num(value)
      end

      def add_base(key, value)
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

      def set_recover_base(key, id_num)
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
        begin
          @item_hs[key].load(id_num , obj)
        rescue => exc
          puts "exc.message=#{exc.message}"
          puts "key=#{key} id_num=#{id_num}"
          exc.backtrace.map{|x| puts "#{x}\n"}
          exit
        end
      end

      def load_hs(key, id_num)
        begin
          @item_hs[key].load
        rescue => exc
          puts "exc.message=#{exc.message}"
          puts "key=#{key} id_num=#{id_num}"
          exc.backtrace.map{|x| puts "#{x}\n"}
          exit
        end
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
        raise NotFoundIconfileError.new("yamlstore save 1") if obj["iconfile"].size.zero?
        raise NotFoundIconlistError.new("yamlstore save 2")  if obj["iconlist"].size.zero?
        content = YAML.dump(obj)
        File.write(fname, content)
        xobj = obj["iconlist"].to_h
        File.write("ax.yml", YAML.dump(xobj) )
      end

      def loadx_sub(obj, keyx, klass, var_name_part)
        hs = obj[keyx.to_s]
        hs.each do |key, val|
          x = klass.make_store(val)
          load_base(keyx, key, x)
        end
        num = num_of_base(keyx)
      end

      def loadx(obj)
        loadx_sub(obj, :iconfilegroup, Iconfilegroup, "icfg")
        loadx_sub(obj, :iconfilesubgroup, Iconfilesubgroup, "icfsg")
        loadx_sub(obj, :iconfile, Iconfile, "icf")
        loadx_sub(obj, :iconlist, Iconlist, "icl")
      end

      def restorex_sub(keyx)
        load_hs = get_restore_hs_base(keyx)
      end

      def restorex
        keyx = :iconfile
        restorex_sub(keyx)

        keyx = :iconfilesubgroup
        restorex_sub(keyx)

        keyx = :iconfilegroup
        restorex_sub(keyx)
      end
    end
  end
end
