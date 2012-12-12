class RecurringUse < ActiveRecord::Base
  belongs_to :chemical
  attr_accessible :amount, :chemist, :end_date, :first_effective_date, :periodicity
  
  validates_associated :chemical 
  validates :chemist,     :presence => true
  validates :amount,      :presence => true,
                          :numericality => { :greater_than => 0 }
  #validates :end_date, :allow_blank => true, :allow_nil => true
                          #:format => {:with => /^[0-9]{4}[-][0-9]{2}[-][0-9]{2}$/}
  validates_inclusion_of :periodicity, :in => ["daily", "weekly"]
  
  before_validation :pre_validation_process
  before_save :validate_chemical_amount
  before_save :validate_first_effective_date_and_end_date

  def pre_validation_process
    if self.first_effective_date.nil?
      self.first_effective_date = self.created_at.nil? ? Time.now.to_date : self.created_at.to_date
    end
  end
  
  def validate_chemical_amount
    if self.chemical.calculate_actual_amount(Time.now.to_date) < self.amount
      self.errors.add(:amount, "Current inventory is not enough")
      return false
    end  
  end
  
  # not exposed to user yet, skip validation for now
  #if self.first_effective_date < Time.now.to_date
  #  self.errors.add(:first_effective_date, "First effective date should not before current date ")
  #  return false
  #end
  def validate_first_effective_date_and_end_date    
    if !self.end_date.nil? and self.end_date < self.first_effective_date
      self.errors.add(:end_date, "End date should not before first effective date")
      return false
    end
  end
  
  # Calculate the amount that was supposed to have been consumed between
  # first effective date and the calculate date/end date.
  # 
  # @param calculate_date: date object
  def cumulated_consumption(calculate_date)
    times = 0
    if self.end_date.nil? || calculate_date <= self.end_date
      if self.periodicity == "daily"
        times = (calculate_date - self.first_effective_date).to_i + 1
      elsif self.periodicity == "weekly"
        times = (calculate_date - self.first_effective_date).to_i / 7 + 1
      end
    else
      if self.periodicity == "daily"
        times = (self.end_date - self.first_effective_date).to_i + 1
      elsif self.periodicity == "weekly"
        times = (self.end_date - self.first_effective_date).to_i / 7 + 1
      end
    end
    return times * self.amount
  end

=begin  
  # Calculate the amount that supposed to be consumed within a week 
  def weekly_consumption
    if self.periodicity == "daily"
      return 7 * self.amount
    elsif self.periodicity == "weekly"
      return self.amount
    end
  end
  
  # Calculate days till next consumption from the calculate date
  # @param calculate_date: date object 
  def days_till_next_consumption(calculate_date = nil)
    if calculate_date.nil?
      calculate_date = Time.now.to_date
    end
    
    if self.end_date.nil? || calculate_date <= self.end_date
      if self.periodicity == "daily"
        return 1
      elsif self.periodicity == "weekly"
        passed_days = (calculate_date - self.first_effective_date) % 7
        return (7 - passed_days)
      end
    else
      return -1
    end   
  end
=end
       
end
