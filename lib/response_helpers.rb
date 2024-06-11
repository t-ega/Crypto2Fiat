module ResponseHelpers
  def render_success(data:)
    { success: true, message: "successful", data: data }
  end

  def render_error(errors: nil, message:, code:)
    error!({ errors: errors, message: message }, code)
  end
end
