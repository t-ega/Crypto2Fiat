class Transaction < ApplicationRecord
  # This represents how long a deposit can remain unconfirmed
  CONFIRMABLE_PERIOD = 20.minutes

  include AASM

  aasm column: "status" do
    state :initiated, initial: true
    state :deposit_initiated, :payout_initiated, :cancelled, :failed

    state :deposit_confirmed, before_enter: :mark_deposit_as_confirmed
    state :payout_completed, before_enter: :mark_payout_as_completed

    event :initiate_deposit do
      transitions from: :initiated, to: :deposit_initiated
    end

    event :confirm_deposit do
      transitions from: :deposit_initiated, to: :deposit_confirmed
    end

    event :initiate_payout do
      transitions from: :deposit_confirmed, to: :payout_initiated
    end

    event :confirm_payout do
      transitions from: :payout_initiated, to: :payout_completed
    end

    event :cancel do
      transitions from: :initiated, to: :cancelled
    end

    event :fail_transaction do
      transitions from: %i[deposit_initiated payout_initiated], to: :failed
    end
  end

  validates :payment_address, presence: true
  validates :account_details, presence: true
  validates :from_amount, presence: true, numericality: { greater_than: 0 }
  validates :to_currency, presence: true
  validates :receipient_email, presence: true
  validates :public_id, presence: true
  validates :network, presence: true

  def extract_currency_pair
    "#{self.from_currency.downcase}#{self.to_currency.downcase}"
  end

  def mark_deposit_as_confirmed
    self.deposit_confirmed_at = Time.current
  end

  def mark_payout_as_completed
    self.payout_confirmed_at = Time.current
  end

  def mark_transaction_as_failed(reason:)
    self.failure_reason = reason
    self.failed_at = Time.current
    self.fail_transaction!
  end

  # Nice to have: Send Mail to the receipient after the payout is successful
end
