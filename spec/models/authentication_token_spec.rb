require "rails_helper"

RSpec.describe AuthenticationToken, type: :model do
  include ActiveSupport::Testing::TimeHelpers

  describe "associations " do
    it { should belong_to(:user) }
  end

  describe "validations" do
    it { should validate_presence_of(:token) }
  end

  describe "behaviour" do
    it "should create a valid token" do
      user = create(:user)

      token =
        AuthenticationToken.create(
          user: user,
          token: "randomstring",
          expires_at: 1.day.from_now
        )

      expect(token.valid?).to eq(true)
      expect(token.user.id).to eq(user.id)
      expect(token.expires_at).to be_present
    end

    it "should expire a token" do
      user = create(:user)

      token =
        AuthenticationToken.create(
          user: user,
          token: "randomstring",
          expires_at: 1.day.from_now
        )

      freeze_time
      revoked = AuthenticationToken.revoke_token(token.token)
      expect(revoked).to eql(true)

      token.reload

      expect(token.expires_at).to eq(Time.current)
    end

    it "should not find a user if their has expired" do
      user = create(:user)

      token =
        AuthenticationToken.create(
          user: user,
          token: "randomstring",
          expires_at: 10.minutes.from_now
        )

      travel_to 1.hour.from_now do
        user = AuthenticationToken.find_user_from_token(token.token)
        expect(user).to eq(nil)
      end
    end
  end
end
