# frozen_string_literal: true

module AccountsAndGoals
  module Accounts
    module Debt
      class LoanForm < AccountForm
        after_initialize :set_personal_loan

        def save
          raise ActiveRecord::RecordInvalid
        end

        private

        def set_personal_loan
          self.personal_loan = kind == Account::KINDS[:debt][:personal] unless personal_loan
        end
      end
    end
  end
end
