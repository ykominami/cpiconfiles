require 'yaml'
require 'pathname'
require 'pstore'

module Cpiconfiles
  class Iconlist
    attr_reader :obj, :l1_keys

    def initialize(list_fname)
      log_level = :info
      # log_level = :debug
      Loggerxcm.log_init(log_level)

      @list_fname = list_fname
      # @yaml_fname_w = "#{yaml_fname}.tmp"
      @pathns ||= {}
      @pathns_byicon_size = {}
      @obj = {}
      # init

      @iconfilegroups = {}

      @store = PStore.new(@list_fname)
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

    def create_paths(iconfiles)
      @pathns.keys.map { |key| Loggerxcm.debug key.to_s }
      iconfiles.map do |icf|
        @pathns[icf.parent_relative_pathn.to_s] ||= {}
        part_names = icf.part_name
        name1 = part_names.shift
        if part_names.size.positive?
          @pathns[icf.parent_relative_pathn.to_s][name1] ||= {}
          name2 = part_names.shift
          if icf.instance_of?(String)
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] ||= {}
            @pathns[icf.parent_relative_pathn.to_s][name1][name2][icf] = []
          else
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] ||= []
            @pathns[icf.parent_relative_pathn.to_s][name1][name2] << icf
          end
        else
          @pathns[icf.parent_relative_pathn.to_s][name1] ||= []
          @pathns[icf.parent_relative_pathn.to_s][name1] << icf
        end
        @pathns_byicon_size[icf.icon_size] ||= []
        @pathns_byicon_size[icf.icon_size] << icf
      end
      @l1_keys = @pathns.keys
    end

    def l2_keys(l1_key)
      @pathns[l1_key].keys
    end

    def pathn_by_keys(l1_key, l2_key)
      @pathns[l1_key][l2_key]
    end

    def make_iconfilegroups
      @pathns.keys.sort_by(&:to_s)
             .map do |pn|
        base = pn.basename.to_s
        @iconfilegroups[base] = {}
        icfg = Iconfilegroup.new(base, pn)
        @pathns[pn].each_key do |key|
          icfg.add(key, @pathns[pn][key])
          @iconfilegroups[base][key] = icfg
        end
      end
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

    def save
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
      @iconfilegroups.map do |key, hash|
        hash.map do |key2, icfg|
          Loggerxcm.debug "#{key} | #{key2}"
          icfg.print
        end
      end
    end

    def print_pathns2
      Loggerxcm.debug '===='
      # Loggerxcm.debug@pathns
      Loggerxcm.debug @pathns.keys
      keys = @pathns.keys.map { |key| [key.to_s, key] }
      Loggerxcm.debug keys
      # sort_by{ |key| key.to_s }
    end

    def print_pathns
      Loggerxcm.debug '===='
      Loggerxcm.debug @pathns
      @pathns.keys.sort_by(&:to_s)
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

    def print_paths_by_size
      Loggerxcm.debug '====######'
      pathns_byicon_size.keys.sort.each do |key|
        Loggerxcm.debug "key=#{key}"
        Loggerxcm.debug "size=#{pathns_byicon_size[key].size}"
      end
    end

    def print_paths_by_size2
      #   "key=0"
      #     "size=1"
      #   "key=1"
      #     "size=100"
      #   "key=2"
      #     "size=166"
      #   "key=3"
      #     "size=145"
      #   "key=10"
      #     "size=1"
      #   "key=16"
      #     "size=61"
      #   "key=24"
      #     "size=137"
      #   "key=32"
      #     "size=139"
      #   "key=48"
      #     "size=138"
      #   "key=64"
      #     "size=79"
      #   "key=128"
      #     "size=79"
      #   "key=192"
      #     "size=1"
      #   "key=256"
      #     "size=88"
      #   "key=512"
      #     "size=8"
      sizes = [16, 24, 32, 48, 64, 128, 256, 512]
      Loggerxcm.debug '====='
      sizes.map do |size|
        Loggerxcm.debug "#### size=#{size}"
        pathns_byicon_size[size].each do |icf|
          Loggerxcm.debug icf.path
        end
      end
    end
  end
end
