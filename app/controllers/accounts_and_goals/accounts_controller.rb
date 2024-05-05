# frozen_string_literal: true

module AccountsAndGoals
  class AccountsController < AccountsAndGoalsController
    before_action :set_kinds, only: :index
    before_action :filter_kind, only: :new
    before_action :set_account, only: %i[show update destroy]

    def index
      @accounts = Account.includes(:credits, :debits).for_listing.parents.where(kind: @kinds)
    end

    def show
      @form = Accounts::FormFor.account(@account)
    end

    def new
      @form = Accounts::FormFor.create(new_account_params.to_h)
    end

    def create
      @form = Accounts::FormFor.create(account_params.to_h.merge("color" => "red.500")) # TODO: implement color picker

      if @form.save
        flash[:form_persistence_warnings] = @form.errors.messages_for(:form_persistence_warnings)

        redirect_to accounts_and_goals_account_path(@form), notice: "account saved"
      else
        render :form
      end
    end

    def update
      @form = Accounts::FormFor.update(@account, attributes: account_params.to_h)

      if @form.save
        flash[:form_persistence_warnings] = @form.errors.messages_for(:form_persistence_warnings)

        redirect_to accounts_and_goals_account_path(@form), notice: "account saved"
      else
        render :form
      end
    end

    def destroy
      @account.destroy

      redirect_to accounts_and_goals_path
    end

    private

    def set_kinds
      @kinds = (Account.visible_kinds_array & params[:kinds].to_a).present? && params[:kinds].to_a

      head :bad_request unless @kinds.present?
    end

    def filter_kind
      head :bad_request unless Account.visible_kinds_array.include?(params.fetch(:kind, "").to_s)
    end

    def set_account
      @account = Account.includes(:children, :debits, :credits, history: [:debits]).visible.find(params[:id])
    end

    def account_params
      params.require(:account).permit(
        :parent_id, :kind, :currency, :name, :description, :color, :capital, :amount, :at, :archived,
        :clear_history, :personal_loan
      )
    end

    def new_account_params
      params.permit(:kind)
    end
  end
end
