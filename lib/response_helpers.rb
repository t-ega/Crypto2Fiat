module ResponseHelpers
  def render_success(data:, message: "successful")
    { success: true, message: message, data: data }
  end

  def render_error(errors: [], message: nil, code:)
    error!({ success: false, errors: errors, message: message }, code)
  end
end
