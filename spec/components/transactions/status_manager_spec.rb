require "rails_helper"

RSpec.describe Transactions::StatusManager do
  describe "when given a transaction id" do
    it "should fetch the current state of the transaction" do
      transaction = create(:transaction)

      status, result =
        Transactions::StatusManager.new(transaction.public_id).call

      expect(status).to eq(:ok)
      expect(result.id).to eq(transaction.id)
      expect(result.status).to eq("initiated")
    end

    describe "given the status is deposit_initiated" do
      it "should confirm a deposit if the wallet has received that amount" do
        deposit_address = "address"
        transaction =
          create(
            :transaction,
            status: "deposit_initiated",
            payment_address: deposit_address,
            from_amount: 1
          )

        wallet_deposits_from_crypto_provider = [
          {
            payment_address: {
              address: deposit_address
            },
            # Only the deposits received **after** the transaction was created would be considered
            created_at: 1.minutes.from_now.to_s,
            amount: 1
          }.deep_stringify_keys
        ]

        quidax_wallet_mock =
          instance_double(
            Quidax::Deposits,
            fetch_deposits: [:ok, wallet_deposits_from_crypto_provider]
          )

        allow(Quidax::Deposits).to receive(:new).and_return(quidax_wallet_mock)
        expect(ExecutePayoutJob).to receive(:perform_later).once

        status, result =
          Transactions::StatusManager.new(transaction.public_id).call

        transaction_status_was = transaction.status
        transaction.reload
        transaction_status_is = transaction.status

        expect(status).to eq(:ok)
        expect(result.status).to eq("deposit_confirmed")
        expect(result.public_id).to eq(transaction.public_id)
        expect(transaction_status_was).not_to eq(transaction_status_is)
        expect(transaction_status_is).to eq("deposit_confirmed")
      end

      it "should not confirm a deposit if the wallet has received that amount after the confirmable period" do
        deposit_address = "address"
        #  A transaction deposit can remain unconfrimed for 20 minutes MAX in order to
        #  prevent a user from locking the address indefinetly
        transaction =
          create(
            :transaction,
            status: "deposit_initiated",
            payment_address: deposit_address,
            from_amount: 1
          )

        wallet_deposits_from_crypto_provider = [
          {
            payment_address: {
              address: deposit_address
            },
            # Only the deposits received **between** the transaction creation time and 20 mins after should be considered
            created_at: 30.minutes.from_now.to_s,
            amount: 1
          }.deep_stringify_keys
        ]

        quidax_wallet_mock =
          instance_double(
            Quidax::Deposits,
            fetch_deposits: [:ok, wallet_deposits_from_crypto_provider]
          )

        allow(Quidax::Deposits).to receive(:new).and_return(quidax_wallet_mock)
        expect(ExecutePayoutJob).not_to receive(:perform_later)

        expect {
          status, result =
            Transactions::StatusManager.new(transaction.public_id).call
          expect(status).to eq(:ok)
          expect(result.status).to eq("deposit_initiated")
          expect(result.public_id).to eq(transaction.public_id)
        }.not_to change { transaction.status }
      end

      it "should not confirm a deposit if the received amount is different" do
        deposit_address = "address"
        expected_amount = 1

        transaction =
          create(
            :transaction,
            status: "deposit_initiated",
            payment_address: deposit_address,
            from_amount: expected_amount
          )

        received_amount = 2
        wallet_deposits_from_crypto_provider = [
          {
            payment_address: {
              address: deposit_address
            },
            created_at: 1.minutes.from_now.to_s,
            amount: received_amount
          }.deep_stringify_keys
        ]

        quidax_wallet_mock =
          instance_double(
            Quidax::Deposits,
            fetch_deposits: [:ok, wallet_deposits_from_crypto_provider]
          )

        allow(Quidax::Deposits).to receive(:new).and_return(quidax_wallet_mock)
        expect(ExecutePayoutJob).not_to receive(:perform_later)

        expect {
          status, result =
            Transactions::StatusManager.new(transaction.public_id).call
          expect(status).to eq(:ok)
          expect(result.status).to eq("deposit_initiated")
          expect(result.public_id).to eq(transaction.public_id)
        }.not_to change { transaction.status }
      end
    end

    describe "given the transaction status is deposit_confirmed" do
      it "should enqueue the payout" do
        transaction =
          create(
            :transaction,
            status: "deposit_confirmed",
            payment_address: "address",
            from_amount: 1
          )
        transaction =
          create(
            :transaction,
            status: "deposit_confirmed",
            payment_address: "address",
            from_amount: 1
          )

        expect(ExecutePayoutJob).to receive(:perform_later).once

        status, result =
          Transactions::StatusManager.new(transaction.public_id).call
        expect(status).to eq(:ok)
        expect(result.public_id).to eq(transaction.public_id)
      end
    end

    describe "given the transaction status is payout initiated" do
      it "should confirm the status of a payout" do
        payout_reference = "Reference"

        transaction =
          create(
            :transaction,
            status: "payout_initiated",
            payout_reference: payout_reference,
            from_amount: 1
          )

        payout_response = {
          status: "success",
          reference: payout_reference
        }.stringify_keys

        kora_payout_mock =
          instance_double(
            Kora::Payouts::VerifyPayout,
            call: [:ok, payout_response]
          )

        allow(Kora::Payouts::VerifyPayout).to receive(:new).and_return(
          kora_payout_mock
        )

        expect {
          status, result =
            Transactions::StatusManager.new(transaction.public_id).call
          expect(status).to eq(:ok)
          expect(result.public_id).to eq(transaction.public_id)
          transaction.reload
        }.to change { transaction.status }.from("payout_initiated").to(
          "payout_completed"
        )
      end

      it "should mark payout as failed if the payout was unsuccessful" do
        payout_reference = "Reference"

        transaction =
          create(
            :transaction,
            status: "payout_initiated",
            payout_reference: payout_reference,
            from_amount: 1
          )

        payout_response = {
          status: "failed",
          reference: payout_reference
        }.stringify_keys

        kora_payout_mock =
          instance_double(
            Kora::Payouts::VerifyPayout,
            call: [:ok, payout_response]
          )

        allow(Kora::Payouts::VerifyPayout).to receive(:new).and_return(
          kora_payout_mock
        )

        expect {
          status, result =
            Transactions::StatusManager.new(transaction.public_id).call
          expect(status).to eq(:ok)
          expect(result.public_id).to eq(transaction.public_id)
          transaction.reload
        }.to change { transaction.status }.from("payout_initiated").to("failed")
      end
    end
  end
end
