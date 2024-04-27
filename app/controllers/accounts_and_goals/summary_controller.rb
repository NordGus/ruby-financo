# frozen_string_literal: true

module AccountsAndGoals
  class SummaryController < ApplicationController
    before_action :set_account_kinds, only: %i[capital debt]
    before_action :calculate_credits, only: %i[capital debt]
    before_action :calculate_debits, only: %i[capital debt]

    before_action :calculate_capital_balance, only: :total
    before_action :calculate_debt_balance, only: :total

    def capital
      @summary = calculate_summary(@debits, @credits)

      render json: { summary: @summary }
    end

    def debt
      @summary = calculate_summary(@debits, @credits)

      render json: { summary: @summary }
    end

    def total
      @summary = @capital_balance.merge(@debt_balance) { |_key, capital, debt| capital + debt }

      render json: { summary: @summary }
    end

    private

    def set_account_kinds
      @account_kinds = Account::KINDS[params[:action].to_sym].values
    end

    def calculate_credits
      @credits = retrieve_and_map_data(credits_sql_query(@account_kinds))
    end

    def calculate_debits
      @debits = retrieve_and_map_data(debits_sql_query(@account_kinds))
    end

    def calculate_capital_balance
      kinds = Account::KINDS[:capital].values

      @capital_balance = calculate_summary(
        retrieve_and_map_data(debits_sql_query(kinds)),
        retrieve_and_map_data(credits_sql_query(kinds))
      )
    end

    def calculate_debt_balance
      kinds = Account::KINDS[:debt].values

      @debt_balance = calculate_summary(
        retrieve_and_map_data(debits_sql_query(kinds)),
        retrieve_and_map_data(credits_sql_query(kinds))
      )
    end

    def retrieve_and_map_data(query)
      ActiveRecord::Base.connection.execute(query)
                        .to_a
                        .map(&:deep_symbolize_keys)
                        .group_by { |entry| entry[:currency] }
                        .transform_values { |currency| currency.sum { |entry| entry[:amount] } }
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

    def calculate_summary(debits, credits)
      debits.merge(credits) { |_key, debit, credit| debit + credit }
    end
  end
end
