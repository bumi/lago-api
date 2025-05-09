# frozen_string_literal: true

class AddIndexesToSubscriptions < ActiveRecord::Migration[7.0]
  disable_ddl_transaction!

  def change
    safety_assured do
      add_index :subscriptions, [:started_at, :ending_at]
    end
    add_index :invoice_subscriptions,
      [:subscription_id, :from_datetime, :to_datetime],
      name: "index_invoice_subscriptions_boundaries",
      algorithm: :concurrently
  end
end
