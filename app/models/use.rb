class Use < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist
  
  validates_associated :chemical
  validates :chemist, :presence => true
  validates :amount,  :presence => true,
                      :numericality => { :greater_than => 0 }
  
  before_save :validate_chemical_amount_before_use
  after_save :deduct_chemical_amount_after_use
  
  def validate_chemical_amount_before_use
    if self.chemical.calculate_actual_amount < self.amount
      self.errors.add(:amount, "use amount is larger than current inventory")
      return false
    end
  end
  
  def deduct_chemical_amount_after_use
    remaining_amount = self.chemical.amount - self.amount
    self.chemical.update_attributes(:amount => remaining_amount)
  end
end
