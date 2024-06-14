class Transaction < ApplicationRecord
  # This represents how long a deposit can remain unconfirmed
  CONFIRMABLE_PERIOD = 20.minutes

  include AASM

  aasm column: "status" do
    state :initiated, initial: true
    state :deposit_confirmed, :payout_initiated, :payout_completed, :failed

    event :confirm_deposit do
      transitions from: :initiated, to: :deposit_confirmed
    end

    event :initiate_payout do
      transitions from: :deposit_confirmed, to: :payout_initiated
    end

    event :confirm_payout do
      transitions from: :payout_initiated, to: :payout_completed
    end

    event :failed do
      transitions from: %i[initiated payout_initiated], to: :failed
    end
  end

  # Nice to have: Send Mail to the receipient after the payout is successful
end
