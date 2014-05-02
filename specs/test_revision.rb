require 'spec_helper'

describe Revision do
  before do
    @repo = Revision.new
  end

  it "should be an instance of Revision" do
    @repo.must_be_instance_of Revision
  end
end
