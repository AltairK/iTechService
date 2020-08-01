class DeviceTaskPolicy < BasePolicy
  def update?
    same_department? &&
      (any_admin? || user.role_match?(record.role))
  end
end
