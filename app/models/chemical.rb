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
  
  @@cas_pattern = /(\d{2,7})\-(\d{2})\-(\d)/
  
  def self.validate_cas(cas_number)
    match = @@cas_pattern.match(cas_number)
    if not match
      return false
    end
    
    # TODO: validate each group
    group1 = match[1]
    group2 = match[2]
    group3 = match[3]
    
    return true
  end
end
