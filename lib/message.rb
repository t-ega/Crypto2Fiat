class Message
  def self.unauthorized
    "You are not authorized to access this resource"
  end

  def self.validation_error
    "One or more required parameters are missing"
  end

  def self.internal_error
    "An internal error occurred. We are aware of this"
  end
end
