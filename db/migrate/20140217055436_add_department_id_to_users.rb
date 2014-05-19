class AddDepartmentIdToUsers < ActiveRecord::Migration
  class User < ActiveRecord::Base; end
  def change
    add_column :users, :department_id, :integer
    add_index :users, :department_id

    User.unscoped.find_each do |r|
      r.update_column :department_id, Department.current.id
    end
  end
end
