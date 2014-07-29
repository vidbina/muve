module MuveError
  class MuveStandardError < StandardError
  end

  class MuveSaveError < MuveStandardError
  end

  class MuveInvalidQuery < MuveStandardError
  end

  class MuveInvalidAttributes < MuveStandardError
  end

  class MuveIncompleteImplementation < MuveStandardError
  end

  class MuveNotConfigured < MuveStandardError
  end
end
