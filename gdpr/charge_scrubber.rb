module Gdpr
  class ChargeScrubber < BaseScrubber

    def gdpr_records
      calls = Call.find_all_by_user_id(user_id)
      calls.map{|call| call.charges }.flatten
    end

    ##
    # @note More flexibility with regards to the fields being changed
    #
    def scrub_hash(record)
      { name: Gdpr::REPLACE_STRING, contents: parse_and_replace_contents(record) }
    end

    ##
    # `record.contents` is a json field and we have to do
    # partial replacement
    #
    def parse_and_replace_contents(record)
      JSON.parse(record.contents).tap do |content|
        content['from'] = Gdpr::REPLACE_STRING if record.call.inbound?
        content['to']   = Gdpr::REPLACE_STRING if record.call.outbound?
      end.to_json
    end
  end
end