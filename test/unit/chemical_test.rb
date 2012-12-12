require 'test_helper'

class ChemicalTest < ActiveSupport::TestCase 
  
  test "should not save chemical without name" do
    chemical = Chemical.new(:name => nil, :cas => "50-00-0", :amount => 500)
    assert !chemical.save, "Saved the chemical without a name."
  end
  
  test "should not save chemical without amount" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => nil)
    assert !chemical.save, "Saved the chemical without an amount."
  end
  
  test "should not save if amount less than 0" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => -1)
    assert !chemical.save, "Saved the chemical with an amount less than 0."
  end
  
  test "should not save if CAS is not unique" do
    chemical1 = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    chemical1.save
    chemical2 = Chemical.new(:name => "carbohydrate", :cas => "50-00-0", :amount => 600)
    assert !chemical2.save, "Chemical should only be saved with a unique CAS."
  end
  
  test "good to save if CAS is blank" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => "", :amount => 500)
    assert chemical.save, "Chemical is good to save when CAS is blank."
  end
  
  test "good to save if CAS is nil" do
    chemical = Chemical.new(:name => "Formaldehyde", :cas => nil, :amount => 500)
    assert chemical.save, "Chemical is good to save when CAS is nil."   
  end
  
  test "should not save if CAS is not valid" do
    chemical1 = Chemical.new(:name => "Formaldehyde", :cas => "123-34-6", :amount => 500)
    assert !chemical1.save, "Saved the chemical with an invalid CAS number 123-34-6."
    
    chemical2 = Chemical.new(:name => "Formaldehyde", :cas => "1234352355", :amount => 500)
    assert !chemical2.save, "Saved the chemical with an invalid CAS number 1234352355."
    
    chemical3 = Chemical.new(:name => "Formaldehyde", :cas => "107-07-31", :amount => 500)
    assert !chemical3.save, "Saved the chemical with an invalid CAS number 107-07-31."
    
    chemical4 = Chemical.new(:name => "Formaldehyde", :cas => "107-07-AA", :amount => 500)
    assert !chemical4.save, "Saved the chemcial with an invalid CAS number 107-07-AA."
  end
  
  test "should save if CAS is valid" do
    chemical1 = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    assert chemical1.save, "Chemical is not properly saved: " + chemical1.to_s
  
    chemical2 = Chemical.new(:name => "Ethanol, 2-chloro-", :cas => "107-07-3", :amount => 500)
    assert chemical2.save, "Chemical is not properly saved: " + chemical2.to_s
    
    chemical3 = Chemical.new(:name => "Sodium Chloride", :cas => "7647-14-5", :amount => 500)
    assert chemical3.save, "Chemical is not properly saved: " + chemical3.to_s
    
    chemical4 = Chemical.new(:name => "L-Cysteine", :cas => "52-90-4", :amount => 500)
    assert chemical4.save, "Chemical is not properly saved: " + chemical4.to_s
  end
  
  test "cas validation" do
    assert !Chemical.validate_cas("123-34-6")
    assert !Chemical.validate_cas("1234352355")
    assert !Chemical.validate_cas("107-07-31")
    assert !Chemical.validate_cas("107-07-AA")
    assert !Chemical.validate_cas("107-06A-3")
    assert !Chemical.validate_cas("????")
    assert Chemical.validate_cas("107-07-3")
    assert Chemical.validate_cas("50-00-0")
  end

  test "calculate actual amount" do
    @chemical1 = chemicals(:one)
    @recurring_use1 = recurring_uses(:one)
    date = Date.new(2012,12,8)
    assert_equal(4975, @chemical1.calculate_actual_amount(date), "actual amount calculation is wrong.")
    
    @chemical2 = chemicals(:two)
    @recurring_use2 = recurring_uses(:two)
    date = Date.new(2012,12,8)
    assert_equal(95, @chemical2.calculate_actual_amount(date), "actual amount calculation is wrong.")
  end
  
  test "calculate ran out date" do

    chemical1 = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    chemical1.save
    assert_equal("not exists", chemical1.ran_out_date_s(Date.new(2012,12,8)), "calculated ran out date is wrong.") # no exist recurring uses, never ran out
    
    recurring_use1 = chemical1.recurring_uses.create(:chemist => "Xingyu", :amount => 50, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,8), :end_date => Date.new(2012,12,9))
    recurring_use1.save
    assert_equal("not exists", chemical1.ran_out_date_s(Date.new(2012,12,8)), "calculated ran out date is wrong.") # never ran out
    
    recurring_use2 = chemical1.recurring_uses.create(:chemist => "Xingyu", :amount => 50, 
      :periodicity => "weekly", :first_effective_date => Date.new(2012,12,8), :end_date => Date.new(2012,12,20))
    recurring_use1.save
    assert_equal("not exists", chemical1.ran_out_date_s(Date.new(2012,12,8)), "calculated ran out date is wrong.") # never ran out
    
    recurring_use3 = chemical1.recurring_uses.create(:chemist => "Rose", :amount => 1000,
      :periodicity => "daily", :first_effective_date => Date.new(2012,3,3), :end_date => Date.new(2012,5,4))
    assert_equal("already in shortage", chemical1.ran_out_date_s(Date.new(2012,12,8)), "calculated ran out date is wrong.") # ran out before calculate date

    @chemical2 = chemicals(:two)
    @recurring_use4 = recurring_uses(:two)
    assert_equal("not exists", @chemical2.ran_out_date_s(Date.new(2012,10,10)), "calculated ran out date is wrong.")
    
    recurring_use5 = @chemical2.recurring_uses.create(:chemist => "Xingyu", :amount => 10, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,3))
    assert_equal("2012-12-11", @chemical2.ran_out_date_s(Date.new(2012,12,4)), "calculate ran out date is wrong.")
        
    @chemical3 = chemicals(:three)
    recurring_use6 = @chemical3.recurring_uses.create(:chemist => "Xingyu", :amount => 100, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,10))
    assert_equal("2013-06-27", @chemical3.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.")

    chemical4 = Chemical.new(:name => "Ethanol, 2-chloro-", :cas => "107-07-3", :amount => 500)
    chemical4.save
    recurring_use7 = chemical4.recurring_uses.create(:chemist => "Xingyu", :amount => 100, 
      :periodicity => "weekly", :first_effective_date => Date.new(2012,12,10))
    assert_equal("2013-01-07", chemical4.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.")
    
    chemical5 = Chemical.new(:name => "Sodium Chloride", :cas => "7647-14-5", :amount => 5000)
    chemical5.save
    recurring_use8 = chemical5.recurring_uses.create(:chemist => "Xingyu", :amount => 33, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,10))
    assert_equal("2013-05-09", chemical5.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.")
    
    chemical6 = Chemical.new(:name => "L-Cysteine", :cas => "52-90-4", :amount => 5000)
    chemical6.save
    recurring_use9 = chemical6.recurring_uses.create(:chemist => "Xingyu", :amount => 56, 
      :periodicity => "weekly", :first_effective_date => Date.new(2012,12,10))
    assert_equal("2014-08-18", chemical6.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.")
    
    chemical7 = Chemical.new(:name => "test1", :amount => 5000)
    chemical7.save
    recurring_use10 = chemical7.recurring_uses.create(:chemist => "Xingyu", :amount => 20, 
      :periodicity => "weekly", :first_effective_date => Date.new(2012,12,10), :end_date => Date.new(2012,12,30))
    recurring_use11 = chemical7.recurring_uses.create(:chemist => "Xingyu", :amount => 20, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,10))
    assert_equal("2013-08-13", chemical7.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.") 
    
    chemical8 = Chemical.new(:name => "test2", :amount => 50000)
    chemical8.save 
    recurring_use12 = chemical8.recurring_uses.create(:chemist => "Xingyu", :amount => 88, 
      :periodicity => "weekly", :first_effective_date => Date.new(2012,12,10))
    recurring_use13 = chemical8.recurring_uses.create(:chemist => "Xingyu", :amount => 123, 
      :periodicity => "daily", :first_effective_date => Date.new(2012,12,20))
    assert_equal("2013-12-27", chemical8.ran_out_date_s(Date.new(2012,12,13)), "calculated ran out date is wrong.")
    
  end
  
end
