require 'test_helper'

class RecurringUseTest < ActiveSupport::TestCase
   
  test "should not save recurring use without chemist" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => nil, :amount => 50, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use without a chemist."
  end
  
  test "should not save recurring use without amount" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => nil, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use without an amount."
  end
  
  test "should not save recurring use if amount less than or equal to 0" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 0, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use with an amount of 0."
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => -1, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use with an amount less than 0."
  end
  
  test "should not save recurring use if amount is larger than inventory" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 5200, :periodicity => "daily")
    assert !recurring_use.save, "Saved the use with an amount larger than inventory."
  end
  
  test "should not save recurring use without periodicity" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 500, :periodicity => nil)
    assert !recurring_use.save, "Saved the recurring use without a periodicity."
  end
  
  test "should not save recurring use if periodicity is not daily or weekly" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 500, :periodicity => "monthly")
    assert !recurring_use.save, "Saved the recurring use without a periodicity other than daily/weekly."
  end
  
  test "should not save if end date is before first effective date" do
    @chemical = chemicals(:one)
    recurring_use = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 500, :periodicity => "weekly", 
    :first_effective_date => "2012-12-05", :end_date => "2012-12-04")
    assert !recurring_use.save, "Saved the recurring use with an end date before the first effective date."
  end
  
  test "should save if attributes are all valid" do
    @chemical = chemicals(:one)
    recurring_use1 = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 500, :periodicity => "daily")
    assert recurring_use1.save
    recurring_use2 = @chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 500, :periodicity => "weekly", 
    :first_effective_date => "2012-12-02", :end_date => "2012-12-04")
    assert recurring_use2.save
  end
  
  test "cumulated consumption" do
    @chemical1 = chemicals(:one)
    @recurring_use1 = recurring_uses(:one)
    date = Date.new(2012,12,8)
    assert_equal(@recurring_use1.cumulated_consumption(date), 25, "cumulated consumption calculation is wrong")
    date = Date.new(2012,12,6)
    assert_equal(@recurring_use1.cumulated_consumption(date), 20, "cumulated consumption calculation is wrong")
    
    @chemical2 = chemicals(:two)
    @recurring_use2 = recurring_uses(:two)
    date = Date.new(2012,12,8)
    assert_equal(@recurring_use2.cumulated_consumption(date), 5, "cumulated consumption calculation is wrong")
    date = Date.new(2012,12,25)
    assert_equal(@recurring_use2.cumulated_consumption(date), 10, "cumulated consumption calculation is wrong")
  end
  
end
