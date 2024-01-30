module Cpiconfiles
  # TODO: class Iconfilegroupを実装する
  class Iconfilegroup
    @iconfilegroup = {}

    def self.register(obj, level, top, first, second = nil)
      @iconfilegroup[level] ||= {}
      @iconfilegroup[level][top] ||= {}
      if level == :two_level
        @iconfilegroup[level][top][first] ||= {}
        @iconfilegroup[level][top][first][second] ||= []
        @iconfilegroup[level][top][first][second] << obj
      else
        @iconfilegroup[level][top][first] ||= []
        @iconfilegroup[level][top][first] << obj
      end
      # @level :two_level, top, first, second
    end

    def initialize(top_dir_pn, parent_pn, sizepat)
      @top_dir_pn = top_dir_pn
      @parent_pn = parent_pn
      @sizepat = sizepat
      @iconfiles = []

      @pathns_byicon_size = {}
    end

    def setup_for_iconfiles
      @base_pns = make_uniq_field('base_pn')
      @basenames = make_uniq_field('basename')
      @extnames = make_uniq_field('extname')
      @parent_basenames = make_uniq_field('parent_basename')
      @kinds = make_uniq_field('kind')
      @icon_sizes = make_uniq_field('icon_size')
      @l1s = make_uniq_field('l1')
      @l2s = make_uniq_field('l2')
      @pathns = make_uniq_field('pathn')
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
      Loggerxcm.debug 'save_as_csv S'
      @iconfiles.map do |icf|
        file.write("#{icf.kind},#{icf.icon_size},#{icf.parent_basename},#{icf.basename},#{icf.pathn}\n")
      end
      Loggerxcm.debug 'save_as_csv E'
    end

    def print
      @iconfiles.map do |icf|
        Loggerxcm.debug icf.pathn.to_s
      end
    end

    def print_l1
      @l1s.each do |l1|
        p "l1=#{l1}"
        findx('l1', l1).sort_by(&:l2).each do |item|
          p item.path
        end
      end
    end

    def print_l1_icon_size
      count = 0
      @l1s.each do |l1|
        list = findx('l1', l1)
        next unless count.zero? && list.size > 10

        count += 1
        category_list = list.map(&:category).uniq
        category_list.each do |cate|
          list.findx('category', cate).sort_by(&:l2).each do |item|
            p "#{item.path} #{item.l2} #{item.icon_size}"
          end
        end
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
