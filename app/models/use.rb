class Use < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist
  
  validates_associated :chemical
  validates :chemist, :presence => true
  validates :amount,  :presence => true,
                      :numericality => { :greater_than => 0 }
  
  after_create :validate_chemical_amount
  after_save :deduct_chemical_amount_after_use
  
  def validate_chemical_amount
    if self.chemical.amount < self.amount
      self.errors.add(:amount, "use amount is larger than inventory")
      raise 'not enough amount chemical for new use'
    end
  end
  
  def deduct_chemical_amount_after_use
    remaining_amount = self.chemical.amount - self.amount
    self.chemical.update_attributes(:amount => remaining_amount)
  end
end
