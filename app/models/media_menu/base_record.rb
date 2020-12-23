module MediaMenu
  class BaseRecord < ActiveRecord::Base
    self.abstract_class = true

    if ActiveRecord::Base.connection.table_exists?(:settings) && Setting.meda_menu_database.present?
      establish_connection(adapter: 'sqlite3', database: Setting.meda_menu_database)
    end

    def database_folder
      @database_folder ||= File.dirname Setting.meda_menu_database
    end
  end
end