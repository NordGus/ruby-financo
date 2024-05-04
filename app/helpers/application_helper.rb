# frozen_string_literal: true

module ApplicationHelper
  def message_colors(type)
    case type
    when :error
      "text-red-700 bg-red-100"
    when :success
      "text-green-700 bg-green-100"
    else
      "text-neutral-700 bg-neutral-100"
    end
  end

  def modal_parent_element_classes(additional_classes = "")
    "grid grid-cols-1 grid-rows-[min-content_fit-content(90dvh)] #{additional_classes}"
  end
end
