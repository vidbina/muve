module MuveError
  class MuveError < StandardError
  end

  class MuveSaveError < MuveError
  end

  class MuveInvalidQuery < MuveError
  end
end
