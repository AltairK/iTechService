class OrderPolicy < CommonPolicy
  def create?; true; end

  def manage?
    any_manager?(:universal, :media, :marketing, :technician)
  end

  def destroy?
    manage? || (record.user_id == user.id)
  end

  def history?
    manage?
  end
end
