class ManualInvoice < Invoice
  referenced_in :manager

  field :agreement_number, type: String
end
