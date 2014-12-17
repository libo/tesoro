tesoro
======

![Example](http://f.cl.ly/items/0q0l0f2u3e2e3U0g2J2Q/Screen%20Shot%202014-12-17%20at%2009.12.45.png)

A simple web app to calculate taxes on capital gain according to the Danish tax system (skat means treasure in english and tesoro in italian)

It kind of works.

You can load some example data with.

```
rake db:migrate
rake tesoro:import_usd_conversion  # Import USD/DDK conversion rate by Danish National Bank
rails server
open http://0.0.0.0:3000/
[create a user]
rake db:seed
```

### TODO:
- Compute commission on sales
