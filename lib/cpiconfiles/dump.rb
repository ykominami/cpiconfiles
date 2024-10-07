require "pstore"

module Cpiconfiles # frozen_string_literal: true
  class Dump
    def initialize(dump_fname, dont_use_dump_file)
      @store = nil
      @obj = {}
      @defalut_dump_filename = 'cpiconfiles.dump'

      if dont_use_dump_file
        @dump_file_pn = nil
      elsif dump_fname.nil?
        @dump_file_pn = Pathname.new(@defalut_dump_filename)
      else
        @dump_file_pn = Pathname.new(dump_fname)
      end

      if (@dump_file_pn && @dump_file_pn.exist?)
        begin
          @store = PStore.new(@dump_file_pn.to_s)
        rescue PStore::Error => e
          puts "Error opening PStore: #{e.message}"
          # Handle the error, e.g. by creating a new PStore file or repairing the existing one
        end
      end

      @iconfilegroups = {}
    end

    def load
      ret = :NOT_LOAD
      return [ret, @iconfilegroups] unless @store

      ret = :FAIL_LOAD
      @store.transaction(true) do
        # オブジェクトをデシリアライズ
        @obj = @store[:my_object]
        postprocess_for_load
        # check_files
        Loggerxcm.debug "#=== load"
        ret = :SUCCESS_LOAD
      end

      [ret, @iconfilegroups]
    end

    def postprocess_for_load
      raise NotInstanceOfHashError.new("Dump postprocess_for_load 0") unless @obj[:iconfilegroups].instance_of?(Hash)
      @iconfilegroups = @obj[:iconfilegroups]
      raise NotIconfilegroupError.new("Dump postprocess_for_load 1") if @iconfilegroups.nil?
      @iconfilegroups.each do |key, ifg|
        raise NotInstanceOfIconfilegroupError.new("Dump postprocess_for_load 2") if ifg.instance_of?(Iconfilegroup)
      end
      @iconfilegroups ||= {}
      Loggerxcm.debug "Iconlist postprocess_for_load @iconfilegroups=#{nil}"
    end

    def dump(iconfilegroups)
      return unless @store

      @iconfilegroups = iconfilegroups
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

    def prepare_for_save
      @obj[:iconfilegroups] = @iconfilegroups
      Loggerxcm.debug "prepare_for_save @iconfilegroups.size=#{@iconfilegroups.size}"
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
  end
end