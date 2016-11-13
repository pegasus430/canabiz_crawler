class RemoteFileUrl < ActiveRecord::Migration
  def change
    add_column :articles, :remote_file_url, :string
  end
end
