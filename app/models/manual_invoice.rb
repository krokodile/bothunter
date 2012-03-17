class ManualInvoice < ActiveRecord::Base #< Invoice
  #referenced_in :manager

  #field :agreement_number, type: String
end
