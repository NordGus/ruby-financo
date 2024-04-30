# frozen_string_literal: true

class AccountsAndGoalsController < ApplicationController
  layout :request_layout

  private

  def request_layout
    return "turbo_rails/frame" if turbo_frame_request?

    "accounts_and_goals"
  end
end
