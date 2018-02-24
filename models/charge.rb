class Charge < SuperModel::Base
  
  belongs_to :call

  enable_gdpr
end
