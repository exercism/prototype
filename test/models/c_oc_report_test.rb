require 'test_helper'

class CoCReportTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end
  test "can create a CoC Report" do
    report = create(:co_c_report)
    assert Solution.where(uuid: report.solution_uuid).exists?
  end
end
