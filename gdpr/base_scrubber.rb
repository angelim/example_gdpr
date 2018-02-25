module Gdpr
  class BaseScrubber
    attr_reader :user_id

    ##
    # Generates the hash that will be used to update the record
    # @param record [Model] the record, so we can use conditionals
    #                       or any other required calculations.
    #
    # @return [Hash] update hash
    # 
    def scrub_hash(record)
      raise NotImplementedError
    end

    ##
    # @return [Array<Model>] list of records to scrub
    #
    def gdpr_records
      raise NotImplementedError
    end

    ##
    # Override this on children scrubbers when you need to use other arguments
    #
    def initialize(account_id, user_id)
      # Account.find(account_id)
      @user_id = user_id
    end

    ##
    # This is just an entry point forwarding all calls to the scrubbing method.
    # Allows calling `ChildScrubber.perform(arg1, arg2)`
    #        Same as `ChildScrubber.new(arg1, arg2).scrub_records`
    #
    def self.perform(*args)
      new(*args).scrub_records
    end

    ##
    # Updates the record using the calculated
    # set of changed attributes
    # @param record [Model] model to update
    #
    def scrub(record)
      hash = scrub_hash(record)
      hash.merge!(updated_at: Time.now) if record.has_attribute?(:updated_at)
      
      record.update_attributes(hash) if hash.present?
    end

    ##
    # Scrubs gdpr records
    #
    def scrub_records
      gdpr_records.each{ |record| scrub(record) }
    end

  end
end