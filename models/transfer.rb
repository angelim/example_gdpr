class Transfer < SuperModel::Base
  
  ##
  # Uses a Lambda to implement the scrubbing.
  # Useful for extremely simple cases
  #
  enable_gdpr scrubber: ->(acc, user_id) do
    all.each do |transfer|
      transfer.update_attributes(amount: 10)
    end
  end
end
