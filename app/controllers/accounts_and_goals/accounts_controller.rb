# frozen_string_literal: true

module AccountsAndGoals
  class AccountsController < AccountsAndGoalsController
    before_action :set_kinds, only: :index
    before_action :filter_kind, only: :new
    before_action :set_account, only: %i[show update destroy]

    def index
      @accounts = Account.includes(:credits, :debits).parents.where(kind: @kinds).order(created_at: :desc)
    end

    def show
      @form = Accounts::FormFor.account(@account)
    end

    def new
      @form = Accounts::FormFor.create(new_account_params.to_h)
    end

    # TODO: design where to implement the store procedure
    def create
      @form = Accounts::FormFor.create(account_params.to_h)
    end

    # TODO: design where to implement the store procedure
    def update
      @form = Accounts::FormFor.update(@account, account_params.to_h)
    end

    # TODO: design and implement soft deletion mechanism
    def destroy; end

    private

    def set_kinds
      @kinds = (Account.visible_kinds_array & params[:kinds].to_a).present? && params[:kinds].to_a

      head :bad_request unless @kinds.present?
    end

    def filter_kind
      head :bad_request unless Account.visible_kinds_array.include?(params.fetch(:kind, "").to_s)
    end

    def set_account
      @account = Account.includes(:children, :debits, :credits).visible.find(params[:id])
    end

    def account_params
      params.require(:account).permit(:parent_id, :kind, :currency, :name, :description, :color, :capital, :archived_at)
    end

    def new_account_params
      params.permit(:kind)
    end
  end
end
