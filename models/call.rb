class Call < SuperModel::Base
  # using the default configuration
  # Requires a Gdpr::CallScrubber class
  enable_gdpr
  
  has_many :legs
  has_many :charges

  def inbound?
    direction == 'inbound'
  end

  def outbound?
    !inbound?
  end
end
