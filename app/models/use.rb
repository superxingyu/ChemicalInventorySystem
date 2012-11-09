class Use < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist
  
  validates :chemist, :presence => true
  validates :amount,  :presence => true,
                      :numericality => { :greater_than_or_equal_to => 0 }
end
