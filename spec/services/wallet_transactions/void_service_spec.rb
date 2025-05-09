# frozen_string_literal: true

require "rails_helper"

RSpec.describe WalletTransactions::VoidService, type: :service do
  subject(:void_service) { described_class.call(wallet:, wallet_credit:) }

  let(:membership) { create(:membership) }
  let(:organization) { membership.organization }
  let(:customer) { create(:customer, organization:) }
  let(:subscription) { create(:subscription, customer:) }
  let(:wallet) do
    create(
      :wallet,
      customer:,
      balance_cents: 1000,
      credits_balance: 10.0,
      ongoing_balance_cents: 1000,
      credits_ongoing_balance: 10.0
    )
  end
  let(:credits_amount) { BigDecimal("10.00") }
  let(:wallet_credit) { WalletCredit.new(wallet:, credit_amount: credits_amount) }

  before do
    subscription
  end

  describe "#call" do
    context "when credits amount is zero" do
      let(:credits_amount) { BigDecimal("0.00") }

      it "does not create a wallet transaction" do
        expect { void_service }.not_to change(WalletTransaction, :count)
      end
    end

    context "when transaction have metadata" do
      subject(:void_service) { described_class.call(wallet:, wallet_credit:, metadata:) }

      let(:metadata) { [{"key" => "valid_value", "value" => "also_valid"}] }

      it "sets expected attributes" do
        expect(void_service.wallet_transaction).to have_attributes(
          amount: 10,
          credit_amount: 10,
          transaction_type: "outbound",
          status: "settled",
          source: "manual",
          transaction_status: "voided",
          metadata: metadata
        )
      end
    end

    it "creates a wallet transaction" do
      expect { void_service }.to change(WalletTransaction, :count).by(1)
    end

    it "sets expected attributes" do
      freeze_time do
        result = void_service
        expect(result.wallet_transaction).to have_attributes(
          amount: 10,
          credit_amount: 10,
          transaction_type: "outbound",
          status: "settled",
          source: "manual",
          transaction_status: "voided",
          settled_at: Time.current
        )
      end
    end

    it "updates wallet balance" do
      result = void_service
      wallet = result.wallet_transaction.wallet

      expect(wallet.balance_cents).to eq(0)
      expect(wallet.credits_balance).to eq(0.0)
    end

    context "when credit_note_id is passed" do
      subject(:void_service) { described_class.call(wallet:, wallet_credit:, credit_note_id:) }

      let(:credit_note_id) { create(:credit_note, organization: organization).id }

      it "saves credit_note_id in wallet_transaction" do
        result = void_service
        wallet_transaction = result.wallet_transaction

        expect(wallet_transaction.credit_note_id).to eq(credit_note_id)
      end
    end
  end
end
