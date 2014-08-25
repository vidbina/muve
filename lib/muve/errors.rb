module MuveError
  class MuveStandardError < StandardError
  end

  class MuveIncompleteImplementation < MuveStandardError
  end

  class MuveInvalidAttributes < MuveStandardError
  end

  class MuveInvalidQuery < MuveStandardError
  end

  class MuveNotConfigured < MuveStandardError
  end

  class MuveValidationError < MuveStandardError
  end

  class MuveSaveError < MuveStandardError
  end
end
