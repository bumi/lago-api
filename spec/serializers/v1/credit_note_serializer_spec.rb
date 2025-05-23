# frozen_string_literal: true

require "rails_helper"

RSpec.describe V1::CreditNoteSerializer, type: :serializer do
  subject(:serializer) do
    described_class.new(credit_note, root_name: "credit_note", includes: %i[customer items error_details])
  end

  let(:credit_note) { create(:credit_note) }
  let(:error_detail) { create(:error_detail, owner: credit_note) }
  let(:customer) { credit_note.customer }
  let(:item) { create(:credit_note_item, credit_note:) }

  before do
    error_detail
    item
  end

  it "serializes the object" do
    result = JSON.parse(serializer.to_json)

    expect(result["credit_note"]).to include(
      "lago_id" => credit_note.id,
      "billing_entity_code" => credit_note.invoice.billing_entity.code,
      "sequential_id" => credit_note.sequential_id,
      "number" => credit_note.number,
      "lago_invoice_id" => credit_note.invoice_id,
      "invoice_number" => credit_note.invoice.number,
      "issuing_date" => credit_note.issuing_date.iso8601,
      "credit_status" => credit_note.credit_status,
      "refund_status" => credit_note.refund_status,
      "reason" => credit_note.reason,
      "description" => credit_note.description,
      "currency" => credit_note.currency,
      "total_amount_cents" => credit_note.total_amount_cents,
      "taxes_amount_cents" => credit_note.taxes_amount_cents,
      "sub_total_excluding_taxes_amount_cents" => credit_note.sub_total_excluding_taxes_amount_cents,
      "balance_amount_cents" => credit_note.balance_amount_cents,
      "credit_amount_cents" => credit_note.credit_amount_cents,
      "refund_amount_cents" => credit_note.refund_amount_cents,
      "coupons_adjustment_amount_cents" => credit_note.coupons_adjustment_amount_cents,
      "created_at" => credit_note.created_at.iso8601,
      "updated_at" => credit_note.updated_at.iso8601,
      "file_url" => credit_note.file_url,
      "error_details" => [{
        "lago_id" => error_detail.id,
        "error_code" => error_detail.error_code,
        "details" => error_detail.details
      }],
      "self_billed" => credit_note.invoice.self_billed
    )

    expect(result["credit_note"].keys).to include("customer", "items")
  end
end
