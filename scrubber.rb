# module Gdpr
#   class TransformationBuilder
#     attr_reader :field, :value, :conditional_key
    
#     def initialize(field, value, options = {})
#       conditional_key = if options.key?(:if)
#         :if
#       elsif options.key?(:unless)
#         :unless
#       end
#       conditional = conditional_key && options[conditional_key]
      
      
#       case conditional
#       trans = when Boolean
#         { field: value } if conditional_key && conditional
#       when Proc then conditional.call

#       else
#         conditional
#       end
      
#       if conditional_key == :if && conditional
#       end
#       if conditional_key == :unless && !conditional
#       end
#     end
#   end
# end

# TransformationBuilder.new(:from,  '####', if: ->(call) { call.inbound? } )
# TransformationBuilder.new(:to,    '####', unless: ->(call) { call.inbound? } )
# TransformationBuilder.new(:from,    '####', if: inbound? )
# TransformationBuilder.new(:to,    '####',   if: outbound? )