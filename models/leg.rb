class Leg < SuperModel::Base
  belongs_to :call
  enable_gdpr scrubber: ::Jobs::LegScrubberJob, async: true
end
