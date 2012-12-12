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
  
  # To get actual inventory amount, consider recuring usages on top of the
  # number stored in database.
  # For each scheduled recurring use on this chemical,
  # calculate the amount that was supposed to have been consumed between
  # first effective date and the calculate date. 
  # @param calculate_date: date object
  def calculate_actual_amount(calculate_date = nil, allow_negative = false)   
    if calculate_date.nil?
      calculate_date = Time.now.to_date
    end
    
    total_deduct = 0
    self.recurring_uses.each do |ru|
      total_deduct += ru.cumulated_consumption(calculate_date)
    end
    actual_amount = self.amount - total_deduct
    return (allow_negative || actual_amount > 0) ? actual_amount : 0
  end
  
  def days_til_ran_out(calculate_date=nil)
    if calculate_date.nil?
      calculate_date = Time.now.to_date
    end
    
    remaining = self.calculate_actual_amount(calculate_date, true)
    if remaining < 0
      return -1 # ran out already
    elsif remaining == 0
      if self.recurring_usage_on(calculate_date) > 0
        return 0 # ran out on this day
      else
        return -1 # ran out before this day
      end
    end
    
    if !self.recurring_uses.any?
      return -2 # never gonna hit shortage
    end
    
    # get scheduled recurring uses
    i = 0
    to_check = {}
    self.recurring_uses.each do |ru|
      to_check[i] = ru
      i += 1
    end

    last_valid_consumption = nil # most recent date with a valid consumption 
    date = calculate_date # date for iteration
    to_remove = nil
    
    # do calculations day by day until we hit shortage or we have no more
    # active recurring use
    while remaining > 0 && to_check.any?
      date += 1
      
      # check schedules regarding the next day's deduction
      deduction = 0
      to_check.each do |i, ru|
        if date < ru.first_effective_date
          # not activated yet, skip
        elsif !ru.end_date.nil? && date > ru.end_date
          # inactive, need to remove this
          if to_remove.nil?
            to_remove = []
          end
          to_remove << i
        else
          # active recurring use, add deduction for this day
          deduction += ru.consumption_on(date)
        end
      end
      
      if deduction > 0
        remaining -= deduction
        if remaining >= 0
          last_valid_consumption = date
        end
      end
      
      # remove inactive recurring use
      if !to_remove.nil?
        to_remove.each do |i|
          to_check.delete(i)
        end
        to_remove = nil
      end
    end
    
    if remaining > 0
      return -2 # never gonna ran out
    elsif last_valid_consumption.nil?
      return -1 # no valid consumption after given calculate date
    else
      return (last_valid_consumption - calculate_date).to_i
    end
  end

  def ran_out_date_s(calculate_date)
    days = self.days_til_ran_out(calculate_date)
    if days >= 0
      return (calculate_date + days).to_s
    elsif days == -2
      return "not exists"
    elsif days == -1
      return "already in shortage"
    else
      return "n/a"
    end
  end
  
  def recurring_usage_on(date)
    consumption = 0
    self.recurring_uses.each do |ru|
      consumption += ru.consumption_on(date)
    end
    return consumption
  end
end
