# frozen_string_literal: true

module AccountsAndGoals
  class BankAccountsController < AccountsAndGoalsController
    before_action :set_account, only: %i[show update destroy balance]

    def index
      @accounts = scope.order(created_at: :desc)
    end

    def show; end

    def new; end

    def create; end

    def update; end

    def destroy; end

    def balance
      @balance = @account.credits.sum(:target_amount) - @account.debits.sum(:source_amount)
      @in_preview = params.fetch(:preview, "false") == "true"
    end

    private

    def scope
      Account.includes(:debits, :credits).where(kind: Account::KINDS[:capital][:normal])
    end

    def set_account
      @account = scope.find(params[:id])
    end
  end
end
