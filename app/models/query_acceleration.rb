class QueryAcceleration < ActiveRecord::Base
  validates_presence_of :day
  validates_presence_of :query
  validates_presence_of :window_size
  validates_presence_of :score
  validates_uniqueness_of :query, :scope => [:day, :window_size]
  RESULTS_SIZE = 10

  def self.highest_scorers_over_window(window_size, num_results = RESULTS_SIZE)
    results = QueryAcceleration.find_all_by_day_and_window_size(Date.yesterday.to_date, window_size, :order => "score desc", :limit => num_results)
    results.empty? ? nil : results
  end

end
