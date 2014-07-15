module Model
  include MuveError

  def initialize
    @new_record = true
  end

  def save!
    create_or_update || raise(MuveSaveError)
  end

  def save
    create_or_update
  end

  def create
  end

  def update
  end

  def new_record?
    @new_record ||= true
  end

  def valid?
    false
  end

  def invalid?
    !valid?
  end

  private
  def create_or_update
    result = new_record? ? create : update
  end
end
