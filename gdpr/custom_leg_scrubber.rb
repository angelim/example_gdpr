module Gdpr
  class CustomLegScrubber < BaseScrubber
    NAME_REPLACEMENT = 'Zendesk'

    def gdpr_records
      calls = Call.find_all_by_user_id(user_id)
      calls.map{|call| call.legs }.flatten
    end

    ##
    # @note Simpler syntax
    #
    def scrub_hash(record)
      { phone: Gdpr::REPLACE_STRING, name: NAME_REPLACEMENT }
    end

  end
end