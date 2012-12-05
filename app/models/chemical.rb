class Chemical < ActiveRecord::Base
  attr_accessible :amount, :cas, :name
  has_many :uses
  has_many :recurring_uses 
  
  validates :name,   :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0 }
  validates_uniqueness_of :cas, :allow_blank => true, :allow_nil => true
  validate :cas_must_be_valid
  
  before_validation :pre_validation_process
  
  def pre_validation_process
    if self.cas != nil
      self.cas = self.cas.strip
      if self.cas.length == 0
        self.cas = nil
      end
    end
  end
  
  def cas_must_be_valid
    if self.cas != nil and not self.class.validate_cas(self.cas)
      errors.add(:cas, "is not valid")
    end
  end
  
  def cas_link
    "http://www.commonchemistry.org/ChemicalDetail.aspx?ref=" + cas
  end
  
  def self.validate_cas(cas_number)
    match = /^(\d{2,7})\-(\d{2})\-(\d)$/.match(cas_number)
    if not match
      return false
    end
    
    seq = match[1] + match[2]
    digits = seq.split('').map{ |ch| ch.to_i }
    
    n = digits.size
    sum = 0
    digits.each do |d|
      sum += d*n
      n -= 1
    end
    
    r = match[3].to_i
    return r == sum % 10
  end
  
  def to_s
    "Chemical: #{self.name}--#{self.cas} (#{self.amount})"
  end
  
  def calculate_actual_amount
    # To get actual inventory amount, consider recuring usages on top of the
    # number stored in database.
    # For each scheduled recurring use on this chemical,
    # calculate the amount that was supposed to have been consumed between
    # first effective date and present date.
    total_deduct = 0
    self.recurring_uses.each do |ru|
      total_deduct += ru.cumulated_consumption
    end
    actual_amount = self.amount - total_deduct
    return actual_amount
  end

  def forecast_run_out_date
    
  end
    
end
