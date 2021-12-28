namespace :tesoro do
  desc "Import USD/DDK conversion rate by Danish National Bank"
  task import_usd_conversion: :environment do
    Conversion.wipe_and_import('USD')
  end
end
