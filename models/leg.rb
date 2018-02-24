class Leg < SuperModel::Base
  belongs_to :call
  enable_gdpr scrubber: Gdpr::CustomLegScrubber
end
