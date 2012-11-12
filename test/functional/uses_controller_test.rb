require 'test_helper'

class UsesControllerTest < ActionController::TestCase
  
  setup do
    @chemical = chemicals(:one)
  end
  
  test "should create use" do
    assert_difference('Use.count') do
      post :create, :use => { :chemist => "xingyu", :amount => 1000 }, :chemical_id => @chemical
    end
    assert_redirected_to chemical_path(assigns(:chemical))
  end
    
end
