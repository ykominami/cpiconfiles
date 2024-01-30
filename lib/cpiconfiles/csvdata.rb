module Cpiconfiles
  class CvsdatAarray < Array
    alias find_original find

    def set_csvdata(csvdata)
      @csvdata = csvdata
      self
    end

    def find(name, value)
      @csvdata.find(name, value, self)
    end
  end

  class Csvdataitem
    attr_reader :row, :kind, :icon_size, :category, :basename, :path, :parent_pn,
                :pattern, :kx1, :kx2, :kx3, :l1, :l2

    def initialize(row)
      @row = row
      # csv_class = Struct.new("Csv", :kind, :icon_size, :category, :base, :path)

      @kind = row.kind
      @icon_size = row.icon_size.to_i
      @category = row.category
      @basename = row.base
      @path = row.path
      @parent_pn = Pathname.new(@path).parent
      @pattern, @kx1, @kx2, @kx3 = order_basename_by_category(@basename)
      determine_hier(pattern, kx1, kx2, kx3)
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

    def order_basename_by_category(basename)
      kx = basename
      if kx =~ /^(.+)\-(.+)\-(.+)$/
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:three_parts, kx1, kx2, kx3]

        # @iconfiles_by_category[kx1] ||= {}
        # @iconfiles_by_category[kx1][kx3] ||= {}
        # @iconfiles_by_category[kx1][kx3] << icf
      elsif kx =~ /^(.+)\-(.+)x(.+)$/
        # not match
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:with_twice_size, kx1, kx2, kx3]
        # @iconfiles_by_category[kx1] ||= []
        # @iconfiles_by_category[kx1] << icf
      elsif kx =~ /^(.+)_(.+)x(.+)$/
        kx1 = $1
        kx2 = $2
        kx3 = $3
        return [:with_twice_size_2, kx1, kx2, kx3]
        # @iconfiles_by_category[kx1] ||= []
        # @iconfiles_by_category[kx1] << icf
      elsif kx =~ /^(.+)(\s+)(.+)x(.+)$/
        # not match
        kx1 = $1
        kx2 = $2
        kx3 = $3
        kx4 = $4
        kx1ex = "#{kx1}#{kx2}"
        return [:with_space_and_twice_size, kx1ex, kx3, kx4]
        # @iconfiles_by_category[kx1] ||= []
        # @iconfiles_by_category[kx1] << icf
      else
        kx1 = kx
        return [:else, kx1]
        # @iconfiles_by_category[kx1] ||= []
        # @iconfiles_by_category[kx1] << icf
      end
    end
  end

  class Csvdata
    attr_reader :kinds, :icon_sizes, :categories, :basenames, :paths, :l1, :l2, :items

    def initialize(*rows)
      @rows = rows
      @items = @rows.map { |row| Csvdataitem.new(row) }

      @kinds = make_uniq_field("kind")
      @icon_sizes = make_uniq_field("icon_size")
      @categories = make_uniq_field("category")
      @basenames = make_uniq_field("basename")
      @paths = make_uniq_field("path")
      @l1s = make_uniq_field("l1")
      @l2s = make_uniq_field("l2")
    end

    def make_uniq_field(name)
      @items.map { |item| item.send(name) }.uniq
    end

    def find(name, value, items = nil)
      items ||= @items
      list = items.select { |item| item.send(name) == value }
      create_csvdata(list)
    end

    def print_l1
      @l1s.each do |l1|
        p "l1=#{l1}"
        find("l1", l1).sort_by { |item| item.l2 }.each do |item|
          p item.path
        end
      end
    end

    def create_csvdata(obj)
      CvsdatAarray.new(obj).set_csvdata(self)
    end

    def print_l1_icon_size
      count = 0
      @l1s.each do |l1|
        list = find("l1", l1)
        if count == 0 && list.size > 10
          count += 1
          p "l1=#{l1}"
          category_list = list.map { |item| item.category }.uniq
          category_list.each do |cate|
            list.find("category", cate).sort_by { |item| item.l2 }.each do |item|
              p "#{item.path} #{item.l2} #{item.icon_size}"
            end
          end
        end
      end

      def print_l2
        @l2s.each do |l2|
          p "l2=#{l2}"
          list = find("l2", l2)
          if list.size > 10
            list.sort_by { |item| item.l1 }.each do |item|
              p item.path
            end
          end
        end
      end
    end
  end
end
