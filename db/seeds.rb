# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveRecord::Base.transaction do
  personal_account = Account.create_with(kind: Account::KINDS[:capital][:normal],
                                         currency: "EUR",
                                         capital: 0,
                                         color: "blue.500")
                            .find_or_create_by!(name: "Personal")
  income_account = Account.create_with(kind: Account::KINDS[:external][:income],
                                       currency: "EUR",
                                       capital: 0,
                                       color: "green.500")
                          .find_or_create_by(name: "Income")
  expense_account = Account.create_with(kind: Account::KINDS[:external][:expense],
                                        currency: "EUR",
                                        capital: 0,
                                        color: "red.500")
                           .find_or_create_by!(name: "Expense")

  if (personal_account.credits.count + personal_account.debits.count) != 2
    Transaction.create!(source: income_account,
                        target: personal_account,
                        source_amount: 250_000,
                        target_amount: 250_000,
                        issued_at: Date.today,
                        executed_at: Date.today)
    Transaction.create!(source: personal_account,
                        target: expense_account,
                        source_amount: 50_000,
                        target_amount: 50_000,
                        issued_at: Date.today,
                        executed_at: Date.today)
  end
end
# rubocop:enable Metrics/BlockLength
