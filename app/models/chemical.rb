class Chemical < ActiveRecord::Base
  attr_accessible :amount, :cas, :name
  has_many :uses 
  
  validates :name,   :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0 }
  validates :cas,    :uniqueness => true,
                     :length => { :maximum => 10 }
  
  validate :cas_must_be_valid
  
  def cas_must_be_valid
    if not self.class.validate_cas(cas)
      errors.add(:cas, "is not valid")
    end
  end
  
  def cas_link
    "http://www.commonchemistry.org/ChemicalDetail.aspx?ref=" + cas
  end
  
  def self.validate_cas(cas_number)
    match = /(\d{2,7})\-(\d{2})\-(\d)/.match(cas_number)
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
  
end
