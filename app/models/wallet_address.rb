class WalletAddress < ApplicationRecord
  # This represents the max time a wallet address can remain locked
  # while waiting for a transaction to be confirmed
  MAX_LOCK_TIME = 20.minutes.freeze
  ALLOWED_CURRENCIES_LIST = %w[eth btc usdt].freeze

  scope :currency, ->(currency) { where(currency: currency) }
  scope :not_in_use,
        -> do
          where("in_use = ? OR last_used_at < ? ", false, MAX_LOCK_TIME.ago)
        end

  # Cope with race conditions
  def lock_for_deposit!
    # Prevent situations when the wallet was not unlocked after deposit was confrimed or failed
    if in_use
      if last_used_at.present? && last_used_at > MAX_LOCK_TIME.ago
        raise Errors::Payouts::WalletAddressInUseError
      end
    end

    self.update!(in_use: true, last_used_at: Time.current)
  end

  def unlock_for_deposit!
    self.update!(in_use: false)
  end
end
