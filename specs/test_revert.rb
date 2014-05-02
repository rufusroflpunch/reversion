require 'spec_helper'

describe Revert do
  before do
    @repo = Revert.new
  end

  it "should be an instance of Revert" do
    @repo.must_be_instance_of Revert
  end
end
