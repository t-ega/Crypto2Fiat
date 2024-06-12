module ResponseHelpers
  def render_success(data:)
    { success: true, message: "successful", data: data }
  end

  def render_error(errors: [], message: nil, code:)
    error!({ success: false, errors: errors, message: message }, code)
  end
end
