class RecurringUse < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist, :end_date, :first_effective_date, :periodicity
  
  validates_associated :chemical
  validates :chemist,     :presence => true
  validates :amount,      :presence => true,
                          :numericality => { :greater_than => 0 }
  validates :periodicity, :presence => true
  
  before_save :validate_chemical_amount

  def validate_chemical_amount
    if self.chemical.amount < self.amount
      self.errors.add(:amount, "Current inventory is not enough")
      return false
    end  
  end
    
  def cumulated_consumption
    # Calculate the amount that was supposed to have been consumed between
    # first effective date and present date.
    times = 0
    if self.periodicity == "daily"
      times = (Time.now.to_date - self.created_at.to_date).to_i + 1
    elsif self.periodicity == "weekly"
      times = (Time.now.to_date - self.created_at.to_date).to_i / 7 + 1
    end
    return times * self.amount
  end
  
  def weekly_consumption
    # Calculate the amount that supposed to be consumed within a week
    if self.periodicity == "daily"
      return 7 * self.amount
    elsif self.periodicity == "weekly"
      return self.amount
    end
  end
   
  def days_till_next_consumption
    if self.periodicity == "daily"
      return 1
    elsif self.periodicity == "weekly"
      passed_days = (Time.now.to_date - self.created_at.to_date) % 7
      return (7 - passed_days)
    end   
  end
       
end
