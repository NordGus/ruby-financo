# frozen_string_literal: true

module AccountsAndGoals
  class AccountsController < AccountsAndGoalsController
    before_action :set_kinds, only: :index
    before_action :set_kind, only: :new
    before_action :set_account, only: %i[show update destroy balance]

    def index
      @accounts = Account.parents.where(kind: @kinds).order(created_at: :desc)
    end

    # TODO: implement form model
    def show; end

    # TODO: implement form model
    def new; end

    # TODO: implement form model
    def create; end

    # TODO: implement form model
    def update; end

    # TODO: design and implement soft deletion mechanism
    def destroy; end

    def balance
      @balance = @account.credits.sum(:target_amount) - @account.debits.sum(:source_amount)
      @in_preview = params.fetch(:preview, "false") == "true"
    end

    private

    def set_kinds
      @kinds = (Account.visible_kinds_array & params[:kind].to_a).present? && params[:kind].to_a

      head :bad_request unless @kinds.present?
    end

    def set_kind
      @kind = Account.visible_kinds_array.include?(params.fetch(:kind, "").to_s) ? params[:kind].to_s : nil

      head :bad_request unless @kinds.present?
    end

    def set_account
      @account = Account.includes(:children, :debits, :credits).visible.find(params[:id])
    end
  end
end
