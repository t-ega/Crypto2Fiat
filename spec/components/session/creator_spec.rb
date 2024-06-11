require "rails_helper"

RSpec.describe "Session::Creator " do
  describe "create" do
    it "should create a session for a user" do
      user = create(:user, email: "email@test.com", password: "password")

      status, result =
        Session::Creator.new(email: "email@test.com", password: "password").call

      expect(status).to eq(:ok)
      expect(result.user_id).to eq(user.id)
      expect(result.token).to be_present
    end

    it "should not create a session for a user if the email or password is incorrect" do
      create(:user, email: "email@test.com", password: "password")

      status, result =
        Session::Creator.new(
          email: "email@test.com",
          password: "wrongpassword"
        ).call

      expect(status).to eq(:error)
      expect(result).to eq("Invalid email or password")
    end
  end
end
