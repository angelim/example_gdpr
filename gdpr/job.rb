##
# Background job to scrub records for a given user
# Hardcodes the target models!
# All of them must implement `.scrub`, which is always true when using `.enable_gdpr`
# This approach also allows flexibility on which arguments we should use when calling
# the scrubbers
#
class GdprJob < Struct.new(:account_id, :user_id)
  GDPR_MODELS = [ Call, Leg, User, Charge, Transfer].freeze
  
  def perform
    GDPR_MODELS.each{ |model| model.scrub(account_id, user_id) }
    # Gdpr::CrazyModel.scrub(user_id, something_else)
  end  
end