Sequel.migration do
  change do
    alter_table(:compiled_packages) do
      add_column :stemcell_os, String
      add_column :stemcell_version, String
    end

    self[:compiled_packages].each do |compiled_package|
      next unless compiled_package[:stemcell_id]

      stemcell = self[:stemcells].filter(id: compiled_package[:stemcell_id]).first

      self[:compiled_packages].filter(id: compiled_package[:id]).update(
          stemcell_os: stemcell[:operating_system],
          stemcell_version: stemcell[:version]
      )
    end

    alter_table(:compiled_packages) do
      drop_column :stemcell_id
    end
  end
end
