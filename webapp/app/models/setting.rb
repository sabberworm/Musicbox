class Setting < ActiveRecord::Base
  def self.get_setting(name, default_value)
    setting = self.find(:first, :conditions => ["name = ?", name])
    return setting ? setting : default_value;
  end
end
