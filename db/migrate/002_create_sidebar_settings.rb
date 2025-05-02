class CreateSidebarSettings < ActiveRecord::Migration[6.0] # Assure-toi d'utiliser la version de migration correcte

  def self.up
    create_table :sidebar_settings do |t|
      t.integer :project_id, null: false
      t.text :pages
      t.timestamps # Si tu souhaites avoir les timestamps (created_at et updated_at)
    end
    add_index :sidebar_settings, :project_id, unique: true, name: :sidebar_settings_project_id
  end

  def self.down
    drop_table :sidebar_settings
  end

end
