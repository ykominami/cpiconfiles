module Cpiconfiles
  class CvsdatAarray < Array
#    alias find_original find

    def set_csvdata(csvdata)
      @csvdata = csvdata
      self
    end

    def findx(name, value)
      @csvdata.findx(name, value, self)
    end
  end

  class Csvdataitem
    attr_reader :row, :kind, :icon_size, :basename, :path, :parent_pn,
                :pattern, :kx1, :kx2, :kx3, :l1, :l2
    attr_accessor :category
 
    def initialize(row)
      @row = row
      # csv_class = Struct.new("Csv", :kind, :icon_size, :base, :path)
      @kind = row.kind
      @icon_size = row.icon_size.to_i

      @basename = row.base
      @path = row.path
      @parent_pn = Pathname.new(@path).parent

      # @category = row.category
      @category ||= Pathname.new(@path).parent.basename('.*').to_s

      @pattern, @kx1, @kx2, @kx3 = order_basename_by_category(@basename)
      determine_hier(pattern, kx1, kx2, kx3)
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

    def order_basename_by_category(basename)
      # kx1 = kx2 = kx3 = nil
      case basename
      when /^(.+)-(.+)-(.+)$/
        kx1 = Regexp.last_match(1)
        kx2 = Regexp.last_match(2)
        kx3 = Regexp.last_match(3)
        [:three_parts, kx1, kx2, kx3]
      when /^(.+)-(.+)x(.+)$/
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
  end

  class Csvdata
    attr_reader :kinds, :icon_sizes, :basenames, :paths, :l1, :l2, :items
    attr_accessor :categories
    def initialize(*rows)
      @rows = rows
      @items = @rows.map { |row| Csvdataitem.new(row) }
      setup_for_iconfiles
    end

    def setup_for_iconfiles
      @kinds = make_uniq_field('kind')
      @icon_sizes = make_uniq_field('icon_size')
      @basenames = make_uniq_field('basename')
      @paths = make_uniq_field('path')
      @l1s = make_uniq_field('l1')
      @l2s = make_uniq_field('l2')
      # @category = @paths.parent.basename('.*').to_s
      @categories = make_uniq_field('category')

      # p @paths
#      p @paths
#      p "==="
      # @categories = @paths.map{ |path| Pathname.new(path).parent.basename('.*').to_s }.uniq
# p @categories

#      @categories = make_uniq_field('category')
    end

    def make_uniq_field(name)
      @items.map { |item| item.send(name) }.uniq
    end

    def findx(name, value, items = nil)
      items ||= @items
      list = items.select { |item| item.send(name) == value }
      create_csvdata(list)
    end

    def print_l1
      @l1s.each do |l1|
        p "l1=#{l1}"
        findx('l1', l1).sort_by(&:l2).each do |item|
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
        list = findx('l1', l1)
        next unless count.zero? && list.size > 10

        count += 1
        p "l1=#{l1}"
        category_list = list.map(&:category).uniq
        category_list.each do |cate|
          list.findx('category', cate).sort_by(&:l2).each do |item|
            p "#{item.path} #{item.l2} #{item.icon_size}"
          end
        end
      end
    end

    def print2
      count = 0
      @l1s.each do |l1|
        list = findx('l1', l1)
        next unless count.zero? && list.size > 10
        break if count > 0

        count += 1
        category_list = list.map(&:category).uniq
        # p "category_list=#{category_list}"
        p "category_list=#{category_list[1]}"
        break
=begin 
        category_list.each do |cate|
          list.findx('category', cate).sort_by(&:l2).each do |item|
            p "#{item.path} #{item.l2} #{item.icon_size}"
          end
        end
=end
      end
    end

    def print_l2
      @l2s.each do |l2|
        p "l2=#{l2}"
        list = findx('l2', l2)
        next unless list.size > 10

        list.sort_by(&:l1).each do |item|
          p item.path
        end
      end
    end
  end
end
