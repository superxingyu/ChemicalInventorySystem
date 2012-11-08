class Chemical < ActiveRecord::Base
  attr_accessible :amount, :cas, :name
  has_many :uses 
  
  validates :name,   :presence => true
  validates :amount, :presence => true,
                     :numericality => { :greater_than_or_equal_to => 0 }
  validates :cas,    :uniqueness => true,
                     :length => { :maximum => 10 }
end
