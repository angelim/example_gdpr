class User < SuperModel::Base
  ##
  # Uses a local method to implement the scrubbing.
  # Useful for simple cases
  #
  enable_gdpr scrubber: :something_local

  def self.something_local(acc, user_id)
    find_by_attribute(:id, user_id)&.update_attributes(name: 'Zendesk')
  end
end