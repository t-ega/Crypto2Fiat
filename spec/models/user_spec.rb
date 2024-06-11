require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:authentication_tokens) }
  end

  describe "validators" do
    it { should validate_presence_of(:email) }
  end
end
