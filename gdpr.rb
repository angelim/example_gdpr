require 'supermodel'
require 'byebug'

module Gdpr
  REPLACE_STRING = '####'.freeze

  module Extension
    ##
    # This is the only method made available to the models.
    # It helps setup the gdpr configuration with some nifty options.
    #
    # When used, it defines the class method `.scrub`, which is the entrypoint for all scrubbing
    # for that particular model.
    #
    # Instead of encouraging to implement GDPR methods inside the model(they are already cluttered enough),
    # it points to an external scrubber class by default.
    #
    # Configuration:
    # * Allows passing a Scrubber class. Defaults to a BaseScrubber child
    #   using a name convention: `Gdpr::{ModelName}Scrubber.`
    # * Allows passing a Symbol pointing to a local method inside the model
    # * Allows passing a Proc for inline scrubbing
    # 
    # @param scrubber [BaseScrubber, Symbol, Proc] scrubbing strategy
    # 
    def enable_gdpr(scrubber: nil)
      if scrubber.is_a?(Symbol)
        define_singleton_method :scrub do |*args|
          send(scrubber, *args)
        end
      elsif scrubber.is_a?(Proc)
        define_singleton_method :scrub do |*args|
          scrubber.call(*args)
        end
      else
        scrubber ||= "Gdpr::#{self.name}Scrubber"
        scrubber_klass ||= scrubber.to_s.constantize rescue nil
        raise ArgumentError.new("#{scrubber} is not defined") unless scrubber_klass
        
        define_singleton_method :scrub do |*args|
          scrubber_klass.perform(*args)
        end
      end
    end
  end
end
# This would be our ActiveRecord
SuperModel::Base.send(:extend, Gdpr::Extension)

require_relative 'gdpr/base_scrubber'
require_relative 'gdpr/call_scrubber'
require_relative 'gdpr/charge_scrubber'
require_relative 'gdpr/custom_leg_scrubber'
require_relative 'gdpr/job'
require_relative 'models/leg'
require_relative 'models/call'
require_relative 'models/user'
require_relative 'models/transfer'
require_relative 'models/charge'
require_relative 'scrubber'

