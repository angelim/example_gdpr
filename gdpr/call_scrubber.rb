module Gdpr
  class CallScrubber < BaseScrubber

    def gdpr_records
      Call.find_all_by_user_id(user_id)
    end

    ##
    # @note More flexibility with regards to the fields being changed
    #
    def scrub_hash(record)
      {}.tap do |attrs|
        attrs.merge!(from: Gdpr::REPLACE_STRING)  if record.inbound?
        attrs.merge!(to: Gdpr::REPLACE_STRING)    if record.outbound?
      end
    end
  end
end