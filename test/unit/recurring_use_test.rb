require 'test_helper'

class RecurringUseTest < ActiveSupport::TestCase
  
  test "should not save recurring use without chemist" do
    recurring_use = RecurringUse.new(:chemist => nil, :amount => 50, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use without a chemist."
  end
  
  test "should not save recurring use without amount" do
    recurring_use = RecurringUse.new(:chemist => "Xingyu", :amount => nil, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use without an amount."
  end
  
  test "should not save recurring use if amount less than or equal to 0" do
    recurring_use = RecurringUse.new(:chemist => "Xingyu", :amount => 0, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use with an amount of 0."
    recurring_use = RecurringUse.new(:chemist => "Xingyu", :amount => -1, :periodicity => "daily")
    assert !recurring_use.save, "Saved the recurring use with an amount less than 0."
  end
  
  test "should not save if amount is larger than inventory" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    chemical.save
    recurring_use = chemical.recurring_uses.create(:chemist => "Xingyu", :amount => 600, :periodicity => "daily")
    assert !recurring_use.save, "Saved the use with an amount larger than inventory."
  end
  
  test "should not save recurring use without periodicity" do
    recurring_use = RecurringUse.new(:chemist => "Xingyu", :amount => 500, :periodicity => nil)
    assert !recurring_use.save, "Saved the recurring use without a periodicity."
  end
  
end
