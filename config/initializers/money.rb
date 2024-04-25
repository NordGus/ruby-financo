# frozen_string_literal: true

Money.locale_backend = :currency
Money.default_infinite_precision = true
Money.rounding_mode = BigDecimal::ROUND_UP
