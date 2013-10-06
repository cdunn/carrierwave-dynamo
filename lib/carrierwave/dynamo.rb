# encoding: utf-8
#require "toy-dynamo"
require "carrierwave/dynamo/version"
require 'carrierwave'
require 'carrierwave/validations/active_model'

module CarrierWave
  module Dynamo
    include CarrierWave::Mount

    def mount_uploader(column, uploader, options={}, &block)
      options[:mount_on] ||= "#{column}_filename"
      attribute options[:mount_on].to_sym, String

      super

      alias_method :read_uploader, :read_attribute
      alias_method :write_uploader, :write_attribute
      public :read_uploader
      public :write_uploader

      include CarrierWave::Validations::ActiveModel

      validates_integrity_of  column if uploader_option(column.to_sym, :validate_integrity)
      validates_processing_of column if uploader_option(column.to_sym, :validate_processing)
      
      after_save "store_#{column}!".to_sym
      before_save "write_#{column}_identifier".to_sym
      after_destroy "remove_#{column}!".to_sym
    end
  end
end

module Toy
  module Dynamo
    module Store
      extend ::CarrierWave::Dynamo
    end
  end
end
