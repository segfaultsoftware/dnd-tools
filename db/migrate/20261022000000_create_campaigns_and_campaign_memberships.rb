class CreateCampaignsAndCampaignMemberships < ActiveRecord::Migration[8.1]
  def change
    create_table :campaigns do |t|
      t.string :name, null: false

      t.timestamps
    end

    create_table :campaign_memberships do |t|
      t.references :campaign, null: false, foreign_key: true
      t.references :profile, null: false, foreign_key: true
      t.boolean :is_dm, null: false, default: false
      t.string :campaign_name_key

      t.timestamps
    end

    add_index :campaign_memberships, [ :campaign_id, :profile_id ], unique: true
    add_index :campaign_memberships, [ :profile_id, :campaign_name_key ],
              unique: true,
              where: "is_dm = TRUE",
              name: "index_campaign_memberships_on_dm_profile_and_name_key"
    add_check_constraint :campaign_memberships,
                         "(is_dm = TRUE AND campaign_name_key IS NOT NULL) OR (is_dm = FALSE AND campaign_name_key IS NULL)",
                         name: "campaign_memberships_dm_name_key_presence"
  end
end
