namespace :tesoro do
  desc "Import USD/DDK conversion rate by Danish National Bank"
  task import_usd_conversion: :environment do
    Conversion.import('USD')
  end

end
