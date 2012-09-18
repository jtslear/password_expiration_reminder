require 'time_converter'
require 'password_policy_calculator'

describe TimeConverter do
  it "converts to linux" do
    windows_time =  129859938771642395
    linux_time = 129859938770000000
    TimeConverter.new(windows_time).convert_to_linux.should == linux_time
  end

  it "can calculate days into seconds" do
    TimeConverter.days_to_seconds(90).should == 7776000
  end
end

describe PasswordPolicyCalculator do
  subject { PasswordPolicyCalculator.new(12985993) }
  it "can determine the valid password period" do
    #90 * 86400 + 12985993
    subject.valid_password_period.should ==  20761993
  end

  it "can determine the warn period" do
    #20761993 -  1209600
    subject.warn_period.should == 19552393
  end

  it "can determine the days till lockout" do
  end

end

