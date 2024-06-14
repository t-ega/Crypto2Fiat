class WalletAddress < ApplicationRecord
  # This represents the max time a wallet address can remain locked
  # while waiting for a transaction to be confirmed
  MAX_LOCK_TIME = 20.minutes

  scope :currency, ->(currency) { where(currency: currency) }
  scope :not_in_use,
        -> do
          where("in_use = ? OR last_used_at > ? ", false, MAX_LOCK_TIME.ago)
        end
end
