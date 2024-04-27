# frozen_string_literal: true

module AccountsAndGoals
  class SummaryController < ApplicationController
    before_action :set_account_kinds, only: %i[capital debt]
    before_action :calculate_credits, only: %i[capital debt]
    before_action :calculate_debits, only: %i[capital debt]

    def capital
      @summary = calculate_summary

      render json: { summary: @summary }
    end

    def debt
      @summary = calculate_summary

      render json: { summary: @summary }
    end

    def total
      render json: { summary: nil }
    end

    private

    def set_account_kinds
      @account_kinds = Account::KINDS.slice(params[:action].to_sym, :system).values.map(&:values).flatten
    end

    def calculate_credits
      @credits = ActiveRecord::Base.connection
                                   .execute(credits_sql_query(@account_kinds))
                                   .to_a
                                   .map(&:deep_symbolize_keys)
                                   .group_by { |credit| credit[:currency] }
                                   .transform_values { |currency| currency.sum { |credit| credit[:amount] } }
    end

    def calculate_debits
      @debits = ActiveRecord::Base.connection
                                  .execute(debits_sql_query(@account_kinds))
                                  .to_a
                                  .map(&:deep_symbolize_keys)
                                  .group_by { |debit| debit[:currency] }
                                  .transform_values { |currency| currency.sum { |debit| debit[:amount] } }
    end

    def debits_sql_query(kinds)
      <<~SQL
        SELECT source.currency AS currency, SUM(-transactions.source_amount)::bigint AS amount
        FROM transactions
        INNER JOIN accounts source ON transactions.source_id = source.id
        WHERE source.kind IN (#{kinds.map { |kind| "'#{kind}'" }.join(',')})
        AND transactions.issued_at <= '#{Date.today}'
        GROUP BY source.currency;
      SQL
    end

    def credits_sql_query(kinds)
      <<~SQL
        SELECT source.currency AS currency, SUM(transactions.target_amount)::bigint AS amount
        FROM transactions
        INNER JOIN accounts source ON transactions.target_id = source.id
        WHERE source.kind IN (#{kinds.map { |kind| "'#{kind}'" }.join(',')})
        AND transactions.executed_at IS NOT NULL
        AND transactions.executed_at <= '#{Date.today}'
        GROUP BY source.currency;
      SQL
    end

    def calculate_summary
      @debits.merge(@credits) { |_key, debit, credit| debit + credit }
    end
  end
end
