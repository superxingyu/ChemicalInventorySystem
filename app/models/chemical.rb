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
  
  # @param calculate_date: date object 
  def calculate_actual_amount(calculate_date = nil, allow_negative = false)
    # To get actual inventory amount, consider recuring usages on top of the
    # number stored in database.
    # For each scheduled recurring use on this chemical,
    # calculate the amount that was supposed to have been consumed between
    # first effective date and the calculate date.
    
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
  
  def ran_out_date_s
    days = self.days_till_ran_out
    if days >= 0
      return (Time.now.to_date + days).to_s
    else
      return "n/a"
    end
  end
  
  def days_till_ran_out
    dts = self.days_till_shortage
    case dts
    when 0 # hit shortage today
      return -2 # already ran out
    when -2 # hit shortage before today
      return -2 # already ran out
    when -1 # never will hit shortage
      return -1 # never gonna hit ran out
    else
      return dts - 1
    end
  end

  def days_till_shortage
    # calculate weekly consumption
    total_weekly_consumption = 0
    self.recurring_uses.each do |ru|
      total_weekly_consumption += ru.weekly_consumption
    end
    
    if total_weekly_consumption == 0
      return -1 # never gonna hit shortage
    end
    
    # this remaining amount includes today's consumptions
    current_amount = self.calculate_actual_amount(Time.now.to_date, true)
    if current_amount < 0
      return -2 # hit shortage already (before today)
    end
    
    # number of weeks that we're good to cover
    weeks = current_amount / total_weekly_consumption

    # find the ran out day
    remaining = current_amount
    days = 1
    self.daily_consumptions_for_following_week.each do |daily_consumption|
      remaining -= daily_consumption
      if remaining < 0:
        break
      end
      days += 1
    end
    
    return 7 * weeks + days
  end
  
  def daily_consumptions_for_following_week
    # for the following week (starting tomorrow)
    # calculate daily consumption schedule
    schedule = Array.new(7, 0)
    self.recurring_uses.each do |ru|
      if ru.periodicity == "daily"
        schedule.map! {|daily_consumption| daily_consumption += ru.amount}
      end
      if ru.periodicity == "weekly"
        schedule[ru.days_till_next_consumption - 1] += ru.amount
      end  
    end
    logger.debug schedule
    return schedule
  end
    
end
