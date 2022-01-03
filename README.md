tesoro
======

![Example](http://f.cl.ly/items/002R0d1u0D332h3p0R03/Screen%20Shot%202014-12-17%20at%2009.27.13.png)

A simple web app to calculate taxes on capital gain according to the Danish tax system (skat means treasure in english and tesoro in italian)

It kind of works.

Prepare the app in development with
```
bundle install --without production
```

You can load some example data with.

```
bundle exec rake db:migrate
bundle exec rails server
open http://0.0.0.0:3000/
[create a user, via web interface click "Sign up"]
bundle exec rake db:seed
bundle exec rake tesoro:import_usd_conversion  # Import USD/DDK conversion rate by Danish National Bank
```

### TODO:
- Compute commission on sales
