# frozen_string_literal: true

# rubocop:disable Metrics/BlockLength
ActiveRecord::Base.transaction do
  personal_account = Account.create_with(currency: "EUR", capital: 0, color: "blue.500")
                            .find_or_create_by!(kind: Account::KINDS[:capital][:normal], name: "Personal")
  income_account = Account.create_with(currency: "EUR", capital: 0, color: "green.500")
                          .find_or_create_by(kind: Account::KINDS[:external][:income], name: "Income")
  expense_account = Account.create_with(currency: "EUR", capital: 0, color: "red.500")
                           .find_or_create_by!(kind: Account::KINDS[:external][:expense], name: "Expense")
  loan_account = Account.create_with(currency: "EUR", capital: 75_000, color: "yellow.500")
                        .find_or_create_by!(kind: Account::KINDS[:debt][:loan], name: "Loan")

  if personal_account.credits.count.zero?
    Transaction.create!(source: income_account,
                        target: personal_account,
                        source_amount: 250_000,
                        target_amount: 250_000,
                        issued_at: Date.today,
                        executed_at: Date.today)
  end

  if loan_account.debits.count.zero?
    Transaction.create!(source: loan_account,
                        target: personal_account,
                        source_amount: 75_000,
                        target_amount: 75_000,
                        issued_at: 1.month.ago.to_date,
                        executed_at: 1.month.ago.to_date)
  end

  if personal_account.debits.count.zero?
    Transaction.create!(source: personal_account,
                        target: expense_account,
                        source_amount: 50_000,
                        target_amount: 50_000,
                        issued_at: Date.today,
                        executed_at: Date.today)
    Transaction.create!(source: personal_account,
                        target: loan_account,
                        source_amount: 25_000,
                        target_amount: 25_000,
                        issued_at: Date.today,
                        executed_at: Date.today)
  end
end
# rubocop:enable Metrics/BlockLength
