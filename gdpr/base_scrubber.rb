module Gdpr
  class BaseScrubber
    attr_reader :user_id

    def scrub_hash(record)
      raise NotImplementedError
    end

    ##
    # @return [Array<Object>] list of records to scrub
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
    #
    def self.perform(*args)
      new(*args).scrub_records
    end

    ##
    # Updates the record using the calculated
    # set of changed attributes
    # @param record [#update_attributes] model to update
    #
    def scrub(record)
      hash = scrub_hash(record)
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