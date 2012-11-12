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
    
    chemical3 = Chemical.new(:name => "Sodium Chloride", :cas => nil, :amount => 500)
    assert chemical3.save, "Chemical is not properly saved: " + chemical3.to_s
    
    chemical4 = Chemical.new(:name => "Aspirin", :cas => nil, :amount => 500)
    assert chemical4.save, "Chemical is not properly saved: " + chemical4.to_s
  end
  
  test "should save if CAS is unique" do
    chemical1 = Chemical.new(:name => "Formaldehyde", :cas => "50-00-0", :amount => 500)
    chemical1.save
    chemical2 = Chemical.new(:name => "carbohydrate", :cas => "50-00-0", :amount => 600)
    assert !chemical2.save, "Chemical should only be saved with unique CAS."
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
  
end
