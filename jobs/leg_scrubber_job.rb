# Pretend like this is a resque job.

module Jobs
  class LegScrubberJob
    include ::Gdpr::BaseScrubber
    
    NAME_REPLACEMENT = 'Zendesk'
    
    # include Resque::Plugins::UniqueJob
    # self.queue = :low

    def self.enqueue(*args)
      new(*args).work
    end
    
    def work
      scrub_records
    end

    def gdpr_records
      calls = Call.find_all_by_user_id(user_id)
      calls.map{|call| call.legs }.flatten
    end

    def scrub_hash(record)
      { phone: Gdpr::REPLACE_STRING, name: NAME_REPLACEMENT }
    end
    
  end
end