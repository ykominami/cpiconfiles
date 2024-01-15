require 'yaml'
require 'pathname'
require 'pstore'

module Cpiconfiles
  class Iconlist
    class << self
      @log_level = nil
      @init_count = 0

      def log_init(log_level)
        return unless @log_level.nil?

        @log_level = log_level
        Loggerxs.init("log_", "log.txt", ".", true, log_level) if @init_count.zero?
        @init_count += 1
      end
    end

    attr_reader :obj, :l1_keys

    def initialize(list_fname)
      log_level = :info
      # log_level = :debug
      Log.log_init(log_level)
      log_level = :info

      @list_fname = list_fname
      # @yaml_fname_w = "#{yaml_fname}.tmp"
      @pathns ||= {}
      @pathnsByIconSize = {}
      @obj = {}
      # init

      @iconfilegroups = {}

      @store = PStore.new(@list_fname)
    end

    def prepare_for_save
      @obj[:pathns] = @pathns
      Loggerxcm.debug "prepare_for_save @pathns.size=#{@pathns.size}"
      @obj[:pathnsByIconSize] = @pathnsByIconSize
    end

    def postprocess_for_save
      @pathns = @obj[:pathns]
      Loggerxcm.debug "prepare_for_save @pathns.size=#{@pathns.size}"
      @pathnsByIconSize = @obj[:pathnsByIconSize]
    end

    def create_paths(iconfiles)
      # Loggerxcm.debug"iconfiles=#{iconfiles}"
      @pathns.keys.map { |_key| Loggerxcm.debugkey.to_s }
      iconfiles.map { |icf|
        @pathns[icf.parent_relative_pathn.to_s] ||= {}
        part_names = icf.part_name
        name1 = part_names.shift
        Loggerxcm.debug "==== #{part_names.size} part_names=#{part_names}"
        if part_names.size > 0
          @pathns[icf.parent_relative_pathn.to_s][name1] ||= {}
          name2 = part_names.shift
          if icf.instance_of?(String)
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] ||= {}
            @pathns[icf.parent_relative_pathn.to_s][name1][name2][icf] = []
            Loggerxcm.debug "zzzzzzzzzzzzzzzz #{icf.parent_relative_pathn} | #{name1} | #{name2} | #{icf}"
          else
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] ||= []
            Loggerxcm.debug "icf.class=#{icf.class}"
            ary = @pathns[icf.parent_relative_pathn.to_s][name1][name2]
            Loggerxcm.debug "0-0 ary.size=#{ary.size} ary[0]=#{ary[0]}"
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] << icf
            Loggerxcm.debug "0-1 ary.size=#{ary.size} ary[0]=#{ary[0]}"
            Loggerxcm.debug "yyyyyyy #{icf.parent_relative_pathn} | #{name1} | #{name2}"
          end
        else
          @pathns[icf.parent_relative_pathn.to_s][name1] ||= []
          if icf.instance_of?(String)
            Loggerxcm.debug "XXXXXXXXXXXXXXXXXXXXXXXXXXX            1"
            @pathns[icf.parent_relative_pathn.to_s][name1][icf] = []
          else
            Loggerxcm.debug "XXXXXXXXXXXXXXXXXXXXXXXXXXX            2"
            @pathns[icf.parent_relative_pathn.to_s][name1] << icf
          end
        end
        # Loggerxcm.debugicf.path
        # pathns[icf.parent_pathn] << icf

        @pathnsByIconSize[icf.icon_size] ||= []
        @pathnsByIconSize[icf.icon_size] << icf
      }
      @l1_keys = @pathns.keys
    end

    def l2_keys(l1_key)
      @pathns[l1_key].keys
    end

    def pathn_by_keys(l1_key, l2_key)
      @pathns[l1_key][l2_key]
    end

    def make_iconfilegroups
      @pathns.keys.sort_by { |key| key.to_s }
             .map { |pn|
        base = pn.basename.to_s
        @iconfilegroups[base] = {}
        icfg = Iconfilegroup.new(base, pn)
        @pathns[pn].keys.each do |key|
          icfg.add(key, @pathns[pn][key])
          @iconfilegroups[base][key] = icfg
        end
      }
    end

    def check_files
      ret = true
      # Loggerxcm.debug"@obj=#{@obj}"
      keys = @obj.keys
      Loggerxcm.debug keys
      # exit
      keys.each do |key|
        Loggerxcm.debug "key=#{key}"
        val = @obj[key]
        if val == nil || val.size == 0
          ret = false
        else
          Loggerxcm.debug "val.size=#{val.size}"
        end
      end
      ret
    end

    def load()
      @store.transaction(true) do
        # オブジェクトをデシリアライズ
        @obj = @store[:my_object]
        # Loggerxcm.debug@obj
        postprocess_for_save
        # check_files
        Loggerxcm.debug "#=== load"
      end
    end

    def save()
      @store.transaction do
        Loggerxcm.debug "save # S"
        prepare_for_save
        check_files
        Loggerxcm.debug "save # S E"
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
      @iconfilegroups.map { |key, hash|
        hash.map { |key2, icfg|
          Loggerxcm.debug "#{key} | #{key2}"
          icfg.print
        }
      }
    end

    def print_pathns2()
      Loggerxcm.debug "===="
      # Loggerxcm.debug@pathns
      Loggerxcm.debug @pathns.keys
      keys = @pathns.keys.map { |key| [key.to_s, key] }
      Loggerxcm.debug keys
      # sort_by{ |key| key.to_s }
    end

    def print_pathns()
      Loggerxcm.debug "===="
      Loggerxcm.debug @pathns
      @pathns.keys.sort_by { |key| key.to_s }
             .each do |pn|
        Loggerxcm.debug "pn=#{pn}"
        @pathns[pn].keys.sort.each do |key|
          Loggerxcm.debug "key=#{key}"
          @pathns[pn][key].each do |icf|
            Loggerxcm.debug icf.relative_path
            Loggerxcm.debug icf.str_reason
          end
        end
      end
    end

    def print_paths_by_size()
      Loggerxcm.debug "====######"
      pathnsByIconSize.keys.sort.each do |key|
        Loggerxcm.debug "key=#{key}"
        Loggerxcm.debug "size=#{pathnsByIconSize[key].size}"
      end
    end

    def print_paths_by_size2()
=begin
  "key=0"
    "size=1"
  "key=1"
    "size=100"
  "key=2"
    "size=166"
  "key=3"
    "size=145"
  "key=10"
    "size=1"
  "key=16"
    "size=61"
  "key=24"
    "size=137"
  "key=32"
    "size=139"
  "key=48"
    "size=138"
  "key=64"
    "size=79"
  "key=128"
    "size=79"
  "key=192"
    "size=1"
  "key=256"
    "size=88"
  "key=512"
    "size=8"
=end
      sizes0 = [0, 1, 2, 3, 10, 16, 24, 32, 48, 64, 128, 192, 256, 512]
      sizes = [16, 24, 32, 48, 64, 128, 256, 512]
      Loggerxcm.debug "====="
      sizes.map { |size|
        Loggerxcm.debug "#### size=#{size}"
        pathnsByIconSize[size].each do |icf|
          Loggerxcm.debug icf.path
        end
      }
    end
  end
end
