module Cpiconfiles
  class Iconfilesubgroup
    @store_class = Struct.new('IconfilesubgroupSave',
      :id_numn,
      :l1, :l2, :icon_size_list,
      :max_icon_size, :min_icon_size, :iconfiles, 
      :num_of_iconfiles, :icon_size_list_size,
      :copied)
  
    # @store_idnum_class = Struct.new("IconfilesubgroupSaveIdnum", :idnum)

    class << @store_class
      define_method(:load_from_obj) do
        p @l1
      end

      define_method(:to_h) do
        hash = {}
        hash["id_num"] = @id_num
        hash["l1"] = @l1
        hash["l2"] = @l2
        hash["icon_size_list"] = @icon_size_list
        hash["max_icon_size"] = @max_icon_size
        hash["min_icon_size"] = @min_icon_size
        hash["iconfiles"] = @iconfiles
        hash["num_of_iconfiles"] = @num_of_iconfiles
        hash["icon_size_list_size"] = @icon_size_list_size
        hash["copied"] = @copied
        hash
      end

      define_method(:recover) do
        hsx = {}
        @iconfiles.each do |obj|
          hsx["id_num"] = Yamlstore.get_recover(id_num)
        end
        hsx
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
          # p value.keys
          inst = create( **value )
          inst.from_h(value)
          obj_hs[key] = inst
        end
        obj_hs
      end
    end

    attr_reader :category, :l1, :l2, :icon_size_list, 
                :max_icon_size, :min_icon_size, :iconfiles, 
                :num_of_iconfiles, :icon_size_list_size,
                :copied
    def initialize(category, l1, l2)
      @category = category
      @l1 = l1
      @l2 = l2
      @icon_size_list = []
      @max_icon_size = 0
      @min_icon_size = 0
      @icon_size_list_size = 0
      @iconfiles = []
      @num_of_iconfiles = 0
      @copied = false
    end

    def make(count)
      self.class.store_class.new(
        count,
        @l1, @l2, @icon_size_list,
        @max_icon_size, @min_icon_size, @iconfiles,
        @num_of_iconfiles, @icon_size_list_size,
        @copied)
    end

    def from_h(hash)
      @icon_size_list = hash[:icon_size_list]
      @max_icon_size = hash[:max_icon_size]
      @min_icon_size = hash[:min_icon_size]
      @icon_size_list_size = hash[:icon_size_list_size]
      @iconfiles = hash[:iconfiles].map{ |key, id_num|
        # p %(#{key} #{id_num})
        id_num
      } 
      @num_of_iconfiles = hash[:num_of_iconfiles]
      @copied = hash[:copied] 
    end

    def to_h
      {
        "l1" => @l1,
        "l2" =>  @l2,
      }
    end

    def make(count)
      self.class.store_class.new(
        count,
        @category,
        @l1, @l2, @icon_size_list,
        @max_icon_size, @min_icon_size, @iconfiles,
        @num_of_iconfiles, @icon_size_list_size,
        @copied)
    end

    def save_to_obj(count)
      iconfiles_hs = {}
      @iconfiles.each do |icf|
        # icf.save_to_obj
        count = Yamlstore.add_iconfile(icf)
        iconfiles_hs[count] = count
      end

      self.class.store_class.new(
        @category, 
        @l1, @l2, @icon_size_list,

        @max_icon_size, @min_icon_size, iconfiles_hs,
        @num_of_iconfiles, @icon_size_list_size,
        @copied
      )
    end

    def copied
      @copied = true
    end

    def add(iconfile)
      @icon_size_list << iconfile.icon_size
      @iconfiles << iconfile
      @num_of_iconfiles += 1
    end

    def post_process
      @icon_size_list = @icon_size_list.sort
      @max_icon_size = @icon_size_list[-1]
      @min_icon_size = @icon_size_list[0]
      @icon_size_list_size = @icon_size_list.size
    end
  end
end
