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
    attr_reader :kinds, :icon_sizes, :categories, :basenames, :paths, :l1, :l2, :items

    def initialize(*rows)
      @rows = rows
      @items = @rows.map { |row| Csvdataitem.new(row) }

      @kinds = make_uniq_field('kind')
      @icon_sizes = make_uniq_field('icon_size')
      @categories = make_uniq_field('category')
      @basenames = make_uniq_field('basename')
      @paths = make_uniq_field('path')
      @l1s = make_uniq_field('l1')
      @l2s = make_uniq_field('l2')
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
        find('l1', l1).sort_by(&:l2).each do |item|
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
        list = find('l1', l1)
        next unless count.zero? && list.size > 10

        count += 1
        p "l1=#{l1}"
        category_list = list.map(&:category).uniq
        category_list.each do |cate|
          list.find('category', cate).sort_by(&:l2).each do |item|
            p "#{item.path} #{item.l2} #{item.icon_size}"
          end
        end
      end
    end

    def print_l2
      @l2s.each do |l2|
        p "l2=#{l2}"
        list = find('l2', l2)
        next unless list.size > 10

        list.sort_by(&:l1).each do |item|
          p item.path
        end
      end
    end
  end
end
