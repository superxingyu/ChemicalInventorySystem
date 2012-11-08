class Use < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist
end
