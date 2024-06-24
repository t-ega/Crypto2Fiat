require "rails_helper"

RSpec.describe User, type: :model do
  describe "associations" do
    it { should have_many(:authentication_tokens) }
  end

  describe "validators" do
    it { should validate_presence_of(:email).with_message(/invalid/) }
    it { should allow_value("email@email.com").for(:email) }
    it { should_not allow_value("email.com").for(:email) }
  end
end
