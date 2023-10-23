task sofa_import: :environment do
  SofaImporter.new(filename: Rails.root.join("public", "SofaExport-17022023-212837.csv")).import
end

task goodreads_import: :environment do
  GoodReadsImporter.new(user: User.last).import!
end