require 'yaml'
require 'pathname'
require 'pstore'

module Cpiconfiles
  class Iconlist
    attr_reader :obj, :l1_keys

    def initialize(list_fname, top_dir_pn = nil)
      log_level = :info
      # log_level = :debug
      Loggerxcm.log_init(log_level)

      @list_fname = list_fname
      # @yaml_fname_w = "#{yaml_fname}.tmp"
      @pathns ||= {}
      @pathns_byicon_size = {}
      @obj = {}
      # init
      @top_dir_pn = top_dir_pn

      @iconfilegroups = {}

      @store = PStore.new(@list_fname)
      @sizepat = Sizepattern.new

      @l1_keys = {}
    end

    def prepare_for_save
      @obj[:pathns] = @pathns
      Loggerxcm.debug "prepare_for_save @pathns.size=#{@pathns.size}"
      @obj[:pathns_byicon_size] = @pathns_byicon_size
    end

    def postprocess_for_save
      @pathns = @obj[:pathns]
      Loggerxcm.debug "prepare_for_save @pathns.size=#{@pathns.size}"
      @pathns_byicon_size = @obj[:pathns_byicon_size]
    end

    def l2_keys(l1_key)
      @pathns[l1_key].keys
    end

    def pathn_by_keys(l1_key, l2_key)
      @pathns[l1_key][l2_key]
    end

    def collect(dir_pn, parent_sizeddir = nil)
      ifg = Iconfilegroup.new(@top_dir_pn, dir_pn, @sizepat)
      ifg.collect(dir_pn, parent_sizeddir)
      @iconfilegroups[dir_pn] = ifg
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
      @store.transaction(true) do
        # オブジェクトをデシリアライズ
        @obj = @store[:my_object]
        postprocess_for_save
        # check_files
        Loggerxcm.debug '#=== load'
      end
    end

    def save_as_csv(csv_file)
      Loggerxcm.debug "############################## Iconlist#save_as_csv S csv_file=#{csv_file}"
      csv_file = Pathname.new(csv_file)
      csv_file.open('w') do |file|
        @iconfilegroups.map do |key, icfg|
            puts "iconlist save_as_csv key=#{key}"
            icfg.save_as_csv(file)
        end
      end
      Loggerxcm.debug "############################## Iconlist#save_as_csv E csv_file=#{csv_file}"
      csv_file
    end

    def dump
      @store.transaction do
        Loggerxcm.debug 'save # S'
        prepare_for_save
        check_files
        Loggerxcm.debug 'save # S E'
        # オブジェクトをシリアライズ
        @store[:my_object] = @obj

        # トランザクションの終了（このブロックを抜けると自動的に終了します）
      end
    end

    def set_pathn(pathn)
      @pathns = pathn
      @obj[:paths] = @paths
    end

    def print
      @iconfilegroups.map do |key, icfg|
        Loggerxcm.debug "#{key}"
        icfg.print
      end
    end

    def print_l1
      @iconfilegroups.map do |key, icfg|
        icfg.print_l1
      end
    end

    def print_l1_icon_size
      @iconfilegroups.map do |key, icfg|
        icfg.print_l1_icon_size
      end
    end

    def print_l2
      @iconfilegroups.map do |key, icfg|
        icfg.print_l2
      end
    end
  end
end
