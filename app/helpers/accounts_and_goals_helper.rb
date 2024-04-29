# frozen_string_literal: true

module AccountsAndGoalsHelper
  def amount_text_color(amount = 0)
    return "text-green-500" if amount.positive?
    return "text-red-500" if amount.negative?

    ""
  end
end
